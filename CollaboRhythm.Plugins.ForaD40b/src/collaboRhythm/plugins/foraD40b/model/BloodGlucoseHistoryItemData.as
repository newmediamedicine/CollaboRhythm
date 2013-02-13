package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bHealthActionInputController;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodGlucoseHistoryItemData
	{
		private var _bloodGlucoseVitalSign:VitalSign;
		private var _dataInputModel:BloodGlucoseHealthActionInputModel;
		private var _dataInputController:ForaD40bHealthActionInputController;

		public function BloodGlucoseHistoryItemData(bloodGlucoseVitalSign:VitalSign,
													dataInputModel:BloodGlucoseHealthActionInputModel,
													dataInputController:ForaD40bHealthActionInputController)
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

		public function get dataInputModel():BloodGlucoseHealthActionInputModel
		{
			return _dataInputModel;
		}

		public function set dataInputModel(value:BloodGlucoseHealthActionInputModel):void
		{
			_dataInputModel = value;
		}

		public function get dataInputController():ForaD40bHealthActionInputController
		{
			return _dataInputController;
		}

		public function set dataInputController(value:ForaD40bHealthActionInputController):void
		{
			_dataInputController = value;
		}

		public function get dateMeasuredStart():Date
		{
			return _bloodGlucoseVitalSign ? _bloodGlucoseVitalSign.dateMeasuredStart : null;
		}
	}
}
