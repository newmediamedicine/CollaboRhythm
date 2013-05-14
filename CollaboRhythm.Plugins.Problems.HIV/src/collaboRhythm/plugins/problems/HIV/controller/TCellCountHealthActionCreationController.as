package collaboRhythm.plugins.problems.HIV.controller
{
	import collaboRhythm.plugins.problems.HIV.model.TCellCountHealthActionCreationModel;
	import collaboRhythm.plugins.problems.HIV.view.TCellCountHealthActionCreationView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionCreationModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import spark.components.ViewNavigator;

	public class TCellCountHealthActionCreationController implements IHealthActionCreationController
	{
		private const TCELL_COUNT_BUTTON_LABEL:String = "Add TCell Count";

		private var _tCellCountHealthActionCreationModel:TCellCountHealthActionCreationModel;

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _viewNavigator:ViewNavigator;

		public function TCellCountHealthActionCreationController(activeAccount:Account, activeRecordAccount:Account,
																 viewNavigator:ViewNavigator)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_viewNavigator = viewNavigator;
		}

		public function get buttonLabel():String
		{
			return TCELL_COUNT_BUTTON_LABEL;
		}

		public function showHealthActionCreationView(event:MouseEvent):void
		{

			_tCellCountHealthActionCreationModel = new TCellCountHealthActionCreationModel(_activeAccount,
					_activeRecordAccount);
			var healthActionCreationModelAndController:HealthActionCreationModelAndController = new HealthActionCreationModelAndController(_tCellCountHealthActionCreationModel, this);
			_viewNavigator.pushView(TCellCountHealthActionCreationView, healthActionCreationModelAndController);
		}

		public function showHealthActionEditView(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
		}

		public function saveTCellCount(tCellCount:String, selectedDate:Date):void
		{
			_tCellCountHealthActionCreationModel.saveTCellCount(tCellCount, selectedDate);

			_viewNavigator.popView();
		}
	}
}
