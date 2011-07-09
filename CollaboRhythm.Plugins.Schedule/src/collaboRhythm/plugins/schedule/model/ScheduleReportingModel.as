package collaboRhythm.plugins.schedule.model
{

	import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;
	import collaboRhythm.plugins.schedule.shared.model.PendingAdherenceItem;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.shared.model.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;

	[Bindable]
	public class ScheduleReportingModel implements IScheduleReportingModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _currentScheduleItemOccurrence:ScheduleItemOccurrence;
		private var _viewStack:ArrayCollection = new ArrayCollection();
		private var _isReportingCompleted:Boolean = false;
		private var _scheduleItemDocumentId:String;
		private var _adherenceResultDocument:XML;
		private var _currentScheduleGroup:ScheduleGroup;
		private var _pendingAdherenceItem:PendingAdherenceItem;
		private var _currentDateSource:ICurrentDateSource;

		public function ScheduleReportingModel(scheduleModel:ScheduleModel)
		{
			_scheduleModel = scheduleModel;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
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
			viewStack.removeAll();
			_scheduleModel.createAdherenceItem(scheduleItemOccurrence, adherenceItem);
//            scheduleItemOccurrence.adherenceItem = adherenceItem;

//            _scheduleItemDocumentId = scheduleItemOccurrence.scheduleItem.id;
//            var adherenceItemDocument:XML = adherenceItem.convertToXML();
//            if (adherenceItem.adherenceResult)
//            {
//                _adherenceResultDocument = adherenceItem.adherenceResult.convertToXML();
//                _phaHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, createDocumentCompleteHandler);
//                _phaHealthRecordService.createDocument(_record, adherenceItemDocument);
//            }
//            else
//            {
//                _phaHealthRecordService.relateNewDocument(_record, _scheduleItemDocumentId, adherenceItemDocument, "adherenceItem");
//            }


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

		public function createPendingAdherenceItem(urlVariables:URLVariables):PendingAdherenceItem
		{
			var pendingAdherenceItem:PendingAdherenceItem;

			var name:String = urlVariables.name;
			var success:Boolean = (urlVariables.success == "true");
			if (success)
			{
				var closestScheduleItemOccurrence:ScheduleItemOccurrence = findClosestScheduleItemOccurrence(name);
				if (closestScheduleItemOccurrence)
				{
					var parentScheduleGroup:ScheduleGroup;
					for each (var scheduleGroup:ScheduleGroup in _scheduleModel.scheduleGroupsCollection)
					{
						for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
						{
							if (closestScheduleItemOccurrence == scheduleItemOccurrence)
							{
								parentScheduleGroup = scheduleGroup;
							}
						}
					}
					var adherenceItem:AdherenceItem = new AdherenceItem();
					var nameCodedValue:CodedValue = new CodedValue();
					nameCodedValue.text = name;
					//TODO: add vital sign
					adherenceItem.init(nameCodedValue, "rpoole@records.media.mit.edu", _currentDateSource.now(),
									   closestScheduleItemOccurrence.recurrenceIndex, true);
					pendingAdherenceItem = new PendingAdherenceItem(parentScheduleGroup, closestScheduleItemOccurrence,
																	adherenceItem);
					this.pendingAdherenceItem = pendingAdherenceItem;
				}
			}
			else
			{
				//TODO: on failed reading, give the user feedback to repeat, toggle bluetooth, etc.
			}
			return pendingAdherenceItem;
		}

		public function findClosestScheduleItemOccurrence(name:String):ScheduleItemOccurrence
		{
			var closestScheduleItemOccurrence:ScheduleItemOccurrence;
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in _scheduleModel.scheduleItemOccurrencesHashMap)
			{
				if (scheduleItemOccurrence.scheduleItem.name.text == name)
				{
					if (_currentDateSource.now() > scheduleItemOccurrence.dateStart && _currentDateSource.now() < scheduleItemOccurrence.dateEnd)
					{
						closestScheduleItemOccurrence = scheduleItemOccurrence;
						break;
					}
					else
					{
						if (closestScheduleItemOccurrence)
						{
							if ((_currentDateSource.now().time - scheduleItemOccurrence.dateEnd.time < _currentDateSource.now().time - closestScheduleItemOccurrence.dateEnd.time)
									|| (scheduleItemOccurrence.dateStart.time - _currentDateSource.now().time < closestScheduleItemOccurrence.dateStart.time - _currentDateSource.now().time))
							{
								closestScheduleItemOccurrence = scheduleItemOccurrence;
							}
						}
						else
						{
							closestScheduleItemOccurrence = scheduleItemOccurrence;
						}
					}
				}
			}
			return closestScheduleItemOccurrence;
		}

//        private function createDocumentCompleteHandler(event:HealthRecordServiceEvent):void
//        {
//            _phaHealthRecordService.relateDocuments(_record, _scheduleItemDocumentId, event.responseXml.@id,
//                                                    "adherenceItem");
//            _phaHealthRecordService.relateNewDocument(_record, event.responseXml.@id, _adherenceResultDocument,
//                                                      "adherenceResult");
//        }

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

		public function get pendingAdherenceItem():PendingAdherenceItem
		{
			return _pendingAdherenceItem;
		}

		public function set pendingAdherenceItem(value:PendingAdherenceItem):void
		{
			_pendingAdherenceItem = value;
		}

		public function get currentScheduleGroup():ScheduleGroup
		{
			return _currentScheduleGroup;
		}

		public function set currentScheduleGroup(value:ScheduleGroup):void
		{
			_currentScheduleGroup = value;
		}
	}
}
