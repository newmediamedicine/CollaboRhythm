package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.model.ConfirmChangePopUpModel;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedication;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationAlternatePair;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.view.titration.ConfirmChangePopUp;
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationButtonWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import flash.accessibility.AccessibilityProperties;

	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	import spark.events.PopUpEvent;

	public class HypertensionMedicationTitrationAppController extends AppControllerBase implements ITitrationMapController
	{
		public static const DEFAULT_NAME:String = "HypertensionMedicationTitration";

		private var _widgetView:HypertensionMedicationTitrationButtonWidgetView;

		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var _collaborationLobbyNetConnectionServiceProxyLocal:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;
		private var confirmChangePopUp:ConfirmChangePopUp = new ConfirmChangePopUp();
		private var _changeConfirmed:Boolean = false;
		private var _confirmChangePopUpModel:ConfirmChangePopUpModel;

		public function HypertensionMedicationTitrationAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_collaborationLobbyNetConnectionServiceProxyLocal = _collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this,
					_collaborationLobbyNetConnectionServiceProxyLocal);

			confirmChangePopUp.accessibilityProperties = new AccessibilityProperties();
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
				_model = new PersistableHypertensionMedicationTitrationModel(_activeAccount, _activeRecordAccount, _settings, _componentContainer);
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
			initializeModel();
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

		public function save():Boolean
		{
			_model.evaluateForSave();

			if (!_model.isChangeSpecified)
			{
				// TODO: Use a better UI to tell the user that a change must be specified to save
				Alert.show("Please choose a change to the dose before saving.");
				return false;
			}
/*
			else if (_changeConfirmed)
			{
				// already showing popup, so assume this is the result of user clicking OK
				_changeConfirmed = false;
				return true;
			}
*/
			else
			{
				_confirmChangePopUpModel = new ConfirmChangePopUpModel(_model.confirmationMessage, _model.headerMessage, _model.selectionsAgreeWithSystem, _model.selectionsMessage);
				confirmChangePopUp.model = _confirmChangePopUpModel;
				confirmChangePopUp.addEventListener(PopUpEvent.CLOSE, confirmChangePopUp_closeHandler);
				confirmChangePopUp.open(_viewNavigator, true);
				PopUpManager.centerPopUp(confirmChangePopUp);

				return false;
			}
		}

		private function confirmChangePopUp_closeHandler(event:PopUpEvent):void
		{
			if (event.commit)
			{
				if (_model.save(_confirmChangePopUpModel.shouldFinalize))
				{
					_changeConfirmed = true;
				}
			}
		}

		public function reloadSelections():void
		{
			_model.reloadSelections();
		}

		public function reset():void
		{
			_model.evaluateForInitialize();
		}
	}
}
