package collaboRhythm.android.deviceGateway;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class DeviceGatewayActivity extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
    	Intent startServiceIntent = new Intent(this, DeviceGatewayService.class);
    	this.startService(startServiceIntent);
    }
}