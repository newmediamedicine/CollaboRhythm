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
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.os.Handler;
import android.os.Message;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class BluetoothServerSocketThread extends Thread {

	private static final String CLASS = "BluetoothSocketServerThread";
	
	private static final String NAME = "BloodPressureService";
	private static final UUID SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
	public static final int BLUETOOTH_DEVICE_CONNECTED = 1;
	public static final int BLUETOOTH_SERVER_SOCKET_EXCEPTION = 2;
	public static final String OPERATION_CANCELED = "Operation Canceled";
    
    private Handler mServiceMessageHandler;
	
    private BluetoothAdapter mBluetoothAdapter;
    public final BluetoothServerSocket mmBluetoothServerSocket;   
    private BluetoothSocket mBluetoothSocket;
    
    private final static Logger log = LoggerFactory.getLogger();

    public BluetoothServerSocketThread(Handler serviceMessageHandler) {
        // Use a temporary object that is later assigned to mmServerSocket,
        // because mmServerSocket is final
        BluetoothServerSocket tmp = null;
        mServiceMessageHandler = serviceMessageHandler;
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        log.debug(CLASS + getId() + ": mmBluetoothServerSocket opening...");
        try {
            // SPP_UUID is the app's UUID string, also used by the client code
            tmp = mBluetoothAdapter.listenUsingRfcommWithServiceRecord(NAME, SPP_UUID);
            log.debug(CLASS + getId() + ": mmBluetoothServerSocket opening - SUCCEEDED");
        } catch (IOException e) { 
        	log.debug(CLASS + getId() + ": mmBluetoothServerSocket opening - FAILED");
        }
        mmBluetoothServerSocket = tmp;
    }

    public void run() {
    	try {
    		mBluetoothSocket = null;
    		// Keep listening until exception occurs or a Bluetooth socket is returned
    		while (true) {
    			log.debug(CLASS + getId() + ": mmBluetoothServerSocket listening...");
    			try {
    				mBluetoothSocket = mmBluetoothServerSocket.accept();
    				// The BluetoothStateChangedBroadcastReceiver will keep track of whether the device disconnects after it connects here.
    	            BluetoothDeviceDisconnectedBroadcastReceiver.mBluetoothDeviceDisconnected = false;
                    BluetoothDeviceDisconnectedBroadcastReceiver.mBluetoothDeviceConnected = false;
    				log.debug(CLASS + getId() + ": mmBluetoothServerSocket listening - SUCCEEDED.");
    			} catch (IOException e) {
    				handleBluetoothSocketServerException(e);
    				break;
    			}
    			// If a connection was accepted
    			if (mBluetoothSocket != null) {
    				// Do work to manage the connection (in a separate thread)
                    BluetoothDeviceDisconnectedBroadcastReceiver.mBluetoothDeviceConnected = true;
    				sendBluetoothDeviceConnnectedMessage(mBluetoothSocket);
    			}
    		}
    		log.debug(CLASS + getId() + ": thread terminated.");
    	} catch (Exception e) {
    		log.debug(CLASS + getId() + ": thread threw an unhandled exception.");
    		e.printStackTrace();
    		handleBluetoothSocketServerException(e);
    	}
    }
    
    private void handleBluetoothSocketServerException(Exception e) {
    	// In the case of an exception, always close the Bluetooth socket if it is open
    	if (mBluetoothSocket != null)
		{
			closeBluetoothSocket(mBluetoothSocket);
		}
		// If this thread was not canceled by the service, then close the BluetoothServerSocket and let the service know
    	// TODO: Confirm that this exception is only thrown 
		if (!e.getMessage().equals(OPERATION_CANCELED))
		{
			log.debug(CLASS + getId() + ": mmBluetoothServerSocket listening - FAILED.");
			closeBluetoothServerSocket();
			sendBluetoothServerSocketExceptionMessage();
		}
    }
    
    // Do work to manage the connection (in a separate thread)
    private void sendBluetoothDeviceConnnectedMessage(BluetoothSocket socket) {
    	Message message = Message.obtain();
    	message.what = BLUETOOTH_DEVICE_CONNECTED;
    	message.obj = socket;
    	mServiceMessageHandler.sendMessage(message);
    }
    
    private void sendBluetoothServerSocketExceptionMessage() {
    	Message message = Message.obtain();
    	message.what = BLUETOOTH_SERVER_SOCKET_EXCEPTION;
    	mServiceMessageHandler.sendMessage(message);
    }
    
    private void closeBluetoothSocket(BluetoothSocket bluetoothSocket) {
    	log.debug(CLASS + getId() + ": bluetoothSocket closing...");
    	try {
    		bluetoothSocket.close();
    		log.debug(CLASS + getId() + ": bluetoothSocket closing - SUCCEEDED");
        } catch (IOException e) {
        	log.debug(CLASS + getId() + ": bluetoothSocket closing - FAILED");
        }
    }

    private void closeBluetoothServerSocket() {
    	log.debug(CLASS + getId() + ": mmBluetoothServerSocket closing...");
    	try {
            mmBluetoothServerSocket.close();
            log.debug(CLASS + getId() + ": mmBluetoothServerSocket closing - SUCCEEDED");
        } catch (IOException e) {
        	log.debug(CLASS + getId() + ": mmBluetoothServerSocket closing - FAILED");
        }
    }
    
    /** Will cancel the listening socket, and cause the thread to finish */
    public void cancel() {
        closeBluetoothServerSocket();
    }
	
}
