package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.EatView;
	import collaboRhythm.plugins.foraD40b.view.WaitView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

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

		private var _deviceBloodGlucose:String = "";

		private var _bloodGlucose:String = "";
		private var _glycemicState:String;
		private var _repeatCount:int = 0;

		private var _currentView:Class;
		private var _pushedViewCount:int = 0;

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

			if ((currentView == EatView || currentView == WaitView) && (glycemicState == SEVERE_HYPOGLYCEMIA || glycemicState == HYPOGLYCEMIA))
			{
//				pushView(PrematureBloodGlucosePopUp);
			}
			else if (currentView != BloodGlucoseHealthActionInputView)
			{
				pushView(BloodGlucoseHealthActionInputView);
			}

			_urlVariables = urlVariables;
		}

		public function submitBloodGlucose(bloodGlucose:String):void
		{
			this.bloodGlucose = bloodGlucose;

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

			if (glycemicState == HYPOGLYCEMIA || glycemicState == SEVERE_HYPOGLYCEMIA)
			{
				pushView(EatView);
			}
			else
			{
				currentView = null;
			}

			deviceBloodGlucose = "";
			repeatCount += 1;
		}

		private function pushView(view:Class):void
		{
			currentView = view;
			pushedViewCount += 1;
		}

		public function pushWaitView():void
		{
			pushView(WaitView);
		}

		override public function set urlVariables(value:URLVariables):void
		{
			bloodGlucose = value.bloodGlucose;

			_urlVariables = value;
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
			else if ((repeatCount == 0 && bloodGlucoseValue < HYPOGLYCEMIA_THRESHOLD) ||
					(repeatCount > 0 && bloodGlucoseValue < REPEAT_HYPOGLYCEMIA_THRESHOLD))
			{
				glycemicState =  HYPOGLYCEMIA;
			}
			else if (bloodGlucoseValue < HYPERGLYCEMIA_THRESHOLD)
			{
				glycemicState =  NORMOGLYCEMIA;
			}
			else
			{
				glycemicState =  HYPERGLYCEMIA;
			}

			_bloodGlucose = value;
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

		public function get repeatCount():int
		{
			return _repeatCount;
		}

		public function set repeatCount(value:int):void
		{
			_repeatCount = value;
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
	}
}
