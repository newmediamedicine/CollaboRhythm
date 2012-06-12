package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HealthActionPlan extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents/healthActionPlan#HealthActionPlan";

		private var _name:CodedValue;
		private var _planType:String;
		private var _plannedBy:String;
		private var _datePlanned:Date;
		private var _dateExpires:Date;
		private var _indication:String;
		private var _instructions:String;
		private var _system:CodedValue;
		private var _actions:ArrayCollection;
		private var _schedules:ArrayCollection = new ArrayCollection();

		public function HealthActionPlan()
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

		public function get planType():String
		{
			return _planType;
		}

		public function set planType(value:String):void
		{
			_planType = value;
		}

		public function get plannedBy():String
		{
			return _plannedBy;
		}

		public function set plannedBy(value:String):void
		{
			_plannedBy = value;
		}

		public function get datePlanned():Date
		{
			return _datePlanned;
		}

		public function set datePlanned(value:Date):void
		{
			_datePlanned = value;
		}

		public function get dateExpires():Date
		{
			return _dateExpires;
		}

		public function set dateExpires(value:Date):void
		{
			_dateExpires = value;
		}

		public function get indication():String
		{
			return _indication;
		}

		public function set indication(value:String):void
		{
			_indication = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}

		public function get system():CodedValue
		{
			return _system;
		}

		public function set system(value:CodedValue):void
		{
			_system = value;
		}

		/**
		 * Collection of collaboRhythm.shared.model.healthRecord.document.healthActionPlan.Action (ActionStep and ActionGroup) instances
		 */
		public function get actions():ArrayCollection
		{
			return _actions;
		}

		public function set actions(value:ArrayCollection):void
		{
			_actions = value;
		}

		/**
		 * Collection of HealthActionSchedule documents which this document relates to (via healthActionSchedule
		 * relationships). This is NOT part of the document itself; this is a convenient property for accessing relationship metadata.
		 */
		public function get schedules():ArrayCollection
		{
			return _schedules;
		}

		public function set schedules(value:ArrayCollection):void
		{
			_schedules = value;
		}
	}
}
