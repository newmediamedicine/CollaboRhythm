/**
 * Copyright 2012 John Moore, Scott Gilroy
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

import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.os.Handler;

/**
 * Created with IntelliJ IDEA.
 * User: jom
 * Date: 4/4/12
 * Time: 2:57 PM
 * To change this template use File | Settings | File Templates.
 */
public interface IBluetoothSocketThread {
	void init(BluetoothSocket bluetoothSocket, Handler serviceMessageHandler, Context applicationContext);
	Boolean isThreadReady();
	void start();
}
