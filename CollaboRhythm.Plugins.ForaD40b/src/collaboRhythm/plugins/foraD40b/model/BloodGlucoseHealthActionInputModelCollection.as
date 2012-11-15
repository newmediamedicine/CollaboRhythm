package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.BloodGlucoseHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class BloodGlucoseHealthActionInputModelCollection extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _reportBloodGlucoseItemDataCollection:ArrayCollection;
		private var _currentView:Class;
		private var _pushedViewCount:int = 0;

		public function BloodGlucoseHealthActionInputModelCollection(scheduleItemOccurrence:ScheduleItemOccurrence,
																	 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																	 scheduleCollectionsProvider:IScheduleCollectionsProvider,
																	 bloodGlucoseHealthActionInputController:BloodGlucoseHealthActionInputController)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider);
			_reportBloodGlucoseItemDataCollection = new ArrayCollection();
			var bloodGlucoseHealthActionInputModel:BloodGlucoseHealthActionInputModel = new BloodGlucoseHealthActionInputModel(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider, this);
			var reportBloodGlucoseItemData:ReportBloodGlucoseItemData = new ReportBloodGlucoseItemData(bloodGlucoseHealthActionInputModel, bloodGlucoseHealthActionInputController);
			_reportBloodGlucoseItemDataCollection.addItem(reportBloodGlucoseItemData);

			dateMeasuredStart = _currentDateSource.now();
		}

		public function get currentView():Class
		{
			return _currentView;
		}

		public function set currentView(value:Class):void
		{
			_currentView = value;
		}

		public function get pushedViewCount():int
		{
			return _pushedViewCount;
		}

		public function set pushedViewCount(value:int):void
		{
			_pushedViewCount = value;
		}

		public function get adherenceResultDate():Date
		{
			var adherenceResultDate:Date;

			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem && scheduleItemOccurrence.adherenceItem.adherenceResults && scheduleItemOccurrence.adherenceItem.adherenceResults.length != 0)
			{
				var bloodGlucoseVitalSign:VitalSign = scheduleItemOccurrence.adherenceItem.adherenceResults[0] as VitalSign;
				adherenceResultDate = bloodGlucoseVitalSign.dateMeasuredStart;
			}

			return adherenceResultDate;
		}

		public function get dateMeasuredStart():Date
		{
			return firstInputModel.dateMeasuredStart;
		}

		public function set dateMeasuredStart(dateMeasuredStart:Date):void
		{
			firstInputModel.dateMeasuredStart = dateMeasuredStart;
		}

		[ArrayElementType("collaboRhythm.plugins.foraD40b.model.ReportBloodGlucoseItemData")]
		public function get reportBloodGlucoseItemDataCollection():ArrayCollection
		{
			return _reportBloodGlucoseItemDataCollection;
		}

		public function handleHealthActionResult():void
		{
			firstInputModel.handleHealthActionResult();
		}

		public function get firstInputModel():BloodGlucoseHealthActionInputModel
		{
			return _reportBloodGlucoseItemDataCollection &&
					_reportBloodGlucoseItemDataCollection.length > 0 ? _reportBloodGlucoseItemDataCollection[0].dataInputModel : null;
		}

		public function get lastInputModel():BloodGlucoseHealthActionInputModel
		{
			return _reportBloodGlucoseItemDataCollection &&
					_reportBloodGlucoseItemDataCollection.length > 0 ? _reportBloodGlucoseItemDataCollection[_reportBloodGlucoseItemDataCollection.length - 1].dataInputModel : null;
		}

		public function handleHealthActionSelected():void
		{
			firstInputModel.handleHealthActionSelected();
		}

		public function nextStep(initiatedLocally:Boolean):void
		{
			firstInputModel.nextStep(initiatedLocally);
		}

		public function createBloodGlucoseVitalSign():void
		{
			firstInputModel.createBloodGlucoseVitalSign();
		}

		public function get bloodGlucoseVitalSign():VitalSign
		{
			return firstInputModel.bloodGlucoseVitalSign;
		}

		public function submitBloodGlucose(bloodGlucoseVitalSign:VitalSign, initiatedLocally:Boolean):void
		{
			firstInputModel.submitBloodGlucose(bloodGlucoseVitalSign, initiatedLocally);
		}

		public function startWaitTimer():void
		{
			firstInputModel.startWaitTimer();
		}

		public function get manualBloodGlucose():String
		{
			return firstInputModel.manualBloodGlucose;
		}

		public function set manualBloodGlucose(manualBloodGlucose:String):void
		{
			firstInputModel.manualBloodGlucose = manualBloodGlucose;
		}

		public function get deviceBloodGlucose():String
		{
			return firstInputModel.deviceBloodGlucose;
		}

		public function set deviceBloodGlucose(deviceBloodGlucose:String):void
		{
			firstInputModel.deviceBloodGlucose = deviceBloodGlucose;
		}

		public function quitHypoglycemiaActionPlan(initiatedLocally:Boolean):void
		{
			firstInputModel.quitHypoglycemiaActionPlan(initiatedLocally);
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			firstInputModel.addEatCarbsHealthAction(description);
		}

		public function addWaitHealthAction(seconds:int):void
		{
			firstInputModel.addWaitHealthAction(seconds);
		}

		public function setBloodGlucoseHistoryListScrollerPosition(scrollPosition:Number):void
		{
			firstInputModel.setBloodGlucoseHistoryListScrollerPosition(scrollPosition);
		}

		public function get bloodGlucoseHistoryListScrollerPosition():Number
		{
			return firstInputModel.bloodGlucoseHistoryListScrollerPosition;
		}

		public function set bloodGlucoseHistoryListScrollerPosition(value:Number):void
		{
			firstInputModel.bloodGlucoseHistoryListScrollerPosition = value;
		}

		public function simpleCarbsItemList_changeHandler(selectedIndex:int):void
		{
			firstInputModel.simpleCarbsItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs15gItemList_changeHandler(selectedIndex:int):void
		{
			firstInputModel.complexCarbs15gItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs30gItemList_changeHandler(selectedIndex:int):void
		{
			firstInputModel.complexCarbs30gItemList_changeHandler(selectedIndex);
		}

		public function synchronizeActionsListScrollerPosition(verticalScrollPosition:Number):void
		{
			firstInputModel.synchronizeActionsListScrollerPosition(verticalScrollPosition);
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return false;
		}
	}
}
