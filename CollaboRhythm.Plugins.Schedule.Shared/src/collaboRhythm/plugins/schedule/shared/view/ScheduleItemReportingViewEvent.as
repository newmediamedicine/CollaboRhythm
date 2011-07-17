package collaboRhythm.plugins.schedule.shared.view
{

	import collaboRhythm.shared.model.ScheduleItemOccurrence;
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

		public function ScheduleItemReportingViewEvent(type:String, scheduleItemOccurrence:ScheduleItemOccurrence,
													   adherenceItem:AdherenceItem,
													   additionalInformationView:UIComponent = null)
		{
			super(type, true);

			_scheduleItemOccurrence = scheduleItemOccurrence;
			_adherenceItem = adherenceItem;
			_additionalInformationView = additionalInformationView;
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
	}
}