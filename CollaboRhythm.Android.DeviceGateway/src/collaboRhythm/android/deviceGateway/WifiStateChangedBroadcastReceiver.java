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

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.widget.Toast;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class WifiStateChangedBroadcastReceiver extends BroadcastReceiver
{
	private static final String CLASS = "WifiStateChangedBroadcastReceiver";

	private final static Logger log = LoggerFactory.getLogger();

	@Override
	public void onReceive(Context context, Intent intent) {
		Bundle extras = intent.getExtras();
		int state = extras.getInt(WifiManager.EXTRA_WIFI_STATE);
		String stateString = new String();
		switch (state) {
		case WifiManager.WIFI_STATE_DISABLING:
			stateString = "WIFI_STATE_DISABLING";
			break;
		case WifiManager.WIFI_STATE_DISABLED:
			stateString = "WIFI_STATE_DISABLED";
			WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
			wifiManager.setWifiEnabled(true);
			createToast(context, "Please do not turn off Wifi.");
			break;
		case WifiManager.WIFI_STATE_ENABLING:
			stateString = "WIFI_STATE_ENABLING";
			break;
		case WifiManager.WIFI_STATE_ENABLED:
			stateString = "WIFI_STATE_ENABLED";
			break;
		}
		log.debug(CLASS + ": " + stateString);
	}

	private void createToast(Context context, CharSequence text)
    {
        int duration = Toast.LENGTH_SHORT;
        Toast toast = Toast.makeText(context, text, duration);
        toast.show();
    }
}
