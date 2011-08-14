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
package collaboRhythm.plugins.equipment.model
{
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;

	import mx.collections.ArrayCollection;

	public class EquipmentAdherencePerformanceEvaluator extends AdherencePerformanceEvaluatorBase
	{
		public static const SCHEDULE_ITEM_TYPE:String = "http://indivo.org/vocab/xml/documents#EquipmentScheduleItem";

		public static const BLOOD_PRESSURE_NONADHERENCE_ASSERTION_YESTERDAY:String = "You did not take your scheduled blood pressure yesterday.";
		public static const BLOOD_PRESSURE_NONADHERENCE_ASSERTION_TODAY:String = "You have not taken your schedule blood pressure today.";
		public static const BLOOD_PRESSURE_NOT_AVAILABLE_ASSERTION:String = "You do not have any blood pressures available.";
		public static const BLOOD_PRESSURE_VALUE_ASSERTION:String = "Your most recent blood pressure";
		public static const BLOOD_PRESSURE_HYPOTENSION_ASSERTION:String = "was dangerously low";
		public static const BLOOD_PRESSURE_HYPERTENSION_ASSERTION:String = "was dangerously high";
		public static const BLOOD_PRESSURE_ABOVE_GOAL_ASSERTION:String = "was above your goal";
		public static const BLOOD_PRESSURE_WITHIN_GOAL_ASSERTION:String = "was within your goal";

		private static const HYPOTENSION_SYSTOLIC_THRESHOLD:int = 90;
		private static const HYPOTENSION_DIASTOLIC_THRESHOLD:int = 60;
		private static const HYPERTENSION_SYSTOLIC_THRESHOLD:int = 180;
		private static const HYPERTENSION_DIASTOLIC_THRESHOLD:int = 120;
		private static const SYSTOLIC_GOAL:int = 130;

		public function EquipmentAdherencePerformanceEvaluator()
		{
			super(SCHEDULE_ITEM_TYPE);
		}

		override public function evaluateAdherencePerformance(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																 record:Record,
																 adherencePerformanceInterval:String):String
		{
			var equipmentScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector);
			if (equipmentScheduleItemOccurrencesVector.length > 0)
			{
				if (!isAdherencePerformancePerfect(equipmentScheduleItemOccurrencesVector))
				{
					if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
					{
						return BLOOD_PRESSURE_NONADHERENCE_ASSERTION_TODAY;
					}
					else if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY)
					{
						return BLOOD_PRESSURE_NONADHERENCE_ASSERTION_YESTERDAY;
					}
				}
			}
			return determineMostRecentBloodPressureAssertion(record);
		}

		private function determineMostRecentBloodPressureAssertion(record:Record):String
		{
			var mostRecentBloodPressureAssertion:String;

			var systolicBloodPressures:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
			systolicBloodPressures.source.sortOn("dateMeasuredStartValue", Array.DESCENDING);
			var diastolicBloodPressures:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];
			diastolicBloodPressures.source.sortOn("dateMeasuredStartValue", Array.DESCENDING);

			if (systolicBloodPressures.length > 0 && diastolicBloodPressures.length > 0)
			{
				var mostRecentSystolicBloodPressure:VitalSign = systolicBloodPressures[0];
				var mostRecentDiastolicBloodPressure:VitalSign = diastolicBloodPressures[0];
				mostRecentBloodPressureAssertion = createBloodPressureAssertion(mostRecentSystolicBloodPressure,
																				mostRecentDiastolicBloodPressure);
				if (isHypotension(mostRecentSystolicBloodPressure, mostRecentDiastolicBloodPressure))
				{
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_HYPOTENSION_ASSERTION;
				}
				else if (isSevereHypertension(mostRecentSystolicBloodPressure, mostRecentDiastolicBloodPressure))
				{
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_HYPERTENSION_ASSERTION;
				}
				else if (isGreaterThanSystolicGoal(mostRecentSystolicBloodPressure))
				{
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_ABOVE_GOAL_ASSERTION;
				}
				else
				{
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_WITHIN_GOAL_ASSERTION;
				}
			}
			else
			{
				mostRecentBloodPressureAssertion = BLOOD_PRESSURE_NOT_AVAILABLE_ASSERTION;
			}
			return mostRecentBloodPressureAssertion;
		}

		private function createBloodPressureAssertion(mostRecentSystolicBloodPressure:VitalSign,
													  mostRecentDiastolicBloodPressure:VitalSign):String
		{
			return BLOOD_PRESSURE_VALUE_ASSERTION + " (" + mostRecentSystolicBloodPressure + "/" + mostRecentDiastolicBloodPressure + ") ";
		}

		public function isHypotension(systolicBloodPressure:VitalSign,
									   diastolicBloodPressure:VitalSign):Boolean
		{
			return (int(systolicBloodPressure.result.value) < HYPOTENSION_SYSTOLIC_THRESHOLD || int(diastolicBloodPressure.result.value) < HYPOTENSION_DIASTOLIC_THRESHOLD);
		}

		public function isSevereHypertension(systolicBloodPressure:VitalSign,
											  diastolicBloodPressure:VitalSign):Boolean
		{
			return (int(systolicBloodPressure.result.value) > HYPERTENSION_SYSTOLIC_THRESHOLD || int(diastolicBloodPressure.result.value) > HYPERTENSION_DIASTOLIC_THRESHOLD);
		}

		public function isGreaterThanSystolicGoal(systolicBloodPressure:VitalSign):Boolean
		{
			return (int(systolicBloodPressure.result.value) > SYSTOLIC_GOAL);
		}
	}
}
