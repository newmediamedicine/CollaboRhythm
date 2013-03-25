package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.view.ForaD40bHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.services.DateUtil;

	import flash.net.URLVariables;

	[Bindable]
	public class ForaD40bHealthActionInputModelBase extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		public static const FROM_DEVICE:String = "from device: ";
		public static const SELF_REPORT:String = "self report";

		private var _isDuplicate:Boolean;
		private var _isFromDevice:Boolean;
		private var _dateMeasuredStart:Date;
		protected var _foraD40bHealthActionInputModelCollection:ForaD40bHealthActionInputModelCollection;

		public function ForaD40bHealthActionInputModelBase(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   scheduleCollectionsProvider:IScheduleCollectionsProvider,
														   foraD40bHealthActionInputModelCollection:ForaD40bHealthActionInputModelCollection)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider, scheduleCollectionsProvider);

			_foraD40bHealthActionInputModelCollection = foraD40bHealthActionInputModelCollection;

			dateMeasuredStart = _currentDateSource.now();
		}

		public function get isDuplicate():Boolean
		{
			return _isDuplicate;
		}

		public function set isDuplicate(isDuplicate:Boolean):void
		{
			_isDuplicate = isDuplicate;
		}

		/**
		 * Creates the VitalSign document(s) or other Indivo document(s) that should result from performing the health action.
		 * @return True if the creation was successful; otherwise false.
		 */
		public function createResult():Boolean
		{
			return false;
		}

		/**
		 * Save the result and persist. For batch transfers, this is only called on the most recent measurement.
		 *
		 * @param initiatedLocally
		 */
		public function submitResult(initiatedLocally:Boolean):void
		{

		}

		/**
		 * Save the result and persist if persist is true. For batch transfers, this is called for every measurement
		 * except the most recent one.
		 *
		 * @param initiatedLocally
		 * @param persist
		 */
		public function saveResult(initiatedLocally:Boolean, persist:Boolean):void
		{

		}

		public function get isFromDevice():Boolean
		{
			return _isFromDevice;
		}

		public function set isFromDevice(isFromDevice:Boolean):void
		{
			_isFromDevice = isFromDevice;
		}

		public function get dateMeasuredStart():Date
		{
			return _dateMeasuredStart;
		}

		public function set dateMeasuredStart(dateMeasuredStart:Date):void
		{
			_dateMeasuredStart = dateMeasuredStart;
		}

		public function get adherenceResultDate():Date
		{
			var adherenceResultDate:Date;

			if (scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem &&
					scheduleItemOccurrence.adherenceItem.adherenceResults &&
					scheduleItemOccurrence.adherenceItem.adherenceResults.length != 0)
			{
				var firstResultVitalSign:VitalSign = scheduleItemOccurrence.adherenceItem.adherenceResults[0] as
						VitalSign;
				adherenceResultDate = firstResultVitalSign.dateMeasuredStart;
			}

			return adherenceResultDate;
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return !isFromDevice;
		}

		override public function getPossibleScheduleItemOccurrences():Vector.<ScheduleItemOccurrence>
		{
			return getMatchingScheduleItemOccurrencesInWindow(DateUtil.MILLISECONDS_IN_DAY / 2,
					DateUtil.MILLISECONDS_IN_DAY / 2, false, true);
		}

		private function getMatchingScheduleItemOccurrencesInWindow(windowStartOffset:Number, windowEndOffset:Number,
																	intersect:Boolean,
																	includeToday:Boolean = false):Vector.<ScheduleItemOccurrence>
		{
			var measuredDayEnd:Number = DateUtil.roundTimeToNextDay(dateMeasuredStart).valueOf();
			var windowStart:Date;
			var windowEnd:Date;
			if (includeToday)
			{
				windowStart = new Date(Math.min(dateMeasuredStart.valueOf() - windowStartOffset,
						measuredDayEnd - DateUtil.MILLISECONDS_IN_DAY));
				windowEnd = new Date(Math.max(dateMeasuredStart.valueOf() + windowEndOffset, measuredDayEnd));
			}
			else
			{
				windowStart = new Date(dateMeasuredStart.valueOf() - windowStartOffset);
				windowEnd = new Date(dateMeasuredStart.valueOf() + windowEndOffset);
			}

			var occurrences:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var schedule:HealthActionSchedule in
					_healthActionModelDetailsProvider.record.healthActionSchedulesModel.healthActionScheduleCollection)
			{
				if (this is BloodGlucoseHealthActionInputModel && ForaD40bHealthActionListViewAdapterFactory.isForBloodGlucose(schedule) ||
						this is BloodPressureHealthActionInputModel && ForaD40bHealthActionListViewAdapterFactory.isForBloodPressure(schedule))
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
				if (matchingOccurrence.adherenceItem == null ||
						matchingOccurrence.adherenceItem.pendingAction == DocumentBase.ACTION_CREATE)
				{
					return matchingOccurrence;
				}
			}
			return null;
		}

		public function handleHealthActionResult():void
		{
			setCurrentView(ForaD40bHealthActionInputView);
		}

		public function handleHealthActionSelected():void
		{
			setCurrentView(ForaD40bHealthActionInputView);
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
		}

		public function get currentView():Class
		{
			return _foraD40bHealthActionInputModelCollection.currentView;
		}

		public function set currentView(currentView:Class):void
		{
			_foraD40bHealthActionInputModelCollection.currentView = currentView;
		}

		protected function setCurrentView(view:Class):void
		{
			currentView = view;
		}

		public function get foraD40bHealthActionInputModelCollection():ForaD40bHealthActionInputModelCollection
		{
			return _foraD40bHealthActionInputModelCollection;
		}

		public function get isReview():Boolean
		{
			return scheduleItemOccurrence && scheduleItemOccurrence.adherenceItem && currentView == ForaD40bHealthActionInputView;
		}

		public function get measurementValue():String
		{
			return null;
		}
	}
}
