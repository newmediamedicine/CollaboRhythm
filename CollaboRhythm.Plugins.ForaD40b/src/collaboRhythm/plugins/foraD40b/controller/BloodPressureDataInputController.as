package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodPressureDataInputModel;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;

	import spark.components.ViewNavigator;

	public class BloodPressureDataInputController extends DataInputControllerBase
    {
		private var _dataInputModel:BloodPressureDataInputModel;
		private var _viewNavigator:ViewNavigator;

        public function BloodPressureDataInputController(dataInputModel:BloodPressureDataInputModel,
														 viewNavigator:ViewNavigator)
        {
			_dataInputModel = dataInputModel;
			_viewNavigator = viewNavigator;
		}

		public function submitBloodPressure(position:String, site:String):void
		{
			_dataInputModel.submitBloodPressure(position, site);
			_viewNavigator.popView();
		}
	}
}
