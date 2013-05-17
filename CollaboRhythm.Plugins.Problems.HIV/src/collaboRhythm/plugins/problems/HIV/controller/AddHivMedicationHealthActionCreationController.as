package collaboRhythm.plugins.problems.HIV.controller
{
	import collaboRhythm.plugins.problems.HIV.model.AddHivMedicationHealthActionCreationModel;
	import collaboRhythm.plugins.problems.HIV.model.HIVMedicationChoice;
	import collaboRhythm.plugins.problems.HIV.view.AddHivMedicationHealthActionCreationView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionCreationModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.SaveMedicationCompleteEvent;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class AddHivMedicationHealthActionCreationController implements IHealthActionCreationController
	{
		private const ADD_HIV_MEDICATION_BUTTON_LABEL:String = "Add HIV Medication";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;

		private var _addHivMedicationHealthActionCreationModel:AddHivMedicationHealthActionCreationModel;

		public function AddHivMedicationHealthActionCreationController(activeAccount:Account,
																	   activeRecordAccount:Account,
																	   viewNavigator:ViewNavigator)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_viewNavigator = viewNavigator;
		}

		public function get buttonLabel():String
		{
			return ADD_HIV_MEDICATION_BUTTON_LABEL;
		}

		public function showHealthActionCreationView(event:MouseEvent):void
		{
			_addHivMedicationHealthActionCreationModel = new AddHivMedicationHealthActionCreationModel(_activeAccount, _activeRecordAccount);
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_addHivMedicationHealthActionCreationModel, this);
			_viewNavigator.pushView(AddHivMedicationHealthActionCreationView, healthActionCreationModelAndController);
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}

		public function scheduleMedication(hivMedicationChoice:HIVMedicationChoice):void
		{
			_addHivMedicationHealthActionCreationModel.addEventListener(SaveMedicationCompleteEvent.SAVE_MEDICATION, saveMedication_completeEventHandler);

			_addHivMedicationHealthActionCreationModel.scheduleMedication(hivMedicationChoice);
		}

		private function saveMedication_completeEventHandler(event:SaveMedicationCompleteEvent):void
		{
			for (var viewToPop:int = 1; viewToPop <= event.viewsToPop; viewToPop++)
			{
				_viewNavigator.popView();
			}

			_addHivMedicationHealthActionCreationModel.removeEventListener(SaveMedicationCompleteEvent.SAVE_MEDICATION, saveMedication_completeEventHandler);
		}
	}
}
