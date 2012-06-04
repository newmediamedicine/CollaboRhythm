package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HealthActionOccurrence extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#HealthActionOccurrence";

		private var _name:CodedValue;
		private var _recurrenceIndex:Number;
		private var _results:ArrayCollection = new ArrayCollection();
//		public var schedule:HealthActionSchedule;

		public function HealthActionOccurrence()
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

		public function get recurrenceIndex():Number
		{
			return _recurrenceIndex;
		}

		public function set recurrenceIndex(value:Number):void
		{
			_recurrenceIndex = value;
		}

		public function get results():ArrayCollection
		{
			return _results;
		}

		public function set results(value:ArrayCollection):void
		{
			_results = value;
		}
	}
}
