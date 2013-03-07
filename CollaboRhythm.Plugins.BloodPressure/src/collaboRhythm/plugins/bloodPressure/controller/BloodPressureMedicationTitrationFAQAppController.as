package collaboRhythm.plugins.bloodPressure.controller
{
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModel;
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModelAndController;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMedicationTitrationFAQButtonWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMedicationTitrationFAQView;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import mx.core.UIComponent;

	public class BloodPressureMedicationTitrationFAQAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "BloodPressureMedicationTitrationFAQ";

		private var _widgetView:BloodPressureMedicationTitrationFAQButtonWidgetView;

		private var _synchronizationService:SynchronizationService;

		public function BloodPressureMedicationTitrationFAQAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new BloodPressureMedicationTitrationFAQButtonWidgetView();
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
			_widgetView = value as BloodPressureMedicationTitrationFAQButtonWidgetView;
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

			var bloodPressureMedicationTitrationFAQModel:BloodPressureMedicationTitrationFAQModel = new BloodPressureMedicationTitrationFAQModel();
			var bloodPressureMedicationTitrationFAQController:BloodPressureMedicationTitrationFAQController = new BloodPressureMedicationTitrationFAQController(bloodPressureMedicationTitrationFAQModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var bloodPressureMedicationTitrationFAQModelAndController:BloodPressureMedicationTitrationFAQModelAndController = new BloodPressureMedicationTitrationFAQModelAndController(bloodPressureMedicationTitrationFAQModel,
					bloodPressureMedicationTitrationFAQController);
			_viewNavigator.pushView(BloodPressureMedicationTitrationFAQView, bloodPressureMedicationTitrationFAQModelAndController);
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
	}
}
