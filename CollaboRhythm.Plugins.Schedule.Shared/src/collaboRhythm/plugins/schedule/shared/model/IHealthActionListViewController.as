package collaboRhythm.plugins.schedule.shared.model
{
	public interface IHealthActionListViewController
	{
		function handleHealthActionResult(calledLocally:Boolean):void;

		function handleHealthActionSelected(calledLocally:Boolean):void;

		function playVideo(instructionalVideo:String):void;

		function removeEventListener():void;
	}
}
