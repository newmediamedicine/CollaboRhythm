/**
 * Created by IntelliJ IDEA.
 * User: Christian
 * Date: 7/13/11
 * Time: 5:54 PM
 * To change this template use File | Settings | File Templates.
 */
package collaboRhythm.plugins.diary.view {

import flash.events.Event;

public class CameraEvent extends Event {

    public static const CAMERA_ON:String = "CameraOn";
    public static const CAMERA_OFF:String = "CameraOff";
    
    public function CameraEvent(type:String) {
        super(type, true);
    }
}
}
