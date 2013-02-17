package collaboRhythm.plugins.bloodPressure.controller
{
	import collaboRhythm.plugins.bloodPressure.model.HypertensionMedication;
	import collaboRhythm.plugins.bloodPressure.model.HypertensionMedicationAlternatePair;
	import collaboRhythm.plugins.bloodPressure.model.HypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.view.HypertensionMedicationTitrationButtonWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.HypertensionMedicationTitrationView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import mx.core.UIComponent;

	public class HypertensionMedicationTitrationAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "HypertensionMedicationTitration";

		private var _widgetView:HypertensionMedicationTitrationButtonWidgetView;

		private var _model:HypertensionMedicationTitrationModel;
		private var _collaborationLobbyNetConnectionServiceProxyLocal:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function HypertensionMedicationTitrationAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_collaborationLobbyNetConnectionServiceProxyLocal = _collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this,
					_collaborationLobbyNetConnectionServiceProxyLocal);
		}

		override public function initialize():void
		{
			super.initialize();
			initializeModel();

			updateWidgetViewModel();
		}

		private function initializeModel():void
		{
			if (_model == null)
			{
				_model = new HypertensionMedicationTitrationModel(_activeRecordAccount);
			}
		}

		override protected function createWidgetView():UIComponent
		{
			initializeModel();

			_widgetView = new HypertensionMedicationTitrationButtonWidgetView();
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
			_widgetView = value as HypertensionMedicationTitrationButtonWidgetView;
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

		public function showHypertensionMedicationTitrationView():void
		{
			if (_synchronizationService.synchronize("showHypertensionMedicationTitrationView"))
			{
				return;
			}

			_viewNavigator.pushView(HypertensionMedicationTitrationView, this);
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

		public function get model():HypertensionMedicationTitrationModel
		{
			return _model;
		}

		public function handleHypertensionMedicationDoseSelected(hypertensionMedication:HypertensionMedication,
															   doseSelected:int, altKey:Boolean, ctrlKey:Boolean):void
		{
			_model.handleHypertensionMedicationDoseSelected(hypertensionMedication, doseSelected, altKey, ctrlKey);
		}

		public function handleHypertensionMedicationAlternateSelected(hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair,
																	  altKey:Boolean, ctrlKey:Boolean):void
		{
			_model.handleHypertensionMedicationAlternateSelected(hypertensionMedicationAlternatePair, altKey, ctrlKey);
		}
	}
}
