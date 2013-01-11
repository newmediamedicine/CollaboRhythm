package exampleOrg.collaboRhythm.plugins.problems.hypertensionHelpExample.controller
{

	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import exampleOrg.collaboRhythm.plugins.problems.hypertensionHelpExample.model.HypertensionHelpExampleModel;
	import exampleOrg.collaboRhythm.plugins.problems.hypertensionHelpExample.view.HypertensionHelpExampleButtonWidgetView;
	import exampleOrg.collaboRhythm.plugins.problems.hypertensionHelpExample.view.HypertensionHelpExampleView;

	import mx.core.UIComponent;

	public class HypertensionHelpExampleAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "HypertensionHelpExample";

		private var _widgetView:HypertensionHelpExampleButtonWidgetView;

		private var _model:HypertensionHelpExampleModel;
		private var _collaborationLobbyNetConnectionServiceProxyLocal:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function HypertensionHelpExampleAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_collaborationLobbyNetConnectionServiceProxyLocal = _collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this,
																 _collaborationLobbyNetConnectionServiceProxyLocal);
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new HypertensionHelpExampleButtonWidgetView();
			return _widgetView;
		}

		override public function reloadUserData():void
		{
			removeUserData();

			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, _model);
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
			_widgetView = value as HypertensionHelpExampleButtonWidgetView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return false;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		protected override function removeUserData():void
		{
			_model = null;
			// unregister any components in the _componentContainer here, such as:
			// _componentContainer.unregisterServiceType(IIndividualMessageHealthRecordService);
		}

		public function showHypertensionHelpExampleView():void
		{
			if (_synchronizationService.synchronize("showHypertensionHelpExampleView"))
			{
				return;
			}

			_viewNavigator.pushView(HypertensionHelpExampleView, this);
		}

		override public function close():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
				_synchronizationService = null;
			}

			super.close();
		}

		public function get model():HypertensionHelpExampleModel
		{
			return _model;
		}
	}
}
