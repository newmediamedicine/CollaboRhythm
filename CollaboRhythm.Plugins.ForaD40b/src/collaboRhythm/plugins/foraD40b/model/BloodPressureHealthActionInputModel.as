package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bAppController;
	import collaboRhythm.plugins.foraD40b.view.AbnormalBloodPressureHypertensiveUrgencyView;
	import collaboRhythm.plugins.foraD40b.view.AbnormalBloodPressureHypotensionView;
	import collaboRhythm.plugins.foraD40b.view.AbnormalBloodPressureRepeatView;
	import collaboRhythm.plugins.foraD40b.view.AbnormalBloodPressureUrgentCallView;
	import collaboRhythm.plugins.foraD40b.view.ForaD40bHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.services.DateUtil;

	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class BloodPressureHealthActionInputModel extends ForaD40bHealthActionInputModelBase implements IHealthActionInputModel
	{
		public static const HYPERTENSIVE_URGENCY_THRESHOLD_SYSTOLIC:int = 180;
		public static const HYPERTENSIVE_URGENCY_THRESHOLD_DIASTOLIC:int = 120;
		public static const HYPOTENSION_THRESHOLD_SYSTOLIC:int = 90;
		public static const HYPOTENSION_THRESHOLD_DIASTOLIC:int = 60;

		public static const HYPERTENSIVE_URGENCY:String = "Hypertensive Urgency";
		public static const NORMAL:String = "Normal";
		public static const HYPOTENSION:String = "Hypotension";

		private static const ABNORMAL_BLOOD_PRESSURE_ACTION_PLAN_HEALTH_ACTION_RESULT_NAME:String = "Abnormal Blood Pressure Action Plan";
		private static const REPORT_SYMPTOMS_ACTION_STEP_NAME:String = "Report Symptoms";

		private var _position:String;
		private var _site:String;
		private var _systolic:String = "";
		private var _diastolic:String = "";
		private var _heartRate:String = "";

		private var _results:Vector.<DocumentBase>;

		private var _bloodPressureState:String = NORMAL;

		private var _abnormalBloodPressure:VitalSign;
		private var _abnormalBloodPressureActionPlanHealthActionResult:HealthActionResult;
		private var _repeatBloodPressureCount:int = 0;

		private var _previousSystolic:String = "";
		private var _previousDiastolic:String = "";
		private var _previousHeartRate:String = "";

		private static const SITTING_POSITION:String = "Sitting";
		private static const LEFT_ARM_SITE:String = "Left Arm";

		private static const DEFAULT_POSITION:String = SITTING_POSITION;
		private static const DEFAULT_SITE:String = LEFT_ARM_SITE;

		public function BloodPressureHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															scheduleCollectionsProvider:IScheduleCollectionsProvider,
															foraD40bHealthActionInputModelCollection:ForaD40bHealthActionInputModelCollection)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider,
					foraD40bHealthActionInputModelCollection);
			position = DEFAULT_POSITION;
			site = DEFAULT_SITE;
			updateFromAdherence();
		}

		private function updateFromAdherence():void
		{
			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem)
			{
				if (scheduleItemOccurrence.adherenceItem.adherenceResults &&
						scheduleItemOccurrence.adherenceItem.adherenceResults.length != 0)
				{
					for each (var documentBase:DocumentBase in
							scheduleItemOccurrence.adherenceItem.adherenceResults)
					{
						var vitalSign:VitalSign = documentBase as VitalSign;
						switch (vitalSign.name.text)
						{
							case VitalSignsModel.SYSTOLIC_CATEGORY:
							{
								systolic = vitalSign.result.value;
								isFromDevice = vitalSign.comments != ForaD40bHealthActionInputModelBase.SELF_REPORT;
								site = vitalSign.site;
								position = vitalSign.position;
								break;
							}
							case VitalSignsModel.DIASTOLIC_CATEGORY:
							{
								diastolic = vitalSign.result.value;
								break;
							}
							case VitalSignsModel.HEART_RATE_CATEGORY:
							{
								heartRate = vitalSign.result.value;
								break;
							}
						}
					}
				}
			}
		}

		override public function createResult():Boolean
		{
			if (isValidValue(systolic) && isValidValue(diastolic))
			{
				var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

				results = new Vector.<DocumentBase>();
				var comments:String = duplicatePreventionComments();
				var bloodPressureSystolic:VitalSign = vitalSignFactory.createBloodPressureSystolic(dateMeasuredStart,
						systolic, null, null, site, position, null, comments);
				results.push(bloodPressureSystolic);
				var bloodPressureDiastolic:VitalSign = vitalSignFactory.createBloodPressureDiastolic(dateMeasuredStart,
						diastolic, null, null, site, position, null, comments);
				results.push(bloodPressureDiastolic);
				if (isValidValue(heartRate))
				{
					var heartRateVitalSign:VitalSign = vitalSignFactory.createHeartRate(dateMeasuredStart, heartRate,
							null, null,
							site, position, null, comments);
					results.push(heartRateVitalSign);
				}

				evaluateBloodPressureState();

				return true;
			}
			return false;
		}

		private function evaluateBloodPressureState():void
		{
			for each (var result:DocumentBase in results)
			{
				var vitalSign:VitalSign = result as VitalSign;

				if (vitalSign)
				{
					if (vitalSign.name.text == VitalSignsModel.SYSTOLIC_CATEGORY)
					{
						if (vitalSign.resultAsNumber > HYPERTENSIVE_URGENCY_THRESHOLD_SYSTOLIC)
						{
							abnormalBloodPressure = vitalSign;
							bloodPressureState = HYPERTENSIVE_URGENCY;
							return;
						}
						else if (vitalSign.resultAsNumber < HYPOTENSION_THRESHOLD_SYSTOLIC)
						{
							abnormalBloodPressure = vitalSign;
							bloodPressureState = HYPOTENSION;
							return;
						}
					}
					else if (vitalSign.name.text == VitalSignsModel.DIASTOLIC_CATEGORY)
					{
						if (vitalSign.resultAsNumber > HYPERTENSIVE_URGENCY_THRESHOLD_DIASTOLIC)
						{
							abnormalBloodPressure = vitalSign;
							bloodPressureState = HYPERTENSIVE_URGENCY;
							return;
						}
						else if (vitalSign.resultAsNumber < HYPOTENSION_THRESHOLD_DIASTOLIC)
						{
							abnormalBloodPressure = vitalSign;
							bloodPressureState = HYPOTENSION;
							return;
						}
					}
				}
			}

			bloodPressureState = NORMAL;
		}

		private function duplicatePreventionComments():String
		{
			return isFromDevice ? FROM_DEVICE + ForaD40bAppController.DEFAULT_NAME + " " +
					_urlVariables.toString() : SELF_REPORT;
		}

		override public function submitResult(initiatedLocally:Boolean):void
		{
			submitBloodPressure(initiatedLocally);
		}

		override public function saveResult(initiatedLocally:Boolean, persist:Boolean):void
		{
			if (healthActionModelDetailsProvider.record == null)
			{
				_logger.warn("Record is null. Unexpected error. Save can not be completed and changes will be lost.");
			}

			if (scheduleItemOccurrence)
			{
				scheduleItemOccurrence.createAdherenceItem(results, healthActionModelDetailsProvider.record,
						healthActionModelDetailsProvider.accountId, true);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					result.pendingAction = DocumentBase.ACTION_CREATE;
					healthActionModelDetailsProvider.record.addDocument(result);
				}
			}

			if (persist)
			{
				healthActionModelDetailsProvider.record.saveAllChanges();
			}

			scheduleItemOccurrence = null;
		}

		public function submitBloodPressure(initiatedLocally:Boolean):void
		{
			saveResult(initiatedLocally, true);
			_foraD40bHealthActionInputModelCollection.clearMeasurements();

			if (bloodPressureState == NORMAL)
			{
				setCurrentView(null);
			}
			else if (bloodPressureState == HYPERTENSIVE_URGENCY)
			{
				handleHypertensiveUrgency();
			}
			else if (bloodPressureState == HYPOTENSION)
			{
				handleHypotension();
			}
		}

		private function handleHypertensiveUrgency():void
		{
			if (_repeatBloodPressureCount == 0)
			{
				setCurrentView(AbnormalBloodPressureHypertensiveUrgencyView);
				createAbnormalBloodPressureHealthActionResult();
			}
			else
			{
				setCurrentView(AbnormalBloodPressureUrgentCallView)
			}

			_repeatBloodPressureCount++;
		}

		private function handleHypotension():void
		{
			if (_repeatBloodPressureCount == 0)
			{
				setCurrentView(AbnormalBloodPressureHypotensionView);
				createAbnormalBloodPressureHealthActionResult();
			}
			else
			{
				setCurrentView(AbnormalBloodPressureUrgentCallView)
			}

			_repeatBloodPressureCount++;
		}

		private function createAbnormalBloodPressureHealthActionResult():void
		{
			_abnormalBloodPressureActionPlanHealthActionResult = new HealthActionResult();
			_abnormalBloodPressureActionPlanHealthActionResult.name = new CollaboRhythmCodedValue(null, null, null,
					ABNORMAL_BLOOD_PRESSURE_ACTION_PLAN_HEALTH_ACTION_RESULT_NAME);
			_abnormalBloodPressureActionPlanHealthActionResult.reportedBy = healthActionModelDetailsProvider.accountId;
			_abnormalBloodPressureActionPlanHealthActionResult.dateReported = _currentDateSource.now();
			_abnormalBloodPressureActionPlanHealthActionResult.actions = new ArrayCollection();
			_abnormalBloodPressure.triggeredHealthActionResults.push(_abnormalBloodPressureActionPlanHealthActionResult);
		}

		private function saveAbnormalBloodPressureHealthActionResult(initiatedLocally:Boolean):void
		{
			healthActionModelDetailsProvider.record.addDocument(_abnormalBloodPressureActionPlanHealthActionResult,
					initiatedLocally);
			healthActionModelDetailsProvider.record.addRelationship(HealthActionResult.RELATION_TYPE_TRIGGERED_HEALTH_ACTION_RESULT,
					_abnormalBloodPressure, _abnormalBloodPressureActionPlanHealthActionResult, initiatedLocally);

			if (initiatedLocally)
			{
				healthActionModelDetailsProvider.record.saveAllChanges();
			}
		}

		override public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_logger.debug("handleUrlVariables " + urlVariables.toString());

			dateMeasuredStart = DateUtil.parseW3CDTF(urlVariables[DeviceGatewayConstants.CORRECTED_MEASURED_DATE_KEY]);
			isFromDevice = true;

			this.urlVariables = urlVariables;

			if (repeatBloodPressureCount == 0)
			{
				if (foraD40bHealthActionInputModelCollection.pushedViewCount == 0 ||
						currentView != ForaD40bHealthActionInputView)
				{
					setCurrentView(ForaD40bHealthActionInputView);
				}
			}
			else
			{
				if (currentView != AbnormalBloodPressureRepeatView)
				{
					setCurrentView(AbnormalBloodPressureRepeatView);
				}
			}
		}

		override public function set urlVariables(value:URLVariables):void
		{
			systolic = value.systolic;
			diastolic = value.diastolic;
			heartRate = value.heartrate;

			_urlVariables = value;
		}

		public function abnormalBloodPressureSymptomsHandler(symptomsPresent:Boolean):void
		{
			var occurrence:Occurrence = new Occurrence();
			occurrence.startTime = _currentDateSource.now();
			occurrence.additionalDetails = symptomsPresent.toString();

			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CollaboRhythmCodedValue(null, null, null, REPORT_SYMPTOMS_ACTION_STEP_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			actionStepResult.occurrences.addItem(occurrence);

			_abnormalBloodPressureActionPlanHealthActionResult.actions.addItem(actionStepResult);

			if (symptomsPresent)
			{
				setCurrentView(AbnormalBloodPressureUrgentCallView);
			}
			else
			{
				setCurrentView(AbnormalBloodPressureRepeatView);
			}
		}

		public function quitAbnormalBloodPressureActionPlan(initiatedLocally:Boolean):void
		{
			saveAbnormalBloodPressureHealthActionResult(initiatedLocally);
			setCurrentView(null);
		}

		public function get systolic():String
		{
			return _systolic;
		}

		public function set systolic(value:String):void
		{
			_systolic = value;
		}

		public function get diastolic():String
		{
			return _diastolic;
		}

		public function set diastolic(value:String):void
		{
			_diastolic = value;
		}

		public function get heartRate():String
		{
			return _heartRate;
		}

		public function set heartRate(value:String):void
		{
			_heartRate = value;
		}

		public function get position():String
		{
			return _position;
		}

		public function set position(value:String):void
		{
			_position = value;
		}

		public function get site():String
		{
			return _site;
		}

		public function set site(value:String):void
		{
			_site = value;
		}

		private function get results():Vector.<DocumentBase>
		{
			return _results;
		}

		private function set results(results:Vector.<DocumentBase>):void
		{
			_results = results;
		}

		public function get previousSystolic():String
		{
			return _previousSystolic;
		}

		public function set previousSystolic(value:String):void
		{
			_previousSystolic = value;
		}

		public function get previousDiastolic():String
		{
			return _previousDiastolic;
		}

		public function set previousDiastolic(value:String):void
		{
			_previousDiastolic = value;
		}

		public function get previousHeartRate():String
		{
			return _previousHeartRate;
		}

		public function set previousHeartRate(value:String):void
		{
			_previousHeartRate = value;
		}

		public function get repeatBloodPressureCount():int
		{
			return _repeatBloodPressureCount;
		}

		public function set repeatBloodPressureCount(value:int):void
		{
			_repeatBloodPressureCount = value;
		}

		public function get bloodPressureState():String
		{
			return _bloodPressureState;
		}

		public function set bloodPressureState(value:String):void
		{
			_bloodPressureState = value;
		}

		public function get abnormalBloodPressure():VitalSign
		{
			return _abnormalBloodPressure;
		}

		public function set abnormalBloodPressure(value:VitalSign):void
		{
			_abnormalBloodPressure = value;
		}

		public function get abnormalBloodPressureActionPlanHealthActionResult():HealthActionResult
		{
			return _abnormalBloodPressureActionPlanHealthActionResult;
		}

		public function set abnormalBloodPressureActionPlanHealthActionResult(value:HealthActionResult):void
		{
			_abnormalBloodPressureActionPlanHealthActionResult = value;
		}

		override public function get measurementValue():String
		{
			return systolic;
		}
	}
}
