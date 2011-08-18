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

import java.io.IOException;
import java.util.UUID;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Handler;
import android.os.Message;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class BluetoothDeviceConnectThread extends Thread {
	
	private static final String CLASS = "BluetoothDeviceConnectThread";
	
	private static final UUID SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
	public static final int BLUETOOTH_DEVICE_CONNECTED = 1;
	public static final int BLUETOOTH_DEVICE_CONNECT_FAILED = 6;	
	
	private BluetoothAdapter mBluetoothAdapter;
    public final BluetoothSocket mmBluetoothSocket;
    
    private Handler mServiceMessageHandler;
    
    private final static Logger log = LoggerFactory.getLogger();
    
    public BluetoothDeviceConnectThread(BluetoothDevice bluetoothDevice, Handler serviceMessageHandler) {
        // Use a temporary object that is later assigned to mmSocket,
        // because mmSocket is final
    	mServiceMessageHandler = serviceMessageHandler;
        BluetoothSocket tmp = null;

        // Get a BluetoothSocket to connect with the given BluetoothDevice
        log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket opening...");
        try {
        	// SPP_UUID is the app's UUID string, also used by the server code
        	tmp = bluetoothDevice.createRfcommSocketToServiceRecord(SPP_UUID);
        	log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket opening - SUCCEEDED");
        } catch (IOException e)	{
        	log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket opening - FAILED");
        }
    	mmBluetoothSocket = tmp;
    }

    public void run() {
        // Cancel discovery because it will slow down the connection
    	mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    	mBluetoothAdapter.cancelDiscovery();

    	log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket connecting to device...");
    	try {
    		// Connect the device through the socket. This will block
    		// until it succeeds or throws an exception
    		mmBluetoothSocket.connect();
    		log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket connecting to device - SUCCEEDED");
    		sendBluetoothDeviceConnectionMessage(BLUETOOTH_DEVICE_CONNECTED);
    	} catch (IOException connectException) {
    		// Unable to connect; close the socket and get out
    		log.debug(CLASS + getId() + ": mmBluetoothRfcommSocket connecting to device - FAILED");
//    		sendBluetoothDeviceConnectionMessage(BLUETOOTH_DEVICE_CONNECT_FAILED);
    		try {
    			mmBluetoothSocket.close();
    		} catch (IOException closeException) { }
    		return;
    	} 
    }
    
    // Do work to manage the connection (in a separate thread)
    private void sendBluetoothDeviceConnectionMessage(int connectionResult) {
    	Message message = Message.obtain();
    	message.what = connectionResult;
    	message.obj = mmBluetoothSocket;
    	mServiceMessageHandler.sendMessage(message);
    }

    /** Will cancel an in-progress connection, and close the socket */
    public void cancel() {
        try {
            mmBluetoothSocket.close();
        } catch (IOException e) { }
    }
}
