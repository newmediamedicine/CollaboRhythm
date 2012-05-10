package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.StartHypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step1HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step2HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step3HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.foraD40b.view.Step4HypoglycemiaActionPlanView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	[Bindable]
	public class BloodGlucoseHealthActionInputModel extends HealthActionInputModelBase
	{
		public static const SEVERE_HYPOGLYCEMIA_THRESHOLD:int = 60;
		public static const HYPOGLYCEMIA_THRESHOLD:int = 70;
		public static const REPEAT_HYPOGLYCEMIA_THRESHOLD:int = 90;
		public static const HYPERGLYCEMIA_THRESHOLD:int = 200;

		public static const SEVERE_HYPOGLYCEMIA:String = "Severe Hypoglycemia";
		public static const HYPOGLYCEMIA:String = "Hypoglycemia";
		public static const NORMOGLYCEMIA:String = "Normoglycemia";
		public static const HYPERGLYCEMIA:String = "Hyperglycemia";

		private var _hypoglycemiaActionPlanIterationCount:int = 0;

		private var _manualBloodGlucose:String = "";
		private var _deviceBloodGlucose:String = "";
		private var _bloodGlucose:String = "";

		private var _invalidBloodGlucose:Boolean = false;
		private var _glycemicState:String;

		private var _currentView:Class;
		private var _pushedViewCount:int = 0;

		public static const TIMER_COUNT:int = 9;

		private var _timer:Timer;
		private var _seconds:int;

		public function BloodGlucoseHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		public function handleHealthActionResult():void
		{
			pushView(BloodGlucoseHealthActionInputView);
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			deviceBloodGlucose = urlVariables.bloodGlucose;

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

		public function updateManualBloodGlucose(text:String):void
		{
			manualBloodGlucose = text;
		}

		public function nextStep():void
		{
			if (currentView == StartHypoglycemiaActionPlanView)
			{
				pushView(Step1HypoglycemiaActionPlanView);
			}
			else if (currentView == Step1HypoglycemiaActionPlanView)
			{
				pushView(Step2HypoglycemiaActionPlanView);
			}
			else if (currentView == Step2HypoglycemiaActionPlanView)
			{
				pushView(Step3HypoglycemiaActionPlanView);
			}
			else if (currentView == Step4HypoglycemiaActionPlanView)
			{
				pushView(null);
			}
		}

		public function submitBloodGlucose(bloodGlucoseText:String):void
		{
			bloodGlucose = bloodGlucoseText;

			manualBloodGlucose = "";
			deviceBloodGlucose = "";

			saveBloodGlucose();

			if (glycemicState == HYPOGLYCEMIA || glycemicState == SEVERE_HYPOGLYCEMIA)
			{
				startHypoglycemiaActionPlan();
			}
			else
			{
				if (currentView == Step3HypoglycemiaActionPlanView)
				{
					pushView(Step4HypoglycemiaActionPlanView);
				}
				else if (currentView == BloodGlucoseHealthActionInputView)
				{
					pushView(null);
				}
			}
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

		private function saveBloodGlucose():void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var bloodGlucoseVitalSign:VitalSign = vitalSignFactory.createBloodGlucose(_currentDateSource.now(),
					bloodGlucose);

			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			results.push(bloodGlucoseVitalSign);

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, _healthActionModelDetailsProvider.record,
						_healthActionModelDetailsProvider.accountId);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					result.pendingAction = DocumentBase.ACTION_CREATE;
					_healthActionModelDetailsProvider.record.addDocument(result);
				}
			}

			_healthActionModelDetailsProvider.record.saveAllChanges();

			scheduleItemOccurrence = null;
		}

		public function startWaitTimer():void
		{
			seconds = BloodGlucoseHealthActionInputModel.TIMER_COUNT;

			timer = new Timer(1000, seconds);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}

		private function timerHandler(event:TimerEvent):void
		{
			seconds--;
		}

		override public function set urlVariables(value:URLVariables):void
		{
			bloodGlucose = value.bloodGlucose;

			_urlVariables = value;
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

		public function get bloodGlucose():String
		{
			return _bloodGlucose;
		}

		public function set bloodGlucose(value:String):void
		{
			var bloodGlucoseValue:int = int(value);
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

			_bloodGlucose = value;
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
	}
}
