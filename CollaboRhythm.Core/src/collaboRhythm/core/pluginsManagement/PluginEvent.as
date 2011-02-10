package collaboRhythm.core.pluginsManagement
{
	import flash.events.Event;
	
	public class PluginEvent extends Event
	{
		public static const RELOAD_REQUEST:String = "reloadRequest";
		
		public function PluginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}