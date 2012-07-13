package collaboRhythm.shared.model
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;

	public interface IApplicationNavigationProxy
	{
		function showFullView(fullViewName:String):void;

		function hideFullView(appControllerBase:AppControllerBase):void;
	}
}
