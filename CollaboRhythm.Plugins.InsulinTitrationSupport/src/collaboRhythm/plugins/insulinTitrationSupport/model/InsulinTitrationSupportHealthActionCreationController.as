package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.view.CreateInsulinTitrationSupportHealthActionView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

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
			var creationModel:InsulinTitrationSupportHealthActionCreationModel = new InsulinTitrationSupportHealthActionCreationModel(_activeAccount, _activeRecordAccount);
			creationModel.createDecisionHealthAction();
			creationModel.createBloodGlucoseHealthAction();
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}
	}
}
