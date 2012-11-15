package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bAppController;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.StartHypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step1HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step2HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step3HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step4HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Measurement;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;

	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class BloodGlucoseHealthActionInputModel extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		private static const HYPOGLYCEMIA_ACTION_PLAN_HEALTH_ACTION_RESULT_NAME:String = "Hypoglycemia Action Plan";
		private static const EAT_CARBS_ACTION_STEP_NAME:String = "Eat Carbs";
		private static const MEASURE_BLOOD_GLUCOSE_ACTION_STEP_NAME:String = "Measure Blood Glucose";
		private static const WAIT_ACTION_STEP_NAME:String = "Wait";

		public static const SEVERE_HYPOGLYCEMIA_THRESHOLD:int = 60;
		public static const HYPOGLYCEMIA_THRESHOLD:int = 70;
		public static const REPEAT_HYPOGLYCEMIA_THRESHOLD:int = 90;
		public static const HYPERGLYCEMIA_THRESHOLD:int = 200;

		public static const SEVERE_HYPOGLYCEMIA:String = "Severe Hypoglycemia";
		public static const HYPOGLYCEMIA:String = "Hypoglycemia";
		public static const NORMOGLYCEMIA:String = "Normoglycemia";
		public static const HYPERGLYCEMIA:String = "Hyperglycemia";

		public static const FROM_DEVICE:String = "from device: ";
		public static const SELF_REPORT:String = "self report";

		private var _hypoglycemiaActionPlanIterationCount:int = 0;
		private var _hypoglycemiaActionPlanInitialBloodGlucose:VitalSign;
		private var _hypoglycemiaHealthActionResult:HealthActionResult;

		private var _manualBloodGlucose:String = "";
		private var _deviceBloodGlucose:String = "";
		private var _bloodGlucoseVitalSign:VitalSign;

		private var _invalidBloodGlucose:Boolean = false;
		private var _glycemicState:String;

		private var _currentStep:int = 0;

		public static const TIMER_COUNT:int = 15 * 60; // fifteen minutes
		public static const TIMER_STEP:int = 1000; // one second

		private var _timer:Timer = new Timer(TIMER_STEP, TIMER_COUNT);
		private var _seconds:int = TIMER_COUNT;
		private var _bloodGlucoseHistoryListScrollerPosition:Number;
		private var _simpleCarbsItemListSelectedIndex:int = -1;
		private var _complexCarbs15gItemListSelectedIndex:int = -1;
		private var _complexCarbs30gItemListSelectedIndex:int = -1;
		private var _actionsListScrollerPosition:Number;
		private var _dateMeasuredStart:Date;
		private var _bloodGlucoseHealthActionInputModelCollection:BloodGlucoseHealthActionInputModelCollection;

		public function BloodGlucoseHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   scheduleCollectionsProvider:IScheduleCollectionsProvider,
														   bloodGlucoseHealthActionInputModelCollection:BloodGlucoseHealthActionInputModelCollection)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider);
			_bloodGlucoseHealthActionInputModelCollection = bloodGlucoseHealthActionInputModelCollection;

			dateMeasuredStart = _currentDateSource.now();
		}

		public function handleHealthActionResult():void
		{
			pushView(BloodGlucoseHealthActionInputView);
		}

		public function handleHealthActionSelected():void
		{
			pushView(BloodGlucoseHealthActionInputView);
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_logger.debug("handleUrlVariables " + urlVariables.toString());

			manualBloodGlucose = "";
			deviceBloodGlucose = urlVariables.bloodGlucose;
			dateMeasuredStart = DateUtil.parseW3CDTF(urlVariables.correctedMeasuredDate);

			if (hypoglycemiaActionPlanIterationCount == 0)
			{
				if (currentView != BloodGlucoseHealthActionInputView)
				{
					pushView(BloodGlucoseHealthActionInputView);
				}
			}
			else
			{
				if (currentView != Step3HypoglycemiaActionPlanView)
				{
					pushView(Step3HypoglycemiaActionPlanView);
				}
			}

			_urlVariables = urlVariables;
		}

		public function get currentView():Class
		{
			return _bloodGlucoseHealthActionInputModelCollection.currentView;
		}

		public function set currentView(currentView:Class):void
		{
			_bloodGlucoseHealthActionInputModelCollection.currentView = currentView;
		}

		public function get pushedViewCount():int
		{
			return _bloodGlucoseHealthActionInputModelCollection.pushedViewCount;
		}

		public function set pushedViewCount(pushedViewCount:int):void
		{
			_bloodGlucoseHealthActionInputModelCollection.pushedViewCount = pushedViewCount;
		}

		public function nextStep(initiatedLocally:Boolean):void
		{
			if (currentView == StartHypoglycemiaActionPlanView)
			{
				currentStep = 1;
				pushView(Step1HypoglycemiaActionPlanView);
			}
			else if (currentView == Step1HypoglycemiaActionPlanView)
			{
				currentStep = 2;
				pushView(Step2HypoglycemiaActionPlanView);
			}
			else if (currentView == Step2HypoglycemiaActionPlanView)
			{
				currentStep = 3;
				timer.stop();
				pushView(Step3HypoglycemiaActionPlanView);
			}
			else if (currentView == Step4HypoglycemiaActionPlanView)
			{
				saveHypoglycemiaHealthActionResult(initiatedLocally);
				currentStep = 0;
				pushView(null);
			}
		}

		public function createBloodGlucoseVitalSign():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			if (deviceBloodGlucose != "")
			{
				bloodGlucoseVitalSign = vitalSignFactory.createBloodGlucose(dateMeasuredStart, deviceBloodGlucose, null,
						null, null, null, null, FROM_DEVICE + ForaD40bAppController.DEFAULT_NAME);
			}
			else if (manualBloodGlucose != "")
			{
				bloodGlucoseVitalSign = vitalSignFactory.createBloodGlucose(dateMeasuredStart, manualBloodGlucose, null,
						null, null, null, null, SELF_REPORT);
			}
		}

		public function submitBloodGlucose(bloodGlucoseVitalSign:VitalSign, initiatedLocally:Boolean):void
		{
			evaluateGlycemicState(bloodGlucoseVitalSign);

			if (glycemicState == HYPOGLYCEMIA || glycemicState == SEVERE_HYPOGLYCEMIA)
			{
				if (currentStep == 0)
				{
					_hypoglycemiaHealthActionResult = new HealthActionResult();
					_hypoglycemiaHealthActionResult.name = new CodedValue(null, null, null,
							HYPOGLYCEMIA_ACTION_PLAN_HEALTH_ACTION_RESULT_NAME);
					_hypoglycemiaHealthActionResult.reportedBy = healthActionModelDetailsProvider.accountId;
					_hypoglycemiaHealthActionResult.dateReported = _currentDateSource.now();
					_hypoglycemiaHealthActionResult.actions = new ArrayCollection();
					_hypoglycemiaActionPlanInitialBloodGlucose = bloodGlucoseVitalSign;
					_hypoglycemiaActionPlanInitialBloodGlucose.triggeredHealthActionResults.push(_hypoglycemiaHealthActionResult);
					saveBloodGlucose(initiatedLocally, _hypoglycemiaActionPlanInitialBloodGlucose);
					startHypoglycemiaActionPlan();
				}
				else
				{
					addBloodGlucoseHealthAction(bloodGlucoseVitalSign);
					if (currentStep == 1)
					{
						pushView(Step1HypoglycemiaActionPlanView);
					}
					else if (currentStep == 2)
					{
						pushView(Step2HypoglycemiaActionPlanView);
					}
					else if (currentStep == 3)
					{
						currentStep = 0;
						startHypoglycemiaActionPlan();
					}
					else if (currentStep == 4)
					{
						currentStep = 0;
						pushView(StartHypoglycemiaActionPlanView);
					}
				}
			}
			else
			{
				if (currentView == Step3HypoglycemiaActionPlanView)
				{
					addBloodGlucoseHealthAction(bloodGlucoseVitalSign);
					currentStep = 4;
					pushView(Step4HypoglycemiaActionPlanView);
				}
				else if (currentView == BloodGlucoseHealthActionInputView)
				{
					saveBloodGlucose(initiatedLocally, bloodGlucoseVitalSign);
					currentStep = 0;
					pushView(null);
				}
			}

			manualBloodGlucose = "";
			deviceBloodGlucose = "";
			dateMeasuredStart = _currentDateSource.now();
		}

		private function evaluateGlycemicState(bloodGlucoseVitalSign:VitalSign):void
		{
			var bloodGlucoseValue:Number = bloodGlucoseVitalSign.resultAsNumber;
			if (bloodGlucoseValue < SEVERE_HYPOGLYCEMIA_THRESHOLD)
			{
				glycemicState = SEVERE_HYPOGLYCEMIA;
			}
			else if ((hypoglycemiaActionPlanIterationCount == 0 && bloodGlucoseValue < HYPOGLYCEMIA_THRESHOLD) ||
					(hypoglycemiaActionPlanIterationCount > 0 && bloodGlucoseValue < REPEAT_HYPOGLYCEMIA_THRESHOLD))
			{
				glycemicState = HYPOGLYCEMIA;
			}
			else if (bloodGlucoseValue < HYPERGLYCEMIA_THRESHOLD)
			{
				glycemicState = NORMOGLYCEMIA;
			}
			else
			{
				glycemicState = HYPERGLYCEMIA;
			}
		}

		private function saveBloodGlucose(initiatedLocally:Boolean, bloodGlucoseVitalSign:VitalSign):void
		{
			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(bloodGlucoseVitalSign);

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, healthActionModelDetailsProvider.record,
						healthActionModelDetailsProvider.accountId, initiatedLocally);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					healthActionModelDetailsProvider.record.addDocument(result, initiatedLocally);
				}
			}

			if (initiatedLocally)
			{
				healthActionModelDetailsProvider.record.saveAllChanges();
			}

			scheduleItemOccurrence = null;
		}

		private function saveHypoglycemiaHealthActionResult(initiatedLocally:Boolean):void
		{
			healthActionModelDetailsProvider.record.addDocument(_hypoglycemiaHealthActionResult, initiatedLocally);

			for each (var vitalSign:VitalSign in _hypoglycemiaHealthActionResult.measurements)
			{
				healthActionModelDetailsProvider.record.addDocument(vitalSign, initiatedLocally);
				healthActionModelDetailsProvider.record.addRelationship(HealthActionResult.RELATION_TYPE_MEASUREMENT,
						_hypoglycemiaHealthActionResult, vitalSign, initiatedLocally)
			}

			healthActionModelDetailsProvider.record.addRelationship(HealthActionResult.RELATION_TYPE_TRIGGERED_HEALTH_ACTION_RESULT,
					_hypoglycemiaActionPlanInitialBloodGlucose, _hypoglycemiaHealthActionResult, initiatedLocally);

			if (initiatedLocally)
			{
				healthActionModelDetailsProvider.record.saveAllChanges();
			}
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			var occurrence:Occurrence = new Occurrence();
			occurrence.startTime = _currentDateSource.now();
			occurrence.additionalDetails = description;

			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CodedValue(null, null, null, EAT_CARBS_ACTION_STEP_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			actionStepResult.occurrences.addItem(occurrence);

			_hypoglycemiaHealthActionResult.actions.addItem(actionStepResult);
		}

		public function addBloodGlucoseHealthAction(vitalSign:VitalSign):void
		{
			var measurement:Measurement = new Measurement();
			measurement.name = vitalSign.name;
			measurement.value = vitalSign.result.clone();

			var occurrence:Occurrence = new Occurrence();
			occurrence.startTime = vitalSign.dateMeasuredStart;
			occurrence.endTime = vitalSign.dateMeasuredEnd;
			occurrence.measurements = new ArrayCollection();
			occurrence.measurements.addItem(measurement);

			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CodedValue(null, null, null, MEASURE_BLOOD_GLUCOSE_ACTION_STEP_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			actionStepResult.occurrences.addItem(occurrence);

			_hypoglycemiaHealthActionResult.actions.addItem(actionStepResult);
			_hypoglycemiaHealthActionResult.measurements.push(vitalSign);
		}

		public function addWaitHealthAction(seconds:int):void
		{
			var wait:int = TIMER_COUNT - seconds;
			var minutes:int = Math.floor(wait / 60);
			var seconds:int = wait % 60;

			var secondsString:String;
			if (seconds < 10)
			{
				secondsString = "0" + seconds.toString();
			}
			else
			{
				secondsString = seconds.toString();
			}

			var occurrence:Occurrence = new Occurrence();
			occurrence.startTime = _currentDateSource.now();
			occurrence.additionalDetails = "Waited " + minutes + ":" + secondsString;

			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CodedValue(null, null, null, WAIT_ACTION_STEP_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			actionStepResult.occurrences.addItem(occurrence);

			_hypoglycemiaHealthActionResult.actions.addItem(actionStepResult);
		}

		private function startHypoglycemiaActionPlan():void
		{
			hypoglycemiaActionPlanIterationCount++;
			pushView(StartHypoglycemiaActionPlanView);
		}

		private function pushView(view:Class):void
		{
			currentView = view;
			if (view != null)
			{
				pushedViewCount += 1;
			}
		}

		public function startWaitTimer():void
		{
			if (!timer.running)
			{
				seconds = TIMER_COUNT;

				timer = new Timer(1000, TIMER_COUNT);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
			}
		}

		private function timerHandler(event:TimerEvent):void
		{
			seconds--;
		}

		public function quitHypoglycemiaActionPlan(initiatedLocally:Boolean):void
		{
			saveHypoglycemiaHealthActionResult(initiatedLocally);
			pushView(null);
		}

		public function get manualBloodGlucose():String
		{
			return _manualBloodGlucose;
		}

		public function set manualBloodGlucose(value:String):void
		{
			_manualBloodGlucose = value;
		}

		public function get deviceBloodGlucose():String
		{
			return _deviceBloodGlucose;
		}

		public function set deviceBloodGlucose(value:String):void
		{
			_deviceBloodGlucose = value;
		}

		public function get glycemicState():String
		{
			return _glycemicState;
		}

		public function set glycemicState(value:String):void
		{
			_glycemicState = value;
		}

		public function get hypoglycemiaActionPlanIterationCount():int
		{
			return _hypoglycemiaActionPlanIterationCount;
		}

		public function set hypoglycemiaActionPlanIterationCount(value:int):void
		{
			_hypoglycemiaActionPlanIterationCount = value;
		}

		public function get currentStep():int
		{
			return _currentStep;
		}

		public function set currentStep(value:int):void
		{
			_currentStep = value;
		}

		public function get timer():Timer
		{
			return _timer;
		}

		public function set timer(value:Timer):void
		{
			_timer = value;
		}

		public function get seconds():int
		{
			return _seconds;
		}

		public function set seconds(value:int):void
		{
			_seconds = value;
		}

		public function get invalidBloodGlucose():Boolean
		{
			return _invalidBloodGlucose;
		}

		public function set invalidBloodGlucose(value:Boolean):void
		{
			_invalidBloodGlucose = value;
		}

		public function setBloodGlucoseHistoryListScrollerPosition(scrollPosition:Number):void
		{
			bloodGlucoseHistoryListScrollerPosition = scrollPosition;
		}

		public function get bloodGlucoseHistoryListScrollerPosition():Number
		{
			return _bloodGlucoseHistoryListScrollerPosition;
		}

		public function set bloodGlucoseHistoryListScrollerPosition(value:Number):void
		{
			_bloodGlucoseHistoryListScrollerPosition = value;
		}

		public function simpleCarbsItemList_changeHandler(selectedIndex:int):void
		{
			simpleCarbsItemListSelectedIndex = selectedIndex;
		}

		public function get simpleCarbsItemListSelectedIndex():int
		{
			return _simpleCarbsItemListSelectedIndex;
		}

		public function set simpleCarbsItemListSelectedIndex(value:int):void
		{
			_simpleCarbsItemListSelectedIndex = value;
		}

		public function complexCarbs15gItemList_changeHandler(selectedIndex:int):void
		{
			complexCarbs15gItemListSelectedIndex = selectedIndex;

			if (selectedIndex != -1)
			{
				complexCarbs30gItemListSelectedIndex = -1;
			}
		}

		public function complexCarbs30gItemList_changeHandler(selectedIndex:int):void
		{
			complexCarbs30gItemListSelectedIndex = selectedIndex;

			if (selectedIndex != -1)
			{
				complexCarbs15gItemListSelectedIndex = -1;
			}
		}

		public function get complexCarbs15gItemListSelectedIndex():int
		{
			return _complexCarbs15gItemListSelectedIndex;
		}

		public function set complexCarbs15gItemListSelectedIndex(value:int):void
		{
			_complexCarbs15gItemListSelectedIndex = value;
		}

		public function get complexCarbs30gItemListSelectedIndex():int
		{
			return _complexCarbs30gItemListSelectedIndex;
		}

		public function set complexCarbs30gItemListSelectedIndex(value:int):void
		{
			_complexCarbs30gItemListSelectedIndex = value;
		}

		public function synchronizeActionsListScrollerPosition(verticalScrollPosition:Number):void
		{
			actionsListScrollerPosition = verticalScrollPosition;
		}

		public function get actionsListScrollerPosition():Number
		{
			return _actionsListScrollerPosition;
		}

		public function set actionsListScrollerPosition(value:Number):void
		{
			_actionsListScrollerPosition = value;
		}

		public function get dateMeasuredStart():Date
		{
			return _dateMeasuredStart;
		}

		public function set dateMeasuredStart(dateMeasuredStart:Date):void
		{
			_dateMeasuredStart = dateMeasuredStart;
		}

		public function get bloodGlucoseVitalSign():VitalSign
		{
			return _bloodGlucoseVitalSign;
		}

		public function set bloodGlucoseVitalSign(value:VitalSign):void
		{
			_bloodGlucoseVitalSign = value;
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

		public function get isFromDevice():Boolean
		{
			return deviceBloodGlucose != null && deviceBloodGlucose != "";
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return !isFromDevice;
		}

		public function get bloodGlucoseHealthActionInputModelCollection():BloodGlucoseHealthActionInputModelCollection
		{
			return _bloodGlucoseHealthActionInputModelCollection;
		}

		override public function getPossibleScheduleItemOccurrences():Vector.<ScheduleItemOccurrence>
		{
			return getMatchingScheduleItemOccurrencesInWindow(DateUtil.MILLISECONDS_IN_DAY / 2,
					DateUtil.MILLISECONDS_IN_DAY / 2, false);
		}

		private function getMatchingScheduleItemOccurrencesInWindow(windowStartOffset:Number, windowEndOffset:Number,
																	intersect:Boolean):Vector.<ScheduleItemOccurrence>
		{
			var windowStart:Date = new Date(dateMeasuredStart.valueOf() - windowStartOffset);
			var windowEnd:Date = new Date(dateMeasuredStart.valueOf() + windowEndOffset);

			var occurrences:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var schedule:HealthActionSchedule in
					_healthActionModelDetailsProvider.record.healthActionSchedulesModel.healthActionScheduleCollection)
			{
				if (ForaD40bHealthActionListViewAdapterFactory.isForBloodGlucose(schedule))
				{
					for each (var occurrence:ScheduleItemOccurrence in
							schedule.getScheduleItemOccurrences(windowStart, windowEnd, intersect))
					{
						occurrences.push(occurrence);
					}
				}
			}
			return occurrences;
		}

		public function guessScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = getMatchingScheduleItemOccurrencesInWindow(0,
					0, true);
			for each (var matchingOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
			{
				if (matchingOccurrence.adherenceItem == null || scheduleItemOccurrence.adherenceItem.pendingAction == DocumentBase.ACTION_CREATE)
				{
					return matchingOccurrence;
				}
			}
			return null;
		}
	}
}
