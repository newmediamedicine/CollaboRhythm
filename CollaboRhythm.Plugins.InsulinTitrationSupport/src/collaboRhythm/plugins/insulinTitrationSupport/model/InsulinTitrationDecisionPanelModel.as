package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
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
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class InsulinTitrationDecisionPanelModel
	{
		public static const STEP_SATISFIED:String = "satisfied";
		public static const STEP_STOP:String = "stop";
		public static const STEP_PREVIOUS_STOP:String = "previous stop";
		private static const REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS:int = 3;

		private var _areBloodGlucoseRequirementsMet:Boolean = true;
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
		protected var _logger:ILogger;
		private var _eligibleBloodGlucoseMeasurements:Vector.<VitalSign>;

		/**
		 * Number of milliseconds after the end of a schedule occurrence for which the item/action is to be still considered
		 * "current" or "next" even though it is in the past (has been missed). This a non-negative value would allow the
		 * schedule to be changed for a dose of medication (for example) after the medication was due to be taken.
		 */
		private const NEXT_OCCURRENCE_DELTA:Number = 0;
		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		public function InsulinTitrationDecisionPanelModel(chartModelDetails:IChartModelDetails)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			this.chartModelDetails = chartModelDetails;
			updateBloodGlucoseAverage();
		}

		private function updateBloodGlucoseAverage():void
		{
			pickEligibleBloodGlucoseMeasurements();
			bloodGlucoseAverage = getBloodGlucoseAverage();
			updateStep1State();
		}

		/**
		 * Picks the eligible blood glucose measurements for the 303 algorithm.
		 * For a blood glucose measurement to eligible for determining the average for the algorithm:
		 * 	1) it must be the first measurement taken in the day
		 * 	2) it must be taken before eating breakfast (preprandial)
		 * 	3) it must fall within a window of time including today and the three days prior to today (four day window)
		 */
		private function pickEligibleBloodGlucoseMeasurements():void
		{
			_eligibleBloodGlucoseMeasurements = new Vector.<VitalSign>();
			var bloodGlucoseArrayCollection:ArrayCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(VitalSignsModel.BLOOD_GLUCOSE_CATEGORY);
			var previousBloodGlucose:VitalSign;
			var now:Date = _chartModelDetails.currentDateSource.now();
			var eligibleWindowCutoff:Date = new Date(SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() - MILLISECONDS_IN_DAY * 4);
			if (bloodGlucoseArrayCollection && bloodGlucoseArrayCollection.length > 0)
			{
				for each (var bloodGlucose:VitalSign in bloodGlucoseArrayCollection)
				{
					if (bloodGlucose.dateMeasuredStart.valueOf() > eligibleWindowCutoff.valueOf() && bloodGlucose.dateMeasuredStart.valueOf() < now.valueOf())
					{
						for each (var relationship:Relationship in bloodGlucose.isRelatedFrom)
						{
							// TODO: implement more robustly; for now we are assuming that any blood glucose that is an adherence result is the eligible preprandial measurement
							if (relationship.type == AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT)
							{
								// TODO: find a better way to determine if the two measurements are in the same day
								if (previousBloodGlucose == null
										|| previousBloodGlucose.dateMeasuredStart.toDateString() != bloodGlucose.dateMeasuredStart.toDateString())
								{
									_eligibleBloodGlucoseMeasurements.push(bloodGlucose);
									previousBloodGlucose = bloodGlucose;
								}
							}
						}
					}
				}

				// remove the oldest so we only have the 3 most recent
				while (_eligibleBloodGlucoseMeasurements.length > REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS)
				{
					_eligibleBloodGlucoseMeasurements.shift();
				}
			}
		}

		public function get areBloodGlucoseRequirementsMet():Boolean
		{
			return _areBloodGlucoseRequirementsMet;
		}

		public function get isAverageAvailable():Boolean
		{
			return !isNaN(_bloodGlucoseAverage);
		}

		public function set areBloodGlucoseRequirementsMet(value:Boolean):void
		{
			_areBloodGlucoseRequirementsMet = value;
			updateStep1State();
		}

		private function updateStep1State():void
		{
			step1State = areBloodGlucoseRequirementsMet ? STEP_SATISFIED : STEP_STOP;
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
			updateIsAverageAvailable();
			updateAlgorithmSuggestions();
		}

		public function updateIsAverageAvailable():void
		{
			areBloodGlucoseRequirementsMet = !isNaN(bloodGlucoseAverage) && _eligibleBloodGlucoseMeasurements != null &&
					_eligibleBloodGlucoseMeasurements.length >= REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS &&
					isLastBloodGlucoseMeasurementFromToday();
		}

		private function isLastBloodGlucoseMeasurementFromToday():Boolean
		{
			var now:Date = _chartModelDetails.currentDateSource.now();
			var startOfToday:Date = new Date(SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() -
					MILLISECONDS_IN_DAY);

			if (_eligibleBloodGlucoseMeasurements && _eligibleBloodGlucoseMeasurements.length > 0)
			{
				var bloodGlucose:VitalSign = _eligibleBloodGlucoseMeasurements[_eligibleBloodGlucoseMeasurements.length -
						1];
				return bloodGlucose && bloodGlucose.dateMeasuredStart != null &&
						bloodGlucose.dateMeasuredStart.valueOf() >= startOfToday.valueOf();
			}
			return false;
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
			var bloodGlucoseSum:Number = 0;
			var bloodGlucoseCount:int = 0;

			for each (var bloodGlucose:VitalSign in _eligibleBloodGlucoseMeasurements)
			{
				bloodGlucoseSum += bloodGlucose.resultAsNumber;
				bloodGlucoseCount++;
			}

			var average:Number = NaN;
			if (bloodGlucoseCount > 0)
				average = bloodGlucoseSum / bloodGlucoseCount;
			return average;
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

		private var _scheduleDetails:ScheduleDetails;
		private var _currentDoseValue:Number;
		private var _newDose:Number;

		public function evaluateForSave():void
		{
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence = chartModelDetails.healthChartsModel.decisionData as ScheduleItemOccurrence;

			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data on the health charts model was not a ScheduleItemOccurrence.");

			// validate
			if (isChangeSpecified)
			{
				_scheduleDetails = getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_LEVEMIR_CODE);
				var currentMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.schedule;
				if (currentMedicationScheduleItem)
				{
					_currentDoseValue = currentMedicationScheduleItem.dose ? Number(currentMedicationScheduleItem.dose.value) : NaN;
					_newDose = _currentDoseValue + dosageChangeValue;
				}
				else
				{
					_currentDoseValue = NaN;
					_newDose = dosageChangeValue;
				}
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
				evaluateForSave();
				var currentMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.schedule;

				// create new HealthActionOccurrence, related to HealthActionSchedule
				// create new HealthActionResult, related to HealthActionOccurrence
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

				// if dose is specified and is different, update existing and/or create a new schedule
				if (_newDose != _currentDoseValue)
				{
					// determine cut off date for schedule change
					// update existing MedicationScheduleItem (old dose) to end the recurrence by cut off date

					var administeredOccurrenceCount:int = _scheduleDetails.occurrence.recurrenceIndex;
					if (administeredOccurrenceCount > 0)
					{
						if (currentMedicationScheduleItem.recurrenceRule)
						{
							var remainingOccurrenceCount:int = currentMedicationScheduleItem.recurrenceRule.count -
									administeredOccurrenceCount;
							if (remainingOccurrenceCount > 0)
							{
								currentMedicationScheduleItem.recurrenceRule.count = administeredOccurrenceCount;
								currentMedicationScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;

								// create new MedicationScheduleItem with new dose starting at cut off day
								var newMedicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
								newMedicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
								newMedicationScheduleItem.dose = new ValueAndUnit(_newDose.toString(),
										new CodedValue("http://indivo.org/codes/units#", "Units", "U", "Units"));
								newMedicationScheduleItem.name = currentMedicationScheduleItem.name.clone();
								newMedicationScheduleItem.scheduledBy = chartModelDetails.accountId;
								newMedicationScheduleItem.dateScheduled = chartModelDetails.currentDateSource.now();
								newMedicationScheduleItem.dateStart = _scheduleDetails.occurrence.dateStart;
								newMedicationScheduleItem.dateEnd = _scheduleDetails.occurrence.dateEnd;
								newMedicationScheduleItem.recurrenceRule = new RecurrenceRule();
								if (currentMedicationScheduleItem.recurrenceRule.frequency)
									newMedicationScheduleItem.recurrenceRule.frequency = currentMedicationScheduleItem.recurrenceRule.frequency.clone();
								if (currentMedicationScheduleItem.recurrenceRule.interval)
									newMedicationScheduleItem.recurrenceRule.interval = currentMedicationScheduleItem.recurrenceRule.interval.clone();
								newMedicationScheduleItem.recurrenceRule.count = remainingOccurrenceCount;
								newMedicationScheduleItem.instructions = currentMedicationScheduleItem.instructions;

								chartModelDetails.record.addDocument(newMedicationScheduleItem);

								var relationship:Relationship = chartModelDetails.record.addNewRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM, currentMedicationScheduleItem.scheduledMedicationOrder, newMedicationScheduleItem);
								newMedicationScheduleItem.scheduledMedicationOrder = currentMedicationScheduleItem.scheduledMedicationOrder;

								// TODO: Use the correct id for the newMedicationScheduleItem; we are currently using the temporary id that we assigned ourselves; the actual id of the document will not bet known until we get a response from the server after creation
								currentMedicationScheduleItem.scheduledMedicationOrder.scheduleItems.put(newMedicationScheduleItem.meta.id, newMedicationScheduleItem);
							}
							else
							{
								// schedule has ended; no future occurrences to reschedule or change the dose for
								// TODO: warn the user why the dose cannot be changed; possibly provide a means to extend the schedule beyond the original recurrence range
								_logger.warn("User is attempting to change the dose for " +
										currentMedicationScheduleItem.name.text + " with dateStart of " +
										currentMedicationScheduleItem.dateStart.toLocaleString() +
										" but the schedule has ended; no future occurrences to reschedule or change the dose for.");
								return false;
							}
						}
					}
					else
					{
						currentMedicationScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;
						currentMedicationScheduleItem.dose.value = _newDose.toString();
					}

				}
			}

			return true;
		}

		/**
		 * Finds the next ScheduleItemOccurrence and corresponding MedicationScheduleItem for the specified medication
		 * where the medication has not yet been administered and the occurrence is current (adherence window overlaps
		 * the current time) or future (occurrence starts after the current time).
		 * @param medicationCode The medication to match.
		 * @return The details of the schedule, including the ScheduleItemOccurrence and corresponding MedicationScheduleItem.
		 */
		public function getNextMedicationScheduleDetails(medicationCode:String):ScheduleDetails
		{
			var now:Date = _chartModelDetails.currentDateSource.now();
			for each (var medicationScheduleItem:MedicationScheduleItem in chartModelDetails.record.medicationScheduleItemsModel.medicationScheduleItemCollection)
			{
				if (medicationScheduleItem.name.value == medicationCode)
				{
					// TODO: exactly what span of time should we use to look for the "next" scheduled item? Currently we are using 24 hours before to 48 hours after the current time (a 3 day window)
					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(
							new Date(now.valueOf() - ScheduleItemBase.MILLISECONDS_IN_DAY),
							new Date(now.valueOf() + 2 * ScheduleItemBase.MILLISECONDS_IN_DAY));
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
					{
						if (scheduleItemOccurrence.adherenceItem == null && scheduleItemOccurrence.dateEnd.valueOf() >= (now.valueOf() - NEXT_OCCURRENCE_DELTA))
						{
							return new ScheduleDetails(medicationScheduleItem, scheduleItemOccurrence);
						}
					}
				}
			}

			return null;
		}

		public function isMeasurementEligible(vitalSign:VitalSign):Boolean
		{
			return _eligibleBloodGlucoseMeasurements && _eligibleBloodGlucoseMeasurements.indexOf(vitalSign) != -1;
		}

		public function get currentDoseValue():Number
		{
			return _currentDoseValue;
		}

		public function get newDose():Number
		{
			return _newDose;
		}
	}
}
