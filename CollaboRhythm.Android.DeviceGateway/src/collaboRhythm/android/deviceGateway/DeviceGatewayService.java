package collaboRhythm.android.deviceGateway;

import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.text.format.DateFormat;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.appender.FileAppender;
import com.google.code.microlog4android.appender.LogCatAppender;
import com.google.code.microlog4android.appender.SyslogAppender;

import java.util.Date;

public class DeviceGatewayService extends Service
{

    private static final String TAG = "CollaboRhythm.Android.DeviceGateway";
    private static final String CLASS = "DeviceGatewayService";

    private final static Logger log = LoggerFactory.getLogger();

    private BluetoothAdapter mBluetoothAdapter;
    private Boolean mBluetoothSupported;

    private BluetoothServerSocketThread mBluetoothServerSocketThread;
    private Boolean mBluetoothServerSocketRunning = false;

    private BluetoothDevice mBluetoothDevice;

    @Override
    public IBinder onBind(Intent arg0)
    {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void onCreate()
    {
        initializeLogging();

        log.debug(CLASS + ": onCreate");

        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null)
        {
            log.debug(CLASS + ": Bluetooth not supported.");
            createToast("Bluetooth not supported.");
            mBluetoothSupported = false;
        } else
        {
            mBluetoothSupported = true;
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        log.debug(CLASS + ": onStart");

        setForeground(true);

        if (mBluetoothSupported)
        {
            Bundle extras = intent.getExtras();
            if (extras != null && extras.getBoolean("bluetoothDeviceDisconnected"))
            {
				mBluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                startBluetoothDeviceConnectThread();
            }
            else
            {
                if (mBluetoothAdapter.isEnabled())
                {
                    startBluetoothServerSocketThread();
                } else
                {
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
    public void onDestroy()
    {
        log.debug(CLASS + ": onDestroy");
    }

    private void startBluetoothServerSocketThread()
    {
        if (!mBluetoothServerSocketRunning)
        {
            mBluetoothServerSocketThread = new BluetoothServerSocketThread(mServiceMessageHandler);
            if (mBluetoothServerSocketThread.mmBluetoothServerSocket != null)
            {
                mBluetoothServerSocketThread.start();
                mBluetoothServerSocketRunning = true;
            } else
            {
                mBluetoothAdapter.disable();
            }
        }
    }

    private void stopBluetoothServerSocketThread()
    {
        if (mBluetoothServerSocketThread != null && mBluetoothServerSocketRunning)
        {
            mBluetoothServerSocketThread.cancel();
            mBluetoothServerSocketRunning = false;
        }
    }

    private void startBluetoothSocketThread(BluetoothSocket bluetoothSocket)
    {
        BluetoothSocketThread bluetoothSocketThread = new BluetoothSocketThread(bluetoothSocket,
                                                                                mServiceMessageHandler);
        if (bluetoothSocketThread.mmInStream != null && bluetoothSocketThread.mmOutStream != null)
        {
            bluetoothSocketThread.start();
        } else
        {
            instructUserToRetry();
        }
    }

    private void startBluetoothDeviceConnectThread()
    {
        BluetoothDeviceConnectThread bluetoothDeviceConnectThread = new BluetoothDeviceConnectThread(mBluetoothDevice,
                                                                                                     mServiceMessageHandler);
        if (bluetoothDeviceConnectThread.mmBluetoothSocket != null)
        {
            bluetoothDeviceConnectThread.start();
        } else
        {
            instructUserToRetry();
        }
    }

    private void instructUserToRetry()
    {
        Intent startCollaboRhythmIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("collaborhythm://retry=true"));
        startCollaboRhythmIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(startCollaboRhythmIntent);
    }

    private void startCollaboRhythm(Bundle data)
    {
        String bloodPressureString = "name=FORA D40b&success=true&systolic=" + Integer.toString(
                data.getInt("systolic")) + "&diastolic=" + Integer.toString(
                data.getInt("diastolic")) + "&heartrate=" + Integer.toString(data.getInt("heartrate")) + "&date=" + new Date().toGMTString();

        Intent startCollaboRhythmIntent = new Intent(Intent.ACTION_VIEW,
                                                     Uri.parse("collaborhythm://" + bloodPressureString));
        startCollaboRhythmIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

//		startCollaboRhythmIntent.setClassName("air.CollaboRhythm.Mobile.debug", "air.CollaboRhythm.Mobile.debug.AppEntry");
        startActivity(startCollaboRhythmIntent);
    }

    public Handler mServiceMessageHandler = new Handler()
    {
        //@Override
        public void handleMessage(Message message)
        {
            switch (message.what)
            {
                case BluetoothServerSocketThread.BLUETOOTH_DEVICE_CONNECTED:
                    BluetoothSocket bluetoothSocket = (BluetoothSocket) message.obj;
                    mBluetoothDevice = bluetoothSocket.getRemoteDevice();
                    startBluetoothSocketThread(bluetoothSocket);
                    break;
                case BluetoothServerSocketThread.BLUETOOTH_SERVER_SOCKET_EXCEPTION:
                    mBluetoothServerSocketRunning = false;
                    startBluetoothServerSocketThread();
                    break;
                case BluetoothDeviceConnectThread.BLUETOOTH_DEVICE_CONNECT_FAILED:
                    instructUserToRetry();
                case BluetoothSocketThread.RETRIEVE_BLOOD_PRESSURE_SUCCEEDED:
                    startCollaboRhythm(message.getData());
                    break;
                case BluetoothSocketThread.RETRIEVE_BLOOD_PRESSURE_FAILED:
                    if (BluetoothDeviceDisconnectedBroadcastReceiver.mBluetoothDeviceDisconnected && mBluetoothDevice != null)
                    {
                        startBluetoothDeviceConnectThread();
                    } else
                    {
                        instructUserToRetry();
                    }
                    break;
            }
            super.handleMessage(message);
        }
    };

    private void initializeLogging()
    {
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

    private void createToast(CharSequence text)
    {
        int duration = Toast.LENGTH_SHORT;
        Toast toast = Toast.makeText(this, text, duration);
        toast.show();
    }
}
