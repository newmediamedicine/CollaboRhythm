package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ActionResult
	{
		private var _actionType:String;
		private var _measurements:ArrayCollection;
		private var _deviceResults:ArrayCollection;
		private var _medicationAdministrations:ArrayCollection;

		public function ActionResult()
		{
		}

		public function get actionType():String
		{
			return _actionType;
		}

		public function set actionType(value:String):void
		{
			_actionType = value;
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
