/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.android.deviceGateway;

import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.appender.FileAppender;
import com.google.code.microlog4android.appender.LogCatAppender;
import com.google.code.microlog4android.appender.SyslogAppender;

public class DeviceGatewayService extends Service {

	private static final String TAG = "CollaboRhythm.Android.DeviceGateway";
	private static final String CLASS = "DeviceGatewayService";
	private static final String BATCH_TRANSFER_URL_VARIABLE = "batchTransfer";
	public static final String BATCH_TRANSFER_ACTION_BEGIN = "begin";
	public static final String BATCH_TRANSFER_ACTION_END = "end";

	private final static Logger log = LoggerFactory.getLogger();

	public enum ServiceMessage {
		BLUETOOTH_DEVICE_CONNECTED,
		BLUETOOTH_SERVER_SOCKET_EXCEPTION,
		RETRIEVE_DATA_SUCCEEDED,
		RETRIEVE_DATA_FAILED,
		BLUETOOTH_DEVICE_CONNECT_FAILED,
		RETRIEVE_DATA_BEGIN,
		RETRIEVE_DATA_END,
	}

	private static ServiceMessage[] mServiceMessages = ServiceMessage.values();


	private BluetoothAdapter mBluetoothAdapter;
	private Boolean mBluetoothSupported;

	private BluetoothServerSocketThread mBluetoothServerSocketThread;
	private Boolean mBluetoothServerSocketRunning = false;

	private BluetoothDevice mBluetoothDevice;

	// The DeviceGatewayService is extensible in that it can support connections from an arbitrary number of Bluetooth devices.
	// A separate class that extends Thread and implements IBluetoothSocketThread must be created for each device. The class must
	// provide a BluetoothSocketThreadAnnotation that specifies the name of the Bluetooth device that it handles. The name
	// of each class must then be added to this array.
	private String mBluetoothSocketThreadNames[] = {"collaboRhythm.android.deviceGateway.ForaD40bBluetoothSocketThread"};

