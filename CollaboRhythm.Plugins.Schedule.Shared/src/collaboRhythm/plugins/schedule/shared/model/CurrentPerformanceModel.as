/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class CurrentPerformanceModel
	{
		/**
		 * Key to the CurrentPerformanceModel instance in Record.appData
		 */
		public static const CURRENT_PERFORMANCE_MODEL_KEY:String = "currentPerformanceModel";

		public static const TIME_PRIOR_TO_FIRST_SCHEDULE_GROUP:String = "Time prior to first schedule group";
		public static const TIME_DURING_SCHEDULE_GROUP:String = "Time during schedule group";
		public static const TIME_BETWEEN_SCHEDULE_GROUPS:String = "Time between schedule groups";
		public static const TIME_AFTER_LAST_SCHEDULE_GROUP:String = "Time after last schedule group";

		public static const BLOOD_PRESSURE_DANGEROUSLY_LOW:String = "Blood pressure dangerously low";
		public static const BLOOD_PRESSURE_NORMAL:String = "Blood pressure normal";
		public static const BLOOD_PRESSURE_HIGH:String = "Blood pressure high";
		public static const BLOOD_PRESSURE_DANGEROUSLY_HIGH:String = "Blood pressure dangerously high";

		private static const HYPOTENSION_SYSTOLIC_THRESHOLD:int = 90;
		private static const HYPOTENSION_DIASTOLIC_THRESHOLD:int = 60;
		private static const HYPERTENSION_SYSTOLIC_THRESHOLD:int = 180;
		private static const HYPERTENSION_DIASTOLIC_THRESHOLD:int = 120;
		private static const SYSTOLIC_GOAL:int = 130;

		private var _scheduleGroupsProvider:IScheduleGroupsProvider;
		private var _record:Record;

		private var _timingState:String;
		private var _duringScheduleGroup:ScheduleGroup;
		private var _medicationAdherenceReported:Boolean;
		private var _medicationAdherenceState:Boolean;
		private var _bloodPressureReported:Boolean;
		private var _bloodPressureReportedScheduleGroup:ScheduleGroup;
		private var _bloodPressureState:String;
		private var _systolicValue:Number;
		private var _diastolicValue:Number;

		private var _currentDateSource:ICurrentDateSource;

		public function CurrentPerformanceModel(scheduleGroupsProvider:IScheduleGroupsProvider, record:Record)
		{
			_scheduleGroupsProvider = scheduleGroupsProvider;
			_record = record;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function determineAdherence():void
		{
			var nowValue:Number = _currentDateSource.now().valueOf();
			var scheduleGroupsCollection:ArrayCollection = _scheduleGroupsProvider.scheduleGroupsCollection;
			scheduleGroupsCollection.source.sortOn("dateStartValue", Array.NUMERIC);
			if (scheduleGroupsCollection.length != 0)
			{
				if (nowValue < scheduleGroupsCollection.getItemAt(0).dateStart.valueOf())
				{
					timingState = TIME_PRIOR_TO_FIRST_SCHEDULE_GROUP;
					medicationAdherenceState = wasAdherentToMedicationsYesterday();
					bloodPressureReported = wasAdherentToEquipmentYesterday();
					updateBloodPressureState();
				}
				else if (nowValue > scheduleGroupsCollection.getItemAt(scheduleGroupsCollection.length - 1).dateEnd.valueOf())
				{
					timingState = TIME_AFTER_LAST_SCHEDULE_GROUP;
					medicationAdherenceState = wasAdherentToMedicationsInScheduleGroups(scheduleGroupsCollection);
					bloodPressureReported = didReportBloodPressure(scheduleGroupsCollection);
					updateBloodPressureState();
				}
				else
				{
					var previousScheduleGroup:ScheduleGroup = null;
					var previousScheduleGroupsCollection:ArrayCollection;
					for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
					{
						if (previousScheduleGroup && nowValue > previousScheduleGroup.dateEnd.valueOf() && nowValue < scheduleGroup.dateStart.valueOf())
						{
							timingState = TIME_BETWEEN_SCHEDULE_GROUPS;
							previousScheduleGroupsCollection = getPreviousScheduleGroups(scheduleGroupsCollection,
																						 previousScheduleGroup);
							medicationAdherenceState = wasAdherentToMedicationsInScheduleGroups(previousScheduleGroupsCollection);
							bloodPressureReported = didReportBloodPressure(previousScheduleGroupsCollection);
							updateBloodPressureState();
						}
						else if (nowValue > scheduleGroup.dateStart.valueOf() && nowValue < scheduleGroup.dateEnd.valueOf())
						{
							duringScheduleGroup = scheduleGroup;
							timingState = TIME_DURING_SCHEDULE_GROUP;
							if (!scheduleGroup.isMedicationAdherenceReportingCompleted)
							{
								medicationAdherenceReported = false;
								medicationAdherenceState = false;
								bloodPressureReported = didReportBloodPressure(previousScheduleGroupsCollection);
							}
							else
							{
								medicationAdherenceReported = true;
								if (scheduleGroupsCollection.getItemIndex(scheduleGroup) == scheduleGroupsCollection.length - 1)
								{
									timingState = TIME_AFTER_LAST_SCHEDULE_GROUP;
								}
								else
								{
									timingState = TIME_BETWEEN_SCHEDULE_GROUPS;
								}
								previousScheduleGroupsCollection = getPreviousScheduleGroups(scheduleGroupsCollection,
																							 scheduleGroup);
								medicationAdherenceState = wasAdherentToMedicationsInScheduleGroups(previousScheduleGroupsCollection);
								bloodPressureReported = didReportBloodPressure(previousScheduleGroupsCollection);
								updateBloodPressureState();
							}
						}
					}
				}
			}
			else
			{
				// TODO: What if there are no schedule groups for any day?
				_timingState = TIME_PRIOR_TO_FIRST_SCHEDULE_GROUP;
				_medicationAdherenceState = false;
			}
		}

		private function updateBloodPressureState():void
		{
			if (bloodPressureReported)
			{
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in _bloodPressureReportedScheduleGroup.scheduleItemsOccurrencesCollection)
				{
					if (scheduleItemOccurrence.scheduleItem.name.text == "FORA D40b")
					{
						var matchingAdherenceItem:AdherenceItem;
						for each (var adherenceItem:AdherenceItem in scheduleItemOccurrence.scheduleItem.adherenceItems)
						{
							if (adherenceItem.recurrenceIndex == scheduleItemOccurrence.recurrenceIndex && adherenceItem.adherence)
							{
								matchingAdherenceItem = adherenceItem;
							}
						}
						var adherenceResults:Vector.<DocumentBase> = matchingAdherenceItem.adherenceResults;
						for each (var adherenceResult:DocumentBase in adherenceResults)
						{
							var vitalSign:VitalSign = adherenceResult as VitalSign;
							if (vitalSign.name.text == VitalSignsModel.SYSTOLIC_CATEGORY)
							{
								systolicValue = vitalSign.resultAsNumber;
							}
							else if (vitalSign.name.text == VitalSignsModel.DIASTOLIC_CATEGORY)
							{
								diastolicValue = vitalSign.resultAsNumber;
							}
						}
					}
				}

//				var systolicValuesArrayCollection:ArrayCollection = _record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
//				var systolicVitalSign:VitalSign = systolicValuesArrayCollection.getItemAt(systolicValuesArrayCollection.length - 1) as VitalSign;
//				systolicValue = systolicVitalSign.resultAsNumber;
//				var diastolicValuesArrayCollection:ArrayCollection = _record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];
//				var diastolicVitalSign:VitalSign = diastolicValuesArrayCollection.getItemAt(diastolicValuesArrayCollection.length - 1) as VitalSign;
//				diastolicValue = diastolicVitalSign.resultAsNumber;

				if (systolicValue > HYPERTENSION_SYSTOLIC_THRESHOLD || diastolicValue > HYPERTENSION_DIASTOLIC_THRESHOLD)
				{
					bloodPressureState = BLOOD_PRESSURE_DANGEROUSLY_HIGH;
				}
				else if (systolicValue < HYPOTENSION_SYSTOLIC_THRESHOLD || diastolicValue < HYPOTENSION_DIASTOLIC_THRESHOLD)
				{
					bloodPressureState = BLOOD_PRESSURE_DANGEROUSLY_LOW;
				}
				else if (systolicValue > SYSTOLIC_GOAL)
				{
					bloodPressureState = BLOOD_PRESSURE_HIGH;
				}
				else
				{
					bloodPressureState = BLOOD_PRESSURE_NORMAL;
				}
			}
			else
			{
				bloodPressureState = "";
			}
		}

		private function didReportBloodPressure(scheduleGroupsCollection:ArrayCollection):Boolean
		{
			for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
			{
				if (scheduleGroup.hasBloodPressureScheduleItem && scheduleGroup.isBloodPressureReportingCompleted)
				{
					_bloodPressureReportedScheduleGroup = scheduleGroup;
					return true
				}
			}
			return false;
		}

		private function wasAdherentToMedicationsInScheduleGroups(scheduleGroupsCollection:ArrayCollection):Boolean
		{
			for each (var scheduleGroup:ScheduleGroup in scheduleGroupsCollection)
			{
				if (!scheduleGroup.isMedicationAdherencePerfect)
				{
					return false;
				}
			}
			return true;
		}

		private function getPreviousScheduleGroups(scheduleGroupsCollection:ArrayCollection,
												   scheduleGroup:ScheduleGroup):ArrayCollection
		{
			var scheduleGroupIndex:int = scheduleGroupsCollection.getItemIndex(scheduleGroup);
			var previousScheduleGroupsCollection:ArrayCollection = new ArrayCollection();
			for (var index:int = 0; index <= scheduleGroupIndex; index++)
			{
				previousScheduleGroupsCollection.addItem(scheduleGroupsCollection.getItemAt(index));
			}
			return previousScheduleGroupsCollection
		}

		private function wasAdherentToMedicationsYesterday():Boolean
		{
			var medicationScheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = getMedicationScheduleItemOccurrencesForYesterday();
			for each (var medicationScheduleItemOccurrence:ScheduleItemOccurrence in medicationScheduleItemOccurrences)
			{
				if (!wasAdherentToScheduleItemOccurrence(medicationScheduleItemOccurrence))
				{
					return false;
				}
			}
			return true;
		}

		private function wasAdherentToEquipmentYesterday():Boolean
		{
			var equipmentScheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = getEquipmentScheduleItemOccurrencesForYesterday();
			for each (var equipmentScheduleItemOccurrence:ScheduleItemOccurrence in equipmentScheduleItemOccurrences)
			{
				if (!wasAdherentToScheduleItemOccurrence(equipmentScheduleItemOccurrence))
				{
					return false;
				}
			}
			return true;
		}

		private function getMedicationScheduleItemOccurrencesForYesterday():Vector.<ScheduleItemOccurrence>
		{
			var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			var dateNow:Date = _currentDateSource.now();
			var dateStart:Date = new Date(new Date(dateNow.getFullYear(), dateNow.getMonth(),
												   dateNow.getDate()).valueOf() - (24 * 60 * 60 * 1000));
			var dateEnd:Date = new Date(new Date(dateNow.getFullYear(), dateNow.getMonth(), dateNow.getDate(), 23,
												 59).valueOf() - (24 * 60 * 60 * 1000));
			for each (var medicationScheduleItem:MedicationScheduleItem in _record.medicationScheduleItemsModel.medicationScheduleItems)
			{
				var medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(dateStart,
																																				dateEnd);
				for each (var medicationScheduleItemOccurrence:ScheduleItemOccurrence in medicationScheduleItemOccurrencesVector)
				{
					medicationScheduleItemOccurrence.scheduleItem = medicationScheduleItem;
					scheduleItemOccurrences.push(medicationScheduleItemOccurrence);
				}
			}
			return scheduleItemOccurrences;
		}

		private function getEquipmentScheduleItemOccurrencesForYesterday():Vector.<ScheduleItemOccurrence>
		{
			var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			var dateNow:Date = _currentDateSource.now();
			var dateStart:Date = new Date(new Date(dateNow.getFullYear(), dateNow.getMonth(),
												   dateNow.getDate()).valueOf() - (24 * 60 * 60 * 1000));
			var dateEnd:Date = new Date(new Date(dateNow.getFullYear(), dateNow.getMonth(), dateNow.getDate(), 23,
												 59).valueOf() - (24 * 60 * 60 * 1000));
			for each (var equipmentScheduleItem:EquipmentScheduleItem in _record.equipmentScheduleItemsModel.equipmentScheduleItems)
			{
				var equipmentScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = equipmentScheduleItem.getScheduleItemOccurrences(dateStart,
																																			  dateEnd);
				for each (var equipmentScheduleItemOccurrence:ScheduleItemOccurrence in equipmentScheduleItemOccurrencesVector)
				{
					equipmentScheduleItemOccurrence.scheduleItem = equipmentScheduleItem;
					scheduleItemOccurrences.push(equipmentScheduleItemOccurrence);
				}
			}
			return scheduleItemOccurrences;
		}

		private function wasAdherentToScheduleItemOccurrence(scheduleItemOccurrence:ScheduleItemOccurrence):Boolean
		{
			for each (var adherenceItem:AdherenceItem in scheduleItemOccurrence.scheduleItem.adherenceItems)
			{
				if (adherenceItem.recurrenceIndex == scheduleItemOccurrence.recurrenceIndex && adherenceItem.adherence)
				{
					return true;
				}
			}
			return false;
		}

		public function get timingState():String
		{
			return _timingState;
		}

		public function set timingState(value:String):void
		{
			_timingState = value;
		}

		public function get duringScheduleGroup():ScheduleGroup
		{
			return _duringScheduleGroup;
		}

		public function set duringScheduleGroup(value:ScheduleGroup):void
		{
			_duringScheduleGroup = value;
		}

		public function get medicationAdherenceReported():Boolean
		{
			return _medicationAdherenceReported;
		}

		public function set medicationAdherenceReported(value:Boolean):void
		{
			_medicationAdherenceReported = value;
		}

		/**
		 * True if all scheduled medications for the applicable schedule groups have been administered. False if any or all of them
		 * have not been administered. The applicable schedule groups are either (a) all schedule groups from yesterday if the current time is before the
		 * first schedule group or (b) all schedule groups from today that start before the current time.
		 */
		public function get medicationAdherenceState():Boolean
		{
			return _medicationAdherenceState;
		}

		public function set medicationAdherenceState(value:Boolean):void
		{
			_medicationAdherenceState = value;
		}

		public function get bloodPressureReported():Boolean
		{
			return _bloodPressureReported;
		}

		public function set bloodPressureReported(value:Boolean):void
		{
			_bloodPressureReported = value;
		}

		public function get systolicValue():int
		{
			return _systolicValue;
		}

		public function set systolicValue(value:int):void
		{
			_systolicValue = value;
		}

		public function get diastolicValue():int
		{
			return _diastolicValue;
		}

		public function set diastolicValue(value:int):void
		{
			_diastolicValue = value;
		}

		public function get bloodPressureState():String
		{
			return _bloodPressureState;
		}

		public function set bloodPressureState(value:String):void
		{
			_bloodPressureState = value;
		}
	}
}
