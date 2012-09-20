package collaboRhythm.plugins.schedule.shared.model
{
	public interface IHealthActionListViewController
	{
		function handleHealthActionResult():void;

		function handleHealthActionSelected():void;

		function playVideo(instructionalVideo:String):void;

		function removeEventListener():void;
	}
}
