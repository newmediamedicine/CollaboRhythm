package collaboRhythm.plugins.schedule.shared.model
{
	import flash.events.MouseEvent;

	public interface IHealthActionCreationController
	{
		function get buttonLabel():String;

		function showHealthActionCreationView(event:MouseEvent):void;
	}
}
