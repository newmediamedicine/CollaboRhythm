package collaboRhythm.core.model
{
	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
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
			_applicationControllerBase.appControllersMediator.showFullView("local", fullViewName);
		}

		public function hideFullView(appController:AppControllerBase):void
		{
			_applicationControllerBase.appControllersMediator.hideFullView(appController);
		}
	}
}
