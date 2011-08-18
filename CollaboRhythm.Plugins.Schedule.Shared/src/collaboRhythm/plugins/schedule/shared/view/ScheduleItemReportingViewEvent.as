package collaboRhythm.plugins.schedule.shared.view
{

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	import flash.events.Event;

	import mx.core.UIComponent;

	public class ScheduleItemReportingViewEvent extends Event
	{
		public static const ADHERENCE_ITEM_INCOMPLETE:String = "AdherenceItemIncomplete";
		public static const ADHERENCE_ITEM_COMPLETE:String = "AdherenceItemComplete";
		public static const ADHERENCE_ITEM_VOID:String = "AdherenceItemVoid";

		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _adherenceItem:AdherenceItem;
		private var _additionalInformationView:UIComponent;
		private var _hideViews:Boolean;
		private var _createAdherenceItem:Boolean;
		private var _secondReading:Boolean;

		public function ScheduleItemReportingViewEvent(type:String, scheduleItemOccurrence:ScheduleItemOccurrence,
													   adherenceItem:AdherenceItem,
													   additionalInformationView:UIComponent = null,
													   hideViews:Boolean = true, createAdherenceItem:Boolean = true,
														secondReading:Boolean = false)
		{
			super(type, true);

			_scheduleItemOccurrence = scheduleItemOccurrence;
			_adherenceItem = adherenceItem;
			_additionalInformationView = additionalInformationView;
			_hideViews = hideViews;
			_createAdherenceItem = createAdherenceItem;
			_secondReading = secondReading;
		}

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

		public function get additionalInformationView():UIComponent
		{
			return _additionalInformationView;
		}

		public function get hideViews():Boolean
		{
			return _hideViews;
		}

		public function set hideViews(value:Boolean):void
		{
			_hideViews = value;
		}

		public function get createAdherenceItem():Boolean
		{
			return _createAdherenceItem;
		}

		public function set createAdherenceItem(value:Boolean):void
		{
			_createAdherenceItem = value;
		}

		public function get secondReading():Boolean
		{
			return _secondReading;
		}

		public function set secondReading(value:Boolean):void
		{
			_secondReading = value;
		}
	}
}