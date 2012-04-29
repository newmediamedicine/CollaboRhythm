package collaboRhythm.plugins.foraD40b.model
{
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
		public static const HYPOGLYCEMIA:String = "Hypoglycemia";
		public static const HYPERGLYCEMIA:String = "Hyperglycemia";

		private var _fromDevice:Boolean = false;
		private var _repeatCount:int = 0;
		private var _state:String;
		private var _pushedViewCount:int = 0;

		private var _previousBloodGlucose:String = "";
		private var _bloodGlucose:String = "";

		public function BloodGlucoseHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		public function submitBloodGlucose():void
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

			scheduleItemOccurrence = null;
		}

		override public function set urlVariables(value:URLVariables):void
		{
			fromDevice = true;
			bloodGlucose = value.bloodGlucose;

			_urlVariables = value;
		}

		public function get bloodGlucose():String
		{
			return _bloodGlucose;
		}

		public function set bloodGlucose(value:String):void
		{
			_bloodGlucose = value;
		}

		public function get repeatCount():int
		{
			return _repeatCount;
		}

		public function set repeatCount(value:int):void
		{
			_repeatCount = value;
		}

		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
		}

		public function get pushedViewCount():int
		{
			return _pushedViewCount;
		}

		public function set pushedViewCount(value:int):void
		{
			_pushedViewCount = value;
		}

		public function get fromDevice():Boolean
		{
			return _fromDevice;
		}

		public function set fromDevice(value:Boolean):void
		{
			_fromDevice = value;
		}

		public function get previousBloodGlucose():String
		{
			return _previousBloodGlucose;
		}

		public function set previousBloodGlucose(value:String):void
		{
			_previousBloodGlucose = value;
		}
	}
}