	@Override
	public IBinder onBind(Intent arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void onCreate() {
		initializeLogging();

		log.debug(CLASS + ": onCreate");

		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		if (mBluetoothAdapter == null) {
			log.debug(CLASS + ": Bluetooth not supported.");
			createToast("Bluetooth not supported.");
			mBluetoothSupported = false;
		} else {
			mBluetoothSupported = true;
		}

		// Register to receive messages.
		// We are registering an observer (mMessageReceiver) to receive Intents
		// with actions named "custom-event-name".
		this.getApplicationContext().registerReceiver(mMessageReceiver,
				new IntentFilter("CollaboRhythm-health-action-received-v1"));
	}

	// Our handler for received Intents. This will be called whenever an Intent
	// with an action named "custom-event-name" is broadcasted.
	private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			// Get extra data included in the Intent
			String message = intent.getStringExtra("message");
			String healthActionString = intent.getStringExtra("customData");
			Log.d("receiver", "Got message: " + message + " " + healthActionString);
		}
	};

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		log.debug(CLASS + ": onStart");

		setForeground(true);

		if (mBluetoothSupported) {
			Bundle extras = intent != null ? intent.getExtras() : null;
			if (extras != null && extras.getBoolean("bluetoothDeviceDisconnected")) {
				mBluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
				startBluetoothDeviceConnectThread();
			} else {
				if (mBluetoothAdapter.isEnabled()) {
					startBluetoothServerSocketThread();
				} else {
					createToast("Please do not turn off Bluetooth.");
					stopBluetoothServerSocketThread();
					mBluetoothAdapter.enable();
				}
			}
		}

		// Continue running until it is explicitly stopped
		return START_STICKY;
	}

	@Override
	public void onDestroy() {
		log.debug(CLASS + ": onDestroy");

		// Unregister since the activity is about to be closed.
		this.getApplicationContext().unregisterReceiver(mMessageReceiver);
		super.onDestroy();
	}

	private void startBluetoothServerSocketThread() {
		if (!mBluetoothServerSocketRunning) {
			mBluetoothServerSocketThread = new BluetoothServerSocketThread(mServiceMessageHandler);
			if (mBluetoothServerSocketThread.mmBluetoothServerSocket != null) {
				mBluetoothServerSocketThread.start();
				mBluetoothServerSocketRunning = true;
			} else {
				mBluetoothAdapter.disable();
			}
		}
	}

	private void stopBluetoothServerSocketThread() {
		if (mBluetoothServerSocketThread != null && mBluetoothServerSocketRunning) {
			mBluetoothServerSocketThread.cancel();
			mBluetoothServerSocketRunning = false;
		}
	}

	private void startBluetoothSocketThread(BluetoothSocket bluetoothSocket) {
		BluetoothDevice bluetoothDevice = bluetoothSocket.getRemoteDevice();

		for (String bluetoothSocketThreadName : mBluetoothSocketThreadNames) {
			try {
				BluetoothSocketThreadAnnotation bluetoothSocketThreadAnnotation = Class.forName(bluetoothSocketThreadName).getAnnotation(BluetoothSocketThreadAnnotation.class);
				for (String bluetoothDeviceName : bluetoothSocketThreadAnnotation.bluetoothDeviceNames()) {
					if (bluetoothDevice.getName().equals(bluetoothDeviceName)) {
						Class bluetoothSocketThreadClass = Class.forName(bluetoothSocketThreadName);
						IBluetoothSocketThread bluetoothSocketThread = (IBluetoothSocketThread) bluetoothSocketThreadClass.newInstance();
						bluetoothSocketThread.init(bluetoothSocket, mServiceMessageHandler, this.getApplicationContext());
						if (bluetoothSocketThread.isThreadReady()) {
							bluetoothSocketThread.start();
						} else {
							instructUserToRetry();
						}
					}
				}
			} catch (ClassNotFoundException e) {
				log.debug(CLASS + ": Class not found for bluetoothSocketThreadName " + bluetoothSocketThreadName + " in mBluetoothSocketThreadNames.");
			} catch (InstantiationException e) {
				e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
			} catch (IllegalAccessException e) {
				e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
			}
		}
	}

	private void startBluetoothDeviceConnectThread() {
		BluetoothDeviceConnectThread bluetoothDeviceConnectThread = new BluetoothDeviceConnectThread(mBluetoothDevice,
				mServiceMessageHandler);
		if (bluetoothDeviceConnectThread.mmBluetoothSocket != null) {
			bluetoothDeviceConnectThread.start();
		} else {
			instructUserToRetry();
		}
	}

	private void instructUserToRetry() {
		Uri.Builder builder = createBuilder(null);
		builder.appendQueryParameter("retry", "true");
//		String intentString = "retry=true";
		startCollaboRhythmActivity(builder.build());
	}

	private void startCollaboRhythmActivity(Uri intentUri) {
//		Uri intentUri = Uri.parse("collaborhythm://" + intentString);
		Intent startCollaboRhythmIntent = new Intent(Intent.ACTION_VIEW, intentUri);
		startCollaboRhythmIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(startCollaboRhythmIntent);
	}

	private void sendDataToCollaboRhythm(Bundle data) {
		Uri.Builder builder = createBuilder(data);
		builder.appendQueryParameter("success", "true");
		builder.appendQueryParameter(BATCH_TRANSFER_URL_VARIABLE, "data");
//		String intentString = "healthActionType=Equipment" + "&equipmentName=" + data.getString("equipmentName") + "&success=true&" + BATCH_TRANSFER_URL_VARIABLE + "=" + "data&" +
//				"&healthActionName=" + data.getString("healthActionName") + data.getString("result") + "&correctedMeasuredDate=" + data.getString("correctedMeasuredDate") + "&deviceMeasuredDate=" + data.getString("deviceMeasuredDate") + "&localTransmittedDate=" + data.getString("localTransmittedDate") + "&deviceTransmittedDate=" + data.getString("deviceTransmittedDate");
		startCollaboRhythmActivity(builder.build());
	}

	private Uri.Builder createBuilder(Bundle dataBundle) {
		Uri.Builder builder = new Uri.Builder();
		builder.scheme("collaborhythm");
		builder.authority("loadData");

		if (dataBundle != null) {
			for (String key : dataBundle.keySet())
			{
				builder.appendQueryParameter(key, dataBundle.getString(key));
			}
		}
		return builder;
	}

	private void sendBeginToCollaboRhythm(Bundle data) {
		sendBatchTransferMessageToCollaboRhythm(data, BATCH_TRANSFER_ACTION_BEGIN);
	}

	private void sendEndToCollaboRhythm(Bundle data) {
		sendBatchTransferMessageToCollaboRhythm(data, BATCH_TRANSFER_ACTION_END);
	}

	private void sendBatchTransferMessageToCollaboRhythm(Bundle data, String batchTransfer) {
		Uri.Builder builder = createBuilder(data);
		builder.appendQueryParameter("success", "true");
		builder.appendQueryParameter(BATCH_TRANSFER_URL_VARIABLE, batchTransfer);
//		String healthActionNamePart = data.containsKey("healthActionName") ? ("&healthActionName=" + data.getString("healthActionName")) : "";
//		String intentString = "healthActionType=Equipment" + healthActionNamePart + "&equipmentName=" + data.getString("equipmentName") + "&success=true&" + BATCH_TRANSFER_URL_VARIABLE + "=" + batchTransfer;
		startCollaboRhythmActivity(builder.build());
	}

	public Handler mServiceMessageHandler = new Handler() {
		//@Override
		public void handleMessage(Message message) {
			switch (mServiceMessages[message.what]) {
				case BLUETOOTH_DEVICE_CONNECTED:
					BluetoothSocket bluetoothSocket = (BluetoothSocket) message.obj;
					mBluetoothDevice = bluetoothSocket.getRemoteDevice();
					startBluetoothSocketThread(bluetoothSocket);
					break;
				case BLUETOOTH_SERVER_SOCKET_EXCEPTION:
					mBluetoothServerSocketRunning = false;
					startBluetoothServerSocketThread();
					break;
				case BLUETOOTH_DEVICE_CONNECT_FAILED:
					instructUserToRetry();
				case RETRIEVE_DATA_BEGIN:
					sendBeginToCollaboRhythm(message.getData());
					break;
				case RETRIEVE_DATA_SUCCEEDED:
					sendDataToCollaboRhythm(message.getData());
					break;
				case RETRIEVE_DATA_END:
					sendEndToCollaboRhythm(message.getData());
					break;
				case RETRIEVE_DATA_FAILED:
					if (BluetoothDeviceDisconnectedBroadcastReceiver.mBluetoothDeviceDisconnected && mBluetoothDevice != null) {
						startBluetoothDeviceConnectThread();
					} else {
						instructUserToRetry();
					}
					break;
			}
			super.handleMessage(message);
		}
	};

	private void initializeLogging() {
		// Log the output to LogCat, a Syslog server, and a file
		LogCatAppender logCatAppender = new LogCatAppender();
		log.addAppender(logCatAppender);
		SyslogAppender syslogAppender = new SyslogAppender();
		syslogAppender.setProperty("host", "18.85.55.246");
		syslogAppender.setHeader(false);
		log.addAppender(syslogAppender);
		FileAppender fileAppender = new FileAppender();
		fileAppender.setAppend(true);
		fileAppender.setFileName("DeviceGateway.txt");
		log.setClientID(TAG);
		log.addAppender(fileAppender);
	}

	private void createToast(CharSequence text) {
		int duration = Toast.LENGTH_SHORT;
		Toast toast = Toast.makeText(this, text, duration);
		toast.show();
	}
}
