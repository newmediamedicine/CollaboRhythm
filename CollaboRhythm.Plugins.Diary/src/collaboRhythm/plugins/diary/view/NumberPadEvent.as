/**
 * Created by IntelliJ IDEA.
 * User: Christian
 * Date: 7/13/11
 * Time: 5:54 PM
 * To change this template use File | Settings | File Templates.
 */
package collaboRhythm.plugins.diary.view {
import air.update.events.StatusUpdateErrorEvent;

import flash.events.Event;

public class NumberPadEvent extends Event {

    public static const CLOSE_NUMBER_PAD:String = "CloseNumberPad";
    
    public function NumberPadEvent(type:String) {
        super(type, true);
    }
}
}
