package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.BloodGlucoseHealthActionInputController;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodGlucoseHistoryItemData
	{
		private var _bloodGlucoseVitalSign:VitalSign;
		private var _dataInputModel:BloodGlucoseHealthActionInputModelCollection;
		private var _dataInputController:BloodGlucoseHealthActionInputController;

		public function BloodGlucoseHistoryItemData(bloodGlucoseVitalSign:VitalSign,
													dataInputModel:BloodGlucoseHealthActionInputModelCollection,
													dataInputController:BloodGlucoseHealthActionInputController)
		{
			_bloodGlucoseVitalSign = bloodGlucoseVitalSign;
			_dataInputModel = dataInputModel;
			_dataInputController = dataInputController;
		}

		public function get bloodGlucoseVitalSign():VitalSign
		{
			return _bloodGlucoseVitalSign;
		}

		public function set bloodGlucoseVitalSign(value:VitalSign):void
		{
			_bloodGlucoseVitalSign = value;
		}

		public function get dataInputModel():BloodGlucoseHealthActionInputModelCollection
		{
			return _dataInputModel;
		}

		public function set dataInputModel(value:BloodGlucoseHealthActionInputModelCollection):void
		{
			_dataInputModel = value;
		}

		public function get dataInputController():BloodGlucoseHealthActionInputController
		{
			return _dataInputController;
		}

		public function set dataInputController(value:BloodGlucoseHealthActionInputController):void
		{
			_dataInputController = value;
		}
	}
}
