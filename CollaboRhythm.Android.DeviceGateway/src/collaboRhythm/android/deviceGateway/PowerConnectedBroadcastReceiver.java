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
import android.net.Uri;

public class PowerConnectedBroadcastReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		Intent startCollaboRhythmIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("collaborhythm://"));
		startCollaboRhythmIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
	
//		startCollaboRhythmIntent.setClassName("air.CollaboRhythm.Mobile.debug", "air.CollaboRhythm.Mobile.debug.AppEntry");
		context.startActivity(startCollaboRhythmIntent);
	}

}
