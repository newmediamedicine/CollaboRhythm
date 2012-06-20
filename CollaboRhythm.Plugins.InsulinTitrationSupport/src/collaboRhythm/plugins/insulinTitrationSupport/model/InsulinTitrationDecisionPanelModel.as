package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;

	import mx.binding.utils.BindingUtils;

	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	[Bindable]
	public class InsulinTitrationDecisionPanelModel
	{
		public static const STEP_SATISFIED:String = "satisfied";
		public static const STEP_STOP:String = "stop";
		public static const STEP_PREVIOUS_STOP:String = "previous stop";

		private var _isAverageAvailable:Boolean = true;
		private var _dosageChangeValue:Number;
		private var _isAdherencePerfect:Boolean = true;
		private var _algorithmSuggestsIncreaseDose:Boolean = true;
		private var _algorithmSuggestsNoChangeDose:Boolean;
		private var _algorithmSuggestsDecreaseDose:Boolean;
		private const _dosageIncreaseText:String = "+3";
		private const _dosageDecreaseText:String = "-3";
		private var _isChangeSpecified:Boolean;
		private var _step1State:String;
		private var _step2State:String;
		private var _step3State:String;
		private var _bloodGlucoseAverage:Number;
		private var _verticalAxisMinimum:Number;
		private var _verticalAxisMaximum:Number;
		private var _goalZoneMinimum:Number;
		private var _goalZoneMaximum:Number;
		private var _goalZoneColor:uint;
		private var _chartModelDetails:IChartModelDetails;
		private var _isInitialized:Boolean;

		public function InsulinTitrationDecisionPanelModel(chartModelDetails:IChartModelDetails)
		{
			this.chartModelDetails = chartModelDetails;
			updateBloodGlucoseAverage();
		}

		private function updateBloodGlucoseAverage():void
		{
			bloodGlucoseAverage = getBloodGlucoseAverage();
			updateStep1State();
		}

		public function get isAverageAvailable():Boolean
		{
			return _isAverageAvailable;
		}

		public function set isAverageAvailable(value:Boolean):void
		{
			_isAverageAvailable = value;
			updateStep1State();
		}

		private function updateStep1State():void
		{
			step1State = isAverageAvailable ? STEP_SATISFIED : STEP_STOP;
			updateStep2State();
		}

		private function updateStep2State():void
		{
			step2State = step1State == STEP_SATISFIED ? (isAdherencePerfect ? STEP_SATISFIED : STEP_STOP) : STEP_PREVIOUS_STOP;
			updateStep3State();
		}

		private function updateStep3State():void
		{
			step3State = step2State == STEP_SATISFIED ? (isChangeSpecified ? STEP_SATISFIED : STEP_STOP) : STEP_PREVIOUS_STOP;
		}

		public function get isChangeSpecified():Boolean
		{
			return _isChangeSpecified;
		}

		public function get dosageChangeValue():Number
		{
			return _dosageChangeValue;
		}

		public function set dosageChangeValue(value:Number):void
		{
			_dosageChangeValue = value;
			isChangeSpecified = !isNaN(_dosageChangeValue);
		}

		public function get isAdherencePerfect():Boolean
		{
			return _isAdherencePerfect;
		}

		public function set isAdherencePerfect(value:Boolean):void
		{
			_isAdherencePerfect = value;
			updateStep2State();
		}

		public function get algorithmSuggestsIncreaseDose():Boolean
		{
			return _algorithmSuggestsIncreaseDose;
		}

		public function set algorithmSuggestsIncreaseDose(value:Boolean):void
		{
			_algorithmSuggestsIncreaseDose = value;
		}

		public function get algorithmSuggestsNoChangeDose():Boolean
		{
			return _algorithmSuggestsNoChangeDose;
		}

		public function set algorithmSuggestsNoChangeDose(value:Boolean):void
		{
			_algorithmSuggestsNoChangeDose = value;
		}

		public function get algorithmSuggestsDecreaseDose():Boolean
		{
			return _algorithmSuggestsDecreaseDose;
		}

		public function set algorithmSuggestsDecreaseDose(value:Boolean):void
		{
			_algorithmSuggestsDecreaseDose = value;
		}

		public function get dosageIncreaseText():String
		{
			return _dosageIncreaseText;
		}

		public function get dosageDecreaseText():String
		{
			return _dosageDecreaseText;
		}

		public function set isChangeSpecified(value:Boolean):void
		{
			_isChangeSpecified = value;
			updateStep3State();
		}

		public function get step1State():String
		{
			return _step1State;
		}

		public function set step1State(value:String):void
		{
			_step1State = value;
		}

		public function get step2State():String
		{
			return _step2State;
		}

		public function set step2State(value:String):void
		{
			_step2State = value;
		}

		public function get step3State():String
		{
			return _step3State;
		}

		public function set step3State(value:String):void
		{
			_step3State = value;
		}

		public function get bloodGlucoseAverage():Number
		{
			return _bloodGlucoseAverage;
		}

		public function set bloodGlucoseAverage(value:Number):void
		{
			_bloodGlucoseAverage = value;
			updateAlgorithmSuggestions();
		}

		private function updateAlgorithmSuggestions():void
		{
			algorithmSuggestsIncreaseDose = algorithmValuesAvailable() && bloodGlucoseAverage > goalZoneMaximum;
			algorithmSuggestsNoChangeDose = algorithmValuesAvailable() && bloodGlucoseAverage <= goalZoneMaximum && bloodGlucoseAverage >= goalZoneMinimum;
			algorithmSuggestsDecreaseDose = algorithmValuesAvailable() && bloodGlucoseAverage < goalZoneMinimum;
		}

		private function algorithmValuesAvailable():Boolean
		{
			return !isNaN(bloodGlucoseAverage) && !isNaN(goalZoneMinimum) && !isNaN(goalZoneMaximum);
		}

		public function get verticalAxisMinimum():Number
		{
			return _verticalAxisMinimum;
		}

		public function set verticalAxisMinimum(value:Number):void
		{
			_verticalAxisMinimum = value;
		}

		public function get verticalAxisMaximum():Number
		{
			return _verticalAxisMaximum;
		}

		public function set verticalAxisMaximum(value:Number):void
		{
			_verticalAxisMaximum = value;
		}

		public function get goalZoneMinimum():Number
		{
			return _goalZoneMinimum;
		}

		public function set goalZoneMinimum(value:Number):void
		{
			_goalZoneMinimum = value;
			updateAlgorithmSuggestions();
		}

		public function get goalZoneMaximum():Number
		{
			return _goalZoneMaximum;
		}

		public function set goalZoneMaximum(value:Number):void
		{
			_goalZoneMaximum = value;
			updateAlgorithmSuggestions();
		}

		public function get goalZoneColor():uint
		{
			return _goalZoneColor;
		}

		public function set goalZoneColor(value:uint):void
		{
			_goalZoneColor = value;
		}

		private function getBloodGlucoseAverage():Number
		{
			var bloodGlucoseArrayCollection:ArrayCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(VitalSignsModel.BLOOD_GLUCOSE_CATEGORY);
			var bloodGlucoseSum:Number = 0;
			var bloodGlucoseCount:int = 0;
			if (bloodGlucoseArrayCollection && bloodGlucoseArrayCollection.length > 0)
			{
				var i:int = 0; // index from 0 = last item in array collection backwards through the data
				var stillEligible:Boolean = true;
				while (bloodGlucoseCount < 3 && bloodGlucoseArrayCollection.length - 1 - i >= 0 && stillEligible)
				{
					var bloodGlucose:VitalSign = bloodGlucoseArrayCollection[bloodGlucoseArrayCollection.length - 1 -
							i];
					if (eligibleForAverage(bloodGlucose))
					{
						bloodGlucoseSum += bloodGlucose.resultAsNumber;
						bloodGlucoseCount++;
					}
					else
					{
						stillEligible = false;
					}

					i++;
				}
			}

			var average:Number = NaN;
			if (bloodGlucoseCount > 0)
				average = bloodGlucoseSum / bloodGlucoseCount;
			return average;
		}

		/**
		 * Fora blood glucose measurement to eligible for determining the average for the algorightm:
		 * 	1) it must be the first measurement taken in the day
		 * 	2) it must be taken before eating breakfast (preprandial)
		 * 	3) it must fall within a window of time including today and the three days prior to today (four day window)
		 * @param bloodGlucose
		 * @return
		 */
		private function eligibleForAverage(bloodGlucose:VitalSign):Boolean
		{
			// TODO: implement more robustly
			return true;
		}

		public function get chartModelDetails():IChartModelDetails
		{
			return _chartModelDetails;
		}

		public function set chartModelDetails(value:IChartModelDetails):void
		{
			this.isInitialized = false;
			_chartModelDetails = value;

			BindingUtils.bindSetter(vitalSignModel_isInitialized_setterHandler, chartModelDetails.record.vitalSignsModel,
									"isInitialized");
		}

		private function vitalSignModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
			{
				var vitalSignsBloodGlucose:ArrayCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.BLOOD_GLUCOSE_CATEGORY];
				if (vitalSignsBloodGlucose)
				{
					vitalSignsBloodGlucose.addEventListener(CollectionEvent.COLLECTION_CHANGE,
														vitalSignsDocuments_collectionChangeEvent);
				}
			}
			this.isInitialized = determineIsInitialized();
		}

		private function determineIsInitialized():Boolean
		{
			return (chartModelDetails && chartModelDetails.record.vitalSignsModel.isInitialized);
		}

		private function vitalSignsDocuments_collectionChangeEvent(event:CollectionEvent):void
		{
			if (chartModelDetails.record.vitalSignsModel.isInitialized && (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE))
			{
				updateBloodGlucoseAverage();
			}
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			if (_isInitialized != value)
			{
				_isInitialized = value;
				updateBloodGlucoseAverage();
			}
		}

		public function save():Boolean
		{
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence = chartModelDetails.healthChartsModel.decisionData as ScheduleItemOccurrence;

			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data on the health charts model was not a ScheduleItemOccurrence.");

			var healthActionSchedule:HealthActionSchedule = decisionScheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			var plan:HealthActionPlan = healthActionSchedule.scheduledHealthAction as HealthActionPlan;

			// validate
			if (isChangeSpecified)
			{
				var scheduleDetails:ScheduleDetails = getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_LEVEMIR_CODE);
				var currentMedicationScheduleItem:MedicationScheduleItem = scheduleDetails.schedule;
				var currentDoseValue:Number;
				var newDose:Number;
				if (currentMedicationScheduleItem)
				{
					currentDoseValue = currentMedicationScheduleItem.dose ? Number(currentMedicationScheduleItem.dose.value) : NaN;
					newDose = currentDoseValue + dosageChangeValue;
				}
				else
				{
					currentDoseValue = NaN;
					newDose = dosageChangeValue;
				}

				// if dose is specified and is different
				if (newDose != currentDoseValue)
				{
					// create new HealthActionOccurrence, related to HealthActionSchedule
					var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
					var decisionHealthActionResult:HealthActionResult = new HealthActionResult();

					decisionHealthActionResult.name = plan.name.clone();
					decisionHealthActionResult.planType = plan.planType;
					decisionHealthActionResult.dateReported = chartModelDetails.currentDateSource.now();
					decisionHealthActionResult.reportedBy = chartModelDetails.accountId;
					var actionStepResult:ActionStepResult = new ActionStepResult();
					actionStepResult.name = new CodedValue("Chose a new dose");
					decisionHealthActionResult.actions = new ArrayCollection();
					decisionHealthActionResult.actions.addItem(actionStepResult);
					results.push(decisionHealthActionResult);

					if (decisionScheduleItemOccurrence)
					{
						// TODO: switch to the new data types
//						decisionScheduleItemOccurrence.createHealthActionOccurrence(results, chartModelDetails.record,
//								chartModelDetails.accountId);
						decisionScheduleItemOccurrence.createAdherenceItem(results, chartModelDetails.record,
								chartModelDetails.accountId);
					}
					else
					{
						for each (var result:DocumentBase in results)
						{
							result.pendingAction = DocumentBase.ACTION_CREATE;
							chartModelDetails.record.addDocument(result);
						}
					}


					// create new HealthActionResult, related to HealthActionOccurrence
					// determine cut off date for schedule change
					// update existing MedicationScheduleItem (old dose) to end the recurrence by cut off date
					// create new MedicationScheduleItem with new dose starting at cut off day
				}
			}

			return true;
		}

		public function getNextMedicationScheduleDetails(medicationCode:String):ScheduleDetails
		{
			var now:Date = _chartModelDetails.currentDateSource.now();
			for each (var medicationScheduleItem:MedicationScheduleItem in chartModelDetails.record.medicationScheduleItemsModel.medicationScheduleItemCollection)
			{
				if (medicationScheduleItem.name.value == medicationCode)
				{
					// TODO: exactly what span of time should we use to look for the "next" scheduled item?
					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(now, new Date(now.valueOf() + ScheduleItemBase.MILLISECONDS_IN_DAY));
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
					{
						if (scheduleItemOccurrence.adherenceItem == null)
						{
							return new ScheduleDetails(medicationScheduleItem, scheduleItemOccurrence);
						}
					}
				}
			}

			return null;
		}
	}
}
