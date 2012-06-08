package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HealthActionResult extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents/healthActionResult#HealthActionResult";

		private var _name:CodedValue;
		private var _planType:String;
		private var _reportedBy:String;
		private var _dateReported:Date;
		private var _actions:ArrayCollection;
		private var _healthActionOccurrence:HealthActionOccurrence;

		public function HealthActionResult()
		{
			super();
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function get planType():String
		{
			return _planType;
		}

		public function set planType(value:String):void
		{
			_planType = value;
		}

		public function get reportedBy():String
		{
			return _reportedBy;
		}

		public function set reportedBy(value:String):void
		{
			_reportedBy = value;
		}

		public function get dateReported():Date
		{
			return _dateReported;
		}

		public function set dateReported(value:Date):void
		{
			_dateReported = value;
		}

		public function get actions():ArrayCollection
		{
			return _actions;
		}

		public function set actions(value:ArrayCollection):void
		{
			_actions = value;
		}

		public function get healthActionOccurrence():HealthActionOccurrence
		{
			return _healthActionOccurrence;
		}

		public function set healthActionOccurrence(value:HealthActionOccurrence):void
		{
			_healthActionOccurrence = value;
		}
	}
}
