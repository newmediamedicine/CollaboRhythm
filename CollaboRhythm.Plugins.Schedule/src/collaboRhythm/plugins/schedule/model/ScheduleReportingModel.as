package collaboRhythm.plugins.schedule.model
{

    import collaboRhythm.shared.model.AdherenceItem;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;

    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;

    [Bindable]
    public class ScheduleReportingModel
    {
        private var _currentScheduleItemOccurrence:ScheduleItemOccurrence;
        private var _viewStack:ArrayCollection = new ArrayCollection();
        private var _isReportingCompleted:Boolean = false;

        public function ScheduleReportingModel()
        {

        }

        public function get currentScheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _currentScheduleItemOccurrence;
        }

        public function set currentScheduleItemOccurrence(value:ScheduleItemOccurrence):void
        {
            _currentScheduleItemOccurrence = value;
        }

        public function get viewStack():ArrayCollection
        {
            return _viewStack;
        }

        public function set viewStack(value:ArrayCollection):void
        {
            _viewStack = value;
        }

        public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence, adherenceItem:AdherenceItem):void
		{
			scheduleItemOccurrence.adherenceItem = adherenceItem;
            viewStack.removeAll();
			var isReportingCompletedCheck:Boolean = true;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
			{
				if (!scheduleItemOccurrence.adherenceItem)
				{
					isReportingCompletedCheck = false;
				}
			}
			if (isReportingCompletedCheck)
			{
				isReportingCompleted = true;
			}
		}

        public function showAdditionalInformationView(additionalInformationView:UIComponent):void
        {
            viewStack.addItem(additionalInformationView);
        }

        public function get isReportingCompleted():Boolean
        {
            return _isReportingCompleted;
        }

        public function set isReportingCompleted(value:Boolean):void
        {
            _isReportingCompleted = value;
        }
    }
}
