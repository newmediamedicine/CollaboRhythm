package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.*;

	import collaboRhythm.shared.model.*;

	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

	[Bindable]
	public class VitalSign extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#VitalSign";

		private var _name:CodedValue;
		private var _measuredBy:String;
		private var _dateMeasuredStart:Date;
		private var _dateMeasuredEnd:Date;
		private var _result:ValueAndUnit;
		private var _site:String;
		private var _position:String;
		private var _technique:String;
		private var _comments:String;

		public function VitalSign(name:CodedValue = null, measuredBy:String = null, dateMeasuredStart:Date = null, dateMeasuredEnd:Date = null, result:ValueAndUnit = null, site:String = null, position:String = null, technique:String = null, comments:String = null)
		{
			meta.type = DOCUMENT_TYPE;
			_name = name;
			_measuredBy = measuredBy;
			_dateMeasuredStart = dateMeasuredStart;
			_dateMeasuredEnd = dateMeasuredEnd;
			_result = result;
			_site = site;
			_position = position;
			_technique = technique;
			_comments = comments;
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function get measuredBy():String
		{
			return _measuredBy;
		}

		public function set measuredBy(value:String):void
		{
			_measuredBy = value;
		}

		public function get dateMeasuredStart():Date
		{
			return _dateMeasuredStart;
		}

		public function set dateMeasuredStart(value:Date):void
		{
			_dateMeasuredStart = value;
		}

		public function get dateMeasuredStartValue():Number
		{
			return _dateMeasuredStart.valueOf();
		}

		public function get dateMeasuredEnd():Date
		{
			return _dateMeasuredEnd;
		}

		public function set dateMeasuredEnd(value:Date):void
		{
			_dateMeasuredEnd = value;
		}

		public function get result():ValueAndUnit
		{
			return _result;
		}

		public function set result(value:ValueAndUnit):void
		{
			_result = value;
		}

		public function get resultAsNumber():Number
		{
			return Number(result.value);
		}

		public function get site():String
		{
			return _site;
		}

		public function set site(value:String):void
		{
			_site = value;
		}

		public function get position():String
		{
			return _position;
		}

		public function set position(value:String):void
		{
			_position = value;
		}

		public function get technique():String
		{
			return _technique;
		}

		public function set technique(value:String):void
		{
			_technique = value;
		}

		public function get comments():String
		{
			return _comments;
		}

		public function set comments(value:String):void
		{
			_comments = value;
		}
	}
}
