package collaboRhythm.android.deviceGateway;

import android.bluetooth.BluetoothDevice;
import android.os.Bundle;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BluetoothDeviceDisconnectedBroadcastReceiver extends BroadcastReceiver {

	private static final String CLASS = "BluetoothDeviceDisconnectedBroadcastReceiver";
	
	private final static Logger log = LoggerFactory.getLogger();

    public static boolean mBluetoothDeviceConnected = false;
	public static boolean mBluetoothDeviceDisconnected = false;
	
	@Override
	public void onReceive(Context context, Intent intent) {
		log.debug(CLASS + ": " + "Bluetooth device disconnected.");
        if (!mBluetoothDeviceConnected)
        {
			BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            sendBluetoothDeviceDisconnectedIntent(context, device);
        }
		mBluetoothDeviceDisconnected = true;
	}

    public void sendBluetoothDeviceDisconnectedIntent(Context context, BluetoothDevice device) {
		Intent startServiceIntent = new Intent(context, DeviceGatewayService.class);
        startServiceIntent.putExtra(BluetoothDevice.EXTRA_DEVICE, device);
		Bundle extras = new Bundle();
		extras.putBoolean("bluetoothDeviceDisconnected", true);
		startServiceIntent.putExtras(extras);
		context.startService(startServiceIntent);
	}
}