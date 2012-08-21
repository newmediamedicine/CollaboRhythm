package collaboRhythm.plugins.medications.controller
{
	import collaboRhythm.plugins.medications.model.MedicationHealthActionCreationModel;
	import collaboRhythm.plugins.medications.model.RxNormConcept;
	import collaboRhythm.plugins.medications.model.SaveMedicationCompleteEvent;
	import collaboRhythm.plugins.medications.view.CreateMedicationOrderView;
	import collaboRhythm.plugins.medications.view.FindNdcCodeView;
	import collaboRhythm.plugins.medications.view.FindRxNormConceptView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionCreationModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionCreationController implements IHealthActionCreationController
	{
		private const BUTTON_LABEL:String = "Add Medication";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;
		private var _medicationHealthActionCreationModel:MedicationHealthActionCreationModel;

		public function MedicationHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
																 viewNavigator:ViewNavigator,
																 scheduleItemOccurrence:ScheduleItemOccurrence = null)
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
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel,
					this);
			_viewNavigator.pushView(FindRxNormConceptView, healthActionCreationModelAndController);
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
			_medicationHealthActionCreationModel = new MedicationHealthActionCreationModel(_activeAccount,
					_activeRecordAccount, scheduleItemOccurrence);
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel,
					this);
			_viewNavigator.pushView(CreateMedicationOrderView, healthActionCreationModelAndController);
		}

		public function queryDrugName(drugName:String):void
		{
			_medicationHealthActionCreationModel.queryDrugName(drugName);
		}

		public function showCreateMedicationOrderView(rxNormConcept:RxNormConcept):void
		{
			_medicationHealthActionCreationModel.currentRxNormConcept = rxNormConcept;
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel,
					this);
			_viewNavigator.pushView(CreateMedicationOrderView, healthActionCreationModelAndController);
		}

		public function showFindNdcCodeView():void
		{
			_medicationHealthActionCreationModel.queryNdcCodes();
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_medicationHealthActionCreationModel,
					this);
			_viewNavigator.pushView(FindNdcCodeView, healthActionCreationModelAndController);
		}

		public function setNdcCode(ndcCode:String):void
		{
			_viewNavigator.popView();
			_medicationHealthActionCreationModel.currentNdcCode = ndcCode;
		}

		public function saveMedication():void
		{
			_medicationHealthActionCreationModel.saveMedication();

			_medicationHealthActionCreationModel.addEventListener(SaveMedicationCompleteEvent.SAVE_MEDICATION, saveMedication_completeEventHandler);
		}

		private function saveMedication_completeEventHandler(event:SaveMedicationCompleteEvent):void
		{
			for (var viewToPop:int = 1; viewToPop <= event.viewsToPop; viewToPop++)
			{
				_viewNavigator.popView();
			}

			_medicationHealthActionCreationModel.removeEventListener(SaveMedicationCompleteEvent.SAVE_MEDICATION, saveMedication_completeEventHandler);
		}

		public function resetMedicationHealthActionCreationModel():void
		{
			_medicationHealthActionCreationModel.resetMedicationHealthActionCreationModel();
		}

		public function updateInstructions(instructions:String):void
		{
			_medicationHealthActionCreationModel.instructions = instructions;
		}

		public function updateDose(dose:String):void
		{
			_medicationHealthActionCreationModel.dose = dose;
		}

		public function updateFrequency(frequency:int):void
		{
			_medicationHealthActionCreationModel.frequency = frequency;
		}
	}
}
