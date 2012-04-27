package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionInputModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationSupportHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import mx.controls.Alert;

	import spark.components.ViewNavigator;

	public class InsulinTitrationSupportHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinTitrationSupportHealthActionInputView;

		private var _dataInputModel:InsulinTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;

		public function InsulinTitrationSupportHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																 viewNavigator:ViewNavigator)
		{
			_dataInputModel = new InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
		}

		public function showHealthActionInputView():void
		{
//			Alert.show("Show insulin titration support health action input view.")

			_dataInputModel.showCharts();
		}

		public function updateVariables(urlVariables:URLVariables):void
		{
		}

		public function get healthActionInputViewClass():Class
		{
			return null;
		}
	}
}
