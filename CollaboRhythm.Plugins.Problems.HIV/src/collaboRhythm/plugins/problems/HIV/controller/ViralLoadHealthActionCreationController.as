package collaboRhythm.plugins.problems.HIV.controller
{
	import collaboRhythm.plugins.problems.HIV.model.ViralLoadHealthActionCreationModel;
	import collaboRhythm.plugins.problems.HIV.view.ViralLoadHealthActionCreationView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionCreationModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class ViralLoadHealthActionCreationController implements IHealthActionCreationController
	{
		private const VIRAL_LOAD_BUTTON_LABEL:String = "Add Viral Load";

		private var _viralLoadHealthActionCreationModel:ViralLoadHealthActionCreationModel;

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;

		public function ViralLoadHealthActionCreationController(activeAccount:Account,
																activeRecordAccount:Account,
																viewNavigator:ViewNavigator)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_viewNavigator = viewNavigator;
		}

		public function get buttonLabel():String
		{
			return VIRAL_LOAD_BUTTON_LABEL;
		}

		public function showHealthActionCreationView(event:MouseEvent):void
		{

			_viralLoadHealthActionCreationModel = new ViralLoadHealthActionCreationModel(_activeAccount,
					_activeRecordAccount);
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_viralLoadHealthActionCreationModel, this);
			_viewNavigator.pushView(ViralLoadHealthActionCreationView, healthActionCreationModelAndController);
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}

		public function saveViralLoad(viralLoad:String, selectedDate:Date):void
		{
			_viralLoadHealthActionCreationModel.saveViralLoad(viralLoad, selectedDate);

			_viewNavigator.popView();
		}
	}
}
