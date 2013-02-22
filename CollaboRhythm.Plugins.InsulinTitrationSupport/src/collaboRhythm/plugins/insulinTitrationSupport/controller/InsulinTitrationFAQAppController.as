package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModel;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModelAndController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationFAQButtonWidgetView;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationFAQView;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import mx.core.UIComponent;

	public class InsulinTitrationFAQAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "InsulinTitrationFAQ";

		private var _widgetView:InsulinTitrationFAQButtonWidgetView;

		private var _synchronizationService:SynchronizationService;

		public function InsulinTitrationFAQAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new InsulinTitrationFAQButtonWidgetView();
			return _widgetView
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as InsulinTitrationFAQButtonWidgetView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return false;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		public function showInsulinTitrationFaq():void
		{
			if (_synchronizationService.synchronize("showInsulinTitrationFaq"))
			{
				return;
			}

			var insulinTitrationFAQModel:InsulinTitrationFAQModel = new InsulinTitrationFAQModel();
			var insulinTitrationFAQController:InsulinTitrationFAQController = new InsulinTitrationFAQController(insulinTitrationFAQModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var insulinTitrationFAQModelAndController:InsulinTitrationFAQModelAndController = new InsulinTitrationFAQModelAndController(insulinTitrationFAQModel,
					insulinTitrationFAQController);
			_viewNavigator.pushView(InsulinTitrationFAQView, insulinTitrationFAQModelAndController);
		}

		override protected function removeUserData():void
		{
			super.removeUserData();
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}
