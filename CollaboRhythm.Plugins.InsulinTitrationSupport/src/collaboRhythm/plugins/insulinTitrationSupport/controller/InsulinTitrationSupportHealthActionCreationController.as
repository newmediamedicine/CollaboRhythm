package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.medications.TitrationHealthActionCreator;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class InsulinTitrationSupportHealthActionCreationController implements IHealthActionCreationController
	{
		public static const BUTTON_LABEL:String = "Add Insulin Titration Support";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;

		public function InsulinTitrationSupportHealthActionCreationController(activeAccount:Account,
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

			creator.equipmentTypeMatchString = "blood glucose";
			creator.equipmentInstructions = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";
			creator.equipmentType = "Blood Glucose Meter";
			creator.equipmentName = "FORA D40b";
			creator.decisionPlanSystem = "CollaboRhythm Hypertension Medication Titration Support";
			creator.decisionPlanStepType = "Decide";
			creator.decisionPlanStepName = "Choose a new dose for your insulin";
			creator.decisionPlanName = "Insulin Titration Decision";
			creator.decisionPlanInstructions = "Use CollaboRhythm to follow the algorithm for changing your dose of basal insulin (generally every three days).";
			creator.indication = "Type II Diabetes Mellitus";
			
			creator.createDecisionHealthAction();
			creator.createMeasurementHealthAction();
			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}
	}
}
