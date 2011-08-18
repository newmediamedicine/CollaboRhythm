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