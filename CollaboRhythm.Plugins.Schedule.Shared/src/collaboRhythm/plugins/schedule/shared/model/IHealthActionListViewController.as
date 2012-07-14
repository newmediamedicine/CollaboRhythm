package collaboRhythm.plugins.schedule.shared.model
{
	public interface IHealthActionListViewController
	{
		function handleHealthActionResult(source:String):void;

		function playVideo(instructionalVideo:String):void;

		function removeEventListener():void;
	}
}
