package collaboRhythm.core.model
{
	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;

	public class ApplicationNavigationProxy implements IApplicationNavigationProxy
	{
		private var _applicationControllerBase:ApplicationControllerBase;

		public function ApplicationNavigationProxy(applicationControllerBase:ApplicationControllerBase)
		{
			_applicationControllerBase = applicationControllerBase;
		}

		public function showFullView(fullViewName:String):void
		{
			_applicationControllerBase.appControllersMediator.showFullView(fullViewName);
		}
	}
}
