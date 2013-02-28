package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class ForaD40bHealthActionInputModelCollection extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _reportForaD40bItemDataCollection:ArrayCollection;
		private var _currentView:Class;
		private var _pushedViewCount:int = 0;
		private var _reportBloodGlucoseListScrollPosition:Number;
		private var _healthAction:ForaD40bHealthAction;
		private var _healthActionInputController:ForaD40bHealthActionInputController;
		private var _isReportingExplicit:Boolean;

		public function ForaD40bHealthActionInputModelCollection(healthAction:ForaD40bHealthAction,
																 scheduleItemOccurrence:ScheduleItemOccurrence,
																 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																 scheduleCollectionsProvider:IScheduleCollectionsProvider,
																 healthActionInputController:ForaD40bHealthActionInputController)
		{
			_healthAction = healthAction;
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider);
			_reportForaD40bItemDataCollection = new ArrayCollection();
			_healthActionInputController = healthActionInputController;
			initializeModel();
		}

		private function initializeModel():void
		{
			addHealthActionInputModel(_healthAction.isBloodGlucose);
			dateMeasuredStart = _currentDateSource.now();
		}

		public function addHealthActionInputModel(isBloodGlucose:Boolean):ReportForaD40bItemData
		{
			var healthActionInputModel:ForaD40bHealthActionInputModelBase = createHealthActionInputModel(isBloodGlucose);
			var reportForaD40bItemData:ReportForaD40bItemData = new ReportForaD40bItemData(healthActionInputModel,
					_healthActionInputController);
			_reportForaD40bItemDataCollection.addItem(reportForaD40bItemData);
			return reportForaD40bItemData;
		}

		private function createHealthActionInputModel(isBloodGlucose:Boolean):ForaD40bHealthActionInputModelBase
		{
			var healthActionInputModel:ForaD40bHealthActionInputModelBase;
			if (isBloodGlucose)
			{
				healthActionInputModel = new BloodGlucoseHealthActionInputModel(this.scheduleItemOccurrence,
						this.healthActionModelDetailsProvider, this.scheduleCollectionsProvider, this);
			}
			else
			{
				healthActionInputModel = new BloodPressureHealthActionInputModel(this.scheduleItemOccurrence,
						this.healthActionModelDetailsProvider, this.scheduleCollectionsProvider, this);
			}
			return healthActionInputModel;
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

			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem &&
					scheduleItemOccurrence.adherenceItem.adherenceResults &&
					scheduleItemOccurrence.adherenceItem.adherenceResults.length != 0)
			{
				var bloodGlucoseVitalSign:VitalSign = scheduleItemOccurrence.adherenceItem.adherenceResults[0] as
						VitalSign;
				adherenceResultDate = bloodGlucoseVitalSign.dateMeasuredStart;
			}

			return adherenceResultDate;
		}

		public function get dateMeasuredStart():Date
		{
			return firstInputModel ? firstInputModel.dateMeasuredStart : null;
		}

		public function set dateMeasuredStart(dateMeasuredStart:Date):void
		{
			if (firstInputModel)
			{
				firstInputModel.dateMeasuredStart = dateMeasuredStart;
			}
		}

		[ArrayElementType("collaboRhythm.plugins.foraD40b.model.ReportForaD40bItemData")]
		public function get reportForaD40bItemDataCollection():ArrayCollection
		{
			return _reportForaD40bItemDataCollection;
		}

		public function handleHealthActionResult():void
		{
			if (firstInputModel)
			{
				firstInputModel.handleHealthActionResult();
			}
		}

		public function get firstBloodGlucoseInputModel():BloodGlucoseHealthActionInputModel
		{
			return _reportForaD40bItemDataCollection &&
					_reportForaD40bItemDataCollection.length > 0 ? (_reportForaD40bItemDataCollection[0] as
					ReportForaD40bItemData).dataInputModel as BloodGlucoseHealthActionInputModel : null;
		}

		public function get firstBloodPressureInputModel():BloodPressureHealthActionInputModel
		{
			return _reportForaD40bItemDataCollection &&
					_reportForaD40bItemDataCollection.length > 0 ? (_reportForaD40bItemDataCollection[0] as
					ReportForaD40bItemData).dataInputModel as BloodPressureHealthActionInputModel : null;
		}

		public function get firstInputModel():ForaD40bHealthActionInputModelBase
		{
			return _reportForaD40bItemDataCollection &&
					_reportForaD40bItemDataCollection.length > 0 ? (_reportForaD40bItemDataCollection[0] as
					ReportForaD40bItemData).dataInputModel : null;
		}

		public function get lastInputModel():ForaD40bHealthActionInputModelBase
		{
			return _reportForaD40bItemDataCollection &&
					_reportForaD40bItemDataCollection.length >
							0 ? (_reportForaD40bItemDataCollection[_reportForaD40bItemDataCollection.length - 1] as
					ReportForaD40bItemData).dataInputModel : null;
		}

		public function handleHealthActionSelected():void
		{
			if (firstInputModel)
			{
				firstInputModel.handleHealthActionSelected();
			}
		}

		public function nextStep(initiatedLocally:Boolean):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.nextStep(initiatedLocally);
			}
		}

		public function startWaitTimer():void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.startWaitTimer();
			}
		}

		public function get manualBloodGlucose():String
		{
			return firstBloodGlucoseInputModel ? firstBloodGlucoseInputModel.manualBloodGlucose : null;
		}

		public function set manualBloodGlucose(manualBloodGlucose:String):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.manualBloodGlucose = manualBloodGlucose;
			}
		}

		public function get deviceBloodGlucose():String
		{
			return firstBloodGlucoseInputModel ? firstBloodGlucoseInputModel.deviceBloodGlucose : null;
		}

		public function set deviceBloodGlucose(deviceBloodGlucose:String):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.deviceBloodGlucose = deviceBloodGlucose;
				firstBloodGlucoseInputModel.isFromDevice = true;
			}
		}

		public function quitHypoglycemiaActionPlan(initiatedLocally:Boolean):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.quitHypoglycemiaActionPlan(initiatedLocally);
			}
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.addEatCarbsHealthAction(description);
			}
		}

		public function addWaitHealthAction(seconds:int):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.addWaitHealthAction(seconds);
			}
		}

		public function simpleCarbsItemList_changeHandler(selectedIndex:int):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.simpleCarbsItemList_changeHandler(selectedIndex);
			}
		}

		public function complexCarbs15gItemList_changeHandler(selectedIndex:int):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.complexCarbs15gItemList_changeHandler(selectedIndex);
			}
		}

		public function complexCarbs30gItemList_changeHandler(selectedIndex:int):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.complexCarbs30gItemList_changeHandler(selectedIndex);
			}
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return false;
		}

		public function get isReview():Boolean
		{
			return !isReportingExplicit && firstInputModel && firstInputModel.isReview;
		}

		public function synchronizeActionsListScrollerPosition(verticalScrollPosition:Number):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.actionsListScrollerPosition = verticalScrollPosition;
			}
		}

		public function setBloodGlucoseHistoryListScrollerPosition(scrollPosition:Number):void
		{
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.setBloodGlucoseHistoryListScrollerPosition(scrollPosition);
			}
		}

		public function get reportBloodGlucoseListScrollPosition():Number
		{
			return _reportBloodGlucoseListScrollPosition;
		}

		public function set reportBloodGlucoseListScrollPosition(value:Number):void
		{
			_reportBloodGlucoseListScrollPosition = value;
		}

		public function clearMeasurements():void
		{
			// Clear the existing measurements, but keep the firstBloodGlucoseInputModel so that fields regarding the hypoglycemia action plan are preserved
			if (firstBloodGlucoseInputModel)
			{
				firstBloodGlucoseInputModel.manualBloodGlucose = "";
				firstBloodGlucoseInputModel.deviceBloodGlucose = "";
				firstBloodGlucoseInputModel.dateMeasuredStart = _currentDateSource.now();
				firstBloodGlucoseInputModel.isFromDevice = false;
			}

			if (firstBloodPressureInputModel)
			{
				firstBloodPressureInputModel.previousSystolic = firstBloodPressureInputModel.systolic;
				firstBloodPressureInputModel.previousDiastolic = firstBloodPressureInputModel.diastolic;
				firstBloodPressureInputModel.previousHeartRate = firstBloodPressureInputModel.heartRate;

				firstBloodPressureInputModel.systolic = "";
				firstBloodPressureInputModel.diastolic = "";
				firstBloodPressureInputModel.heartRate = "";

				firstBloodPressureInputModel.dateMeasuredStart = _currentDateSource.now();
				firstBloodPressureInputModel.isFromDevice = false;
			}

			// Remove other measurements; they should have been persisted already, and should not appear again in a reporting view.
			// Also, we want to ensure that in ForaD40bHealthActionInputController.handleUrlVariablesNewMeasurement() isFirstFromDevice resolves to true so that
			// the value coming from the device will be displayed correctly.
			while (_reportForaD40bItemDataCollection.length > 1)
			{
				_reportForaD40bItemDataCollection.removeItemAt(_reportForaD40bItemDataCollection.length - 1);
			}
		}

		public function set isReportingExplicit(isReviewExplicit:Boolean):void
		{
			_isReportingExplicit = isReviewExplicit;
		}

		public function get isReportingExplicit():Boolean
		{
			return _isReportingExplicit;
		}

		public function abnormalBloodPressureSymptomsHandler(symptomsPresent:Boolean):void
		{
			if (firstBloodPressureInputModel)
			{
				firstBloodPressureInputModel.abnormalBloodPressureSymptomsHandler(symptomsPresent);
			}
		}

		public function quitAbnormalBloodPressureActionPlan(initiatedLocally:Boolean):void
		{
			if (firstBloodPressureInputModel)
			{
				firstBloodPressureInputModel.quitAbnormalBloodPressureActionPlan(initiatedLocally);
			}
		}
	}
}
