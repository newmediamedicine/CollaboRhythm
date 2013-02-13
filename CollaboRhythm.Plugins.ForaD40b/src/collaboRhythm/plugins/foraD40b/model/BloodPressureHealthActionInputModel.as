package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bAppController;
	import collaboRhythm.plugins.foraD40b.view.ForaD40bHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.DeviceGatewayConstants;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	[Bindable]
	public class BloodPressureHealthActionInputModel extends ForaD40bHealthActionInputModelBase implements IHealthActionInputModel
	{
		private var _position:String;
		private var _site:String;
		private var _systolic:String = "";
		private var _diastolic:String = "";
		private var _heartRate:String = "";
		private var _results:Vector.<DocumentBase>;

		public function BloodPressureHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
															healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															scheduleCollectionsProvider:IScheduleCollectionsProvider,
															foraD40bHealthActionInputModelCollection:ForaD40bHealthActionInputModelCollection)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider, foraD40bHealthActionInputModelCollection);
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
						switch(vitalSign.name.text)
						{
							case VitalSignsModel.SYSTOLIC_CATEGORY:
							{
								systolic = vitalSign.result.value;
								isFromDevice = vitalSign.comments != ForaD40bHealthActionInputModelBase.SELF_REPORT;
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
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var comments:String = duplicatePreventionComments();
			var bloodPressureSystolic:VitalSign = vitalSignFactory.createBloodPressureSystolic(dateMeasuredStart,
					systolic, null, null, site, position, null, comments);
			var bloodPressureDiastolic:VitalSign = vitalSignFactory.createBloodPressureDiastolic(dateMeasuredStart,
					diastolic, null, null, site, position, null, comments);
			var heartRate:VitalSign = vitalSignFactory.createHeartRate(dateMeasuredStart, heartRate, null, null,
					site, position, null, comments);

			results = new Vector.<DocumentBase>();
			results.push(bloodPressureSystolic, bloodPressureDiastolic, heartRate);

			return true;
		}

		private function duplicatePreventionComments():String
		{
			return isFromDevice ? FROM_DEVICE + ForaD40bAppController.DEFAULT_NAME + " " + _urlVariables.toString() : SELF_REPORT;
		}

		override public function submitResult(initiatedLocally:Boolean):void
		{
			saveResult(initiatedLocally, true);
		}

		override public function saveResult(initiatedLocally:Boolean, persist:Boolean):void
		{
			submitBloodPressure();
			if (persist)
			{
				healthActionModelDetailsProvider.record.saveAllChanges();
				setCurrentView(null);
			}
		}

		public function submitBloodPressure():void
		{
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
		}

		override public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_logger.debug("handleUrlVariables " + urlVariables.toString());

			dateMeasuredStart = DateUtil.parseW3CDTF(urlVariables[DeviceGatewayConstants.CORRECTED_MEASURED_DATE_KEY]);
			isFromDevice = true;

			this.urlVariables = urlVariables;

			if (currentView != ForaD40bHealthActionInputView)
			{
				setCurrentView(ForaD40bHealthActionInputView);
			}
		}

		override public function set urlVariables(value:URLVariables):void
		{
			systolic = value.systolic;
			diastolic = value.diastolic;
			heartRate = value.heartrate;

			_urlVariables = value;
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
	}
}
