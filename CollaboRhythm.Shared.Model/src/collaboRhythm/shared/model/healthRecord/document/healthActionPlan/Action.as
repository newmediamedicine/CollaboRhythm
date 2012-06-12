package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class Action
	{
		private var _position:CodedValue;
		private var _stopConditions:ArrayCollection;
		private var _targets:ArrayCollection;
		private var _measurementPlans:ArrayCollection;
		private var _devicePlans:ArrayCollection;
		private var _medicationPlans:ArrayCollection;

		public function Action()
		{
		}

		public function get position():CodedValue
		{
			return _position;
		}

		public function set position(value:CodedValue):void
		{
			_position = value;
		}

		public function get stopConditions():ArrayCollection
		{
			return _stopConditions;
		}

		public function set stopConditions(value:ArrayCollection):void
		{
			_stopConditions = value;
		}

		public function get targets():ArrayCollection
		{
			return _targets;
		}

		public function set targets(value:ArrayCollection):void
		{
			_targets = value;
		}

		public function get measurementPlans():ArrayCollection
		{
			return _measurementPlans;
		}

		public function set measurementPlans(value:ArrayCollection):void
		{
			_measurementPlans = value;
		}

		public function get devicePlans():ArrayCollection
		{
			return _devicePlans;
		}

		public function set devicePlans(value:ArrayCollection):void
		{
			_devicePlans = value;
		}

		public function get medicationPlans():ArrayCollection
		{
			return _medicationPlans;
		}

		public function set medicationPlans(value:ArrayCollection):void
		{
			_medicationPlans = value;
		}
	}
}
