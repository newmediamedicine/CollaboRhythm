package collaboRhythm.plugins.medications.controller
{
	import collaboRhythm.plugins.medications.model.MedicationHealthActionCreationModel;
	import collaboRhythm.plugins.medications.model.RxNormConcept;
	import collaboRhythm.plugins.medications.view.CreateMedicationOrderView;
	import collaboRhythm.plugins.medications.view.FindNdcCodeView;
	import collaboRhythm.plugins.medications.view.FindRxNormConceptView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionCreationModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionCreationController implements IHealthActionCreationController
	{
		private const BUTTON_LABEL:String = "Add Medication";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;
		private var _medicationHealthActionCreationModel:MedicationHealthActionCreationModel;

		public function MedicationHealthActionCreationController(activeAccount:Account,
																 activeRecordAccount:Account,
																 viewNavigator:ViewNavigator)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_viewNavigator = viewNavigator;
		}

		public function get buttonLabel():String
		{
			return BUTTON_LABEL;
		}

		public function showHealthActionCreationView(event:MouseEvent):void
		{
			_medicationHealthActionCreationModel = new MedicationHealthActionCreationModel(_activeAccount,
					_activeRecordAccount);
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel, this);
			_viewNavigator.pushView(FindRxNormConceptView, healthActionCreationModelAndController);
		}

		public function queryDrugName(drugName:String):void
		{
			_medicationHealthActionCreationModel.queryDrugName(drugName);
		}

		public function showCreateMedicationOrderView(rxNormConcept:RxNormConcept):void
		{
			_medicationHealthActionCreationModel.currentRxNormConcept = rxNormConcept;
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel, this);
			_viewNavigator.pushView(CreateMedicationOrderView, healthActionCreationModelAndController);
		}

		public function showFindNdcCodeView():void
		{
			_medicationHealthActionCreationModel.queryNdcCodes();
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel, this);
			_viewNavigator.pushView(FindNdcCodeView, healthActionCreationModelAndController);
		}

		public function setNdcCode(ndcCode:String):void
		{
			_viewNavigator.popView();
			_medicationHealthActionCreationModel.currentNdcCode = ndcCode;
		}

		public function createMedication(medicationOrderInstructions:String, dose:String, doseUnit:CodedValue,
										 frequency:int):void
		{
			_medicationHealthActionCreationModel.createMedication(medicationOrderInstructions, dose, doseUnit,
					frequency);

			_viewNavigator.popView();
			_viewNavigator.popView();
		}

		public function resetMedicationHealthActionCreationModel():void
		{
			_medicationHealthActionCreationModel.reset();
		}
	}
}
