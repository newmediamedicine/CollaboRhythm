package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class Occurrence
	{
		private var _startTime:Date;
		private var _endTime:Date;
		private var _additionalDetails:String;
		private var _stopCondition:StopCondition;
		private var _measurements:ArrayCollection;
		private var _deviceResults:ArrayCollection;
		private var _medicationAdministrations:ArrayCollection;

		public function Occurrence()
		{
		}

		public function get startTime():Date
		{
			return _startTime;
		}

		public function set startTime(value:Date):void
		{
			_startTime = value;
		}

		public function get endTime():Date
		{
			return _endTime;
		}

		public function set endTime(value:Date):void
		{
			_endTime = value;
		}

		public function get additionalDetails():String
		{
			return _additionalDetails;
		}

		public function set additionalDetails(value:String):void
		{
			_additionalDetails = value;
		}

		public function get stopCondition():StopCondition
		{
			return _stopCondition;
		}

		public function set stopCondition(value:StopCondition):void
		{
			_stopCondition = value;
		}

		public function get measurements():ArrayCollection
		{
			return _measurements;
		}

		public function set measurements(value:ArrayCollection):void
		{
			_measurements = value;
		}

		public function get deviceResults():ArrayCollection
		{
			return _deviceResults;
		}

		public function set deviceResults(value:ArrayCollection):void
		{
			_deviceResults = value;
		}

		public function get medicationAdministrations():ArrayCollection
		{
			return _medicationAdministrations;
		}

		public function set medicationAdministrations(value:ArrayCollection):void
		{
			_medicationAdministrations = value;
		}
	}
}
