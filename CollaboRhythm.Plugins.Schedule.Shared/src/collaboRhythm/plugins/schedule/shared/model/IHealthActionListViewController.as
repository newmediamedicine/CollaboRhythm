package collaboRhythm.plugins.schedule.shared.model
{
	import flash.events.MouseEvent;

	public interface IHealthActionListViewController
	{
		function handleHealthActionResult():void;

		function handleHealthActionSelected():void;

		function playVideo(instructionalVideo:String):void;

		function removeEventListener():void;

		function handleHealthActionCommandButtonClick(event:MouseEvent):void;
	}
}
