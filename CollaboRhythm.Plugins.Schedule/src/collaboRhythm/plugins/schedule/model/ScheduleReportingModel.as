package collaboRhythm.plugins.schedule.model
{

    import collaboRhythm.shared.model.AdherenceItem;
    import collaboRhythm.shared.model.Record;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
    import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;

    [Bindable]
    public class ScheduleReportingModel
    {
        private var _phaHealthRecordService:PhaHealthRecordServiceBase;
        private var _record:Record;
        private var _currentScheduleItemOccurrence:ScheduleItemOccurrence;
        private var _viewStack:ArrayCollection = new ArrayCollection();
        private var _isReportingCompleted:Boolean = false;
        private var _scheduleItemDocumentId:String;
        private var _adherenceResultDocument:XML;

        public function ScheduleReportingModel(phaHealthRecordService:PhaHealthRecordServiceBase, record:Record)
        {
            _phaHealthRecordService = phaHealthRecordService;
            _record = record;
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

        public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence,
                                            adherenceItem:AdherenceItem):void
        {
            scheduleItemOccurrence.adherenceItem = adherenceItem;
            viewStack.removeAll();
            _scheduleItemDocumentId = scheduleItemOccurrence.scheduleItem.id;
            var adherenceItemDocument:XML = adherenceItem.convertToXML();
            if (adherenceItem.adherenceResult)
            {
                _adherenceResultDocument = adherenceItem.adherenceResult.convertToXML();
                _phaHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, createDocumentCompleteHandler);
                _phaHealthRecordService.createDocument(_record, adherenceItemDocument);
            }
            else
            {
                _phaHealthRecordService.relateNewDocument(_record, _scheduleItemDocumentId, adherenceItemDocument, "adherenceItem");
            }


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

        private function createDocumentCompleteHandler(event:HealthRecordServiceEvent):void
        {
            _phaHealthRecordService.relateDocuments(_record, _scheduleItemDocumentId, event.responseXml.@id, "adherenceItem");
            _phaHealthRecordService.relateNewDocument(_record, event.responseXml.@id, _adherenceResultDocument, "adherenceResult");
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
