package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.*;
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.medications.TitrationHealthActionCreator;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationSupportHealthActionCreationController implements IHealthActionCreationController
	{
		public static const BUTTON_LABEL:String = "Add Hypertension Titration Support";

		private static const HEALTH_ACTION_NAME_BLOOD_PRESSURE:String = DeviceGatewayConstants.BLOOD_PRESSURE_HEALTH_ACTION_NAME;
		public static const EQUIPMENT_NAME:String = "FORA D40b";
		private static const BLOOD_PRESSURE_INSTRUCTIONS:String = "Use device to record blood pressure systolic and blood pressure diastolic readings. Heart rate will also be recorded. Press the power button and wait several seconds to take reading.";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;

		public function HypertensionMedicationTitrationSupportHealthActionCreationController(activeAccount:Account,
																			  activeRecordAccount:Account,
																			  viewNavigator:ViewNavigator,
																			  scheduleItemOccurrence:ScheduleItemOccurrence = null)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_viewNavigator = viewNavigator;
			_scheduleItemOccurrence = scheduleItemOccurrence;
		}

		public function get buttonLabel():String
		{
			return BUTTON_LABEL;
		}

		public function showHealthActionCreationView(event:MouseEvent):void
		{
			// TODO: push the view and provide some fields for the schedule to be customized
//			_viewNavigator.pushView(CreateInsulinTitrationSupportHealthActionView, this);
			var creator:TitrationHealthActionCreator = new TitrationHealthActionCreator(_activeAccount.accountId,
					_activeRecordAccount.primaryRecord);

			creator.equipmentTypeMatchString = "blood pressure";
			creator.equipmentInstructions = BLOOD_PRESSURE_INSTRUCTIONS;
			creator.equipmentType = "Blood Pressure Meter";
			creator.equipmentName = EQUIPMENT_NAME;
			creator.decisionPlanSystem = "CollaboRhythm Hypertension Titration Support";
			creator.decisionPlanName = PersistableHypertensionMedicationTitrationModel.HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME;
			creator.decisionPlanInstructions = "Use CollaboRhythm to follow the algorithm for changing your dose of hypertension medications.";
			creator.indication = "Type II Diabetes Mellitus";
			
			creator.createDecisionHealthAction();
			creator.createMeasurementHealthAction();
//			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}
	}
}
