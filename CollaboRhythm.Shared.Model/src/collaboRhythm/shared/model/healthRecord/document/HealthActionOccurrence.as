package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HealthActionOccurrence extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#HealthActionOccurrence";
		public static const RELATION_TYPE_HEALTH_ACTION_RESULT:String = "http://indivo.org/vocab/documentrels#healthActionResult";

		private var _name:CodedValue;
		private var _recurrenceIndex:Number;
		private var _results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
//		public var schedule:HealthActionSchedule;

		public function HealthActionOccurrence()
		{
			meta.type = DOCUMENT_TYPE;
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

		public function get results():Vector.<DocumentBase>
		{
			return _results;
		}

		public function set results(value:Vector.<DocumentBase>):void
		{
			_results = value;
		}

		public function init(name:CodedValue, recurrenceIndex:int,
							 healthActionResults:Vector.<DocumentBase> = null):void
		{
			_name = name;
            _recurrenceIndex = recurrenceIndex;
			if (healthActionResults)
				results = healthActionResults;
		}
	}
}
