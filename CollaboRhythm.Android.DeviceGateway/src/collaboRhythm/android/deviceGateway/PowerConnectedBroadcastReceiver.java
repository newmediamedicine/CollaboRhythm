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
