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

	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceAssertion;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;

	public class EquipmentAdherencePerformanceEvaluator extends AdherencePerformanceEvaluatorBase
	{
		public static const SCHEDULE_ITEM_TYPE:String = "http://indivo.org/vocab/xml/documents#EquipmentScheduleItem";

		public static const BLOOD_PRESSURE_NONADHERENCE_ASSERTION_YESTERDAY:String = "You did not take your scheduled blood pressure yesterday.";
		public static const BLOOD_PRESSURE_NONADHERENCE_ASSERTION_TODAY:String = "You have not taken your scheduled blood pressure today.";
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
																 adherencePerformanceInterval:String):AdherencePerformanceAssertion
		{
			var equipmentScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector);
			if (equipmentScheduleItemOccurrencesVector.length > 0)
			{
				if (!isAdherencePerformancePerfect(equipmentScheduleItemOccurrencesVector))
				{
					if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING, BLOOD_PRESSURE_NONADHERENCE_ASSERTION_TODAY, false);
					}
					else if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY)
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING, BLOOD_PRESSURE_NONADHERENCE_ASSERTION_YESTERDAY, false);
					}
				}
			}
			return determineMostRecentBloodPressureAssertion(record);
		}

		private function determineMostRecentBloodPressureAssertion(record:Record):AdherencePerformanceAssertion
		{
			var mostRecentBloodPressureAssertion:String;

			var systolicBloodPressures:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
			var diastolicBloodPressures:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];

			if (systolicBloodPressures && systolicBloodPressures.length > 0 && diastolicBloodPressures && diastolicBloodPressures.length > 0)
			{
				var mostRecentSystolicBloodPressure:VitalSign = systolicBloodPressures[systolicBloodPressures.length - 1];
				var mostRecentDiastolicBloodPressure:VitalSign = diastolicBloodPressures[diastolicBloodPressures.length - 1];
				mostRecentBloodPressureAssertion = createBloodPressureAssertion(mostRecentSystolicBloodPressure,
																				mostRecentDiastolicBloodPressure);
				var icon:String;
				var valence:Boolean;
				if (isHypotension(mostRecentSystolicBloodPressure, mostRecentDiastolicBloodPressure))
				{
					icon = AdherencePerformanceAssertion.WARNING;
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_HYPOTENSION_ASSERTION;
					valence = false;
				}
				else if (isSevereHypertension(mostRecentSystolicBloodPressure, mostRecentDiastolicBloodPressure))
				{
					icon = AdherencePerformanceAssertion.LIGHTNING;
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_HYPERTENSION_ASSERTION;
					valence = false;
				}
				else if (isGreaterThanSystolicGoal(mostRecentSystolicBloodPressure))
				{
					icon = AdherencePerformanceAssertion.LIGHTNING;
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_ABOVE_GOAL_ASSERTION;
					valence = false;
				}
				else
				{
					icon = AdherencePerformanceAssertion.THUMBS_UP;
					mostRecentBloodPressureAssertion += BLOOD_PRESSURE_WITHIN_GOAL_ASSERTION;
					valence = true;
				}
			}
			else
			{
				icon = AdherencePerformanceAssertion.WARNING;
				mostRecentBloodPressureAssertion = BLOOD_PRESSURE_NOT_AVAILABLE_ASSERTION;
				valence = false;
			}
			return new AdherencePerformanceAssertion(icon, mostRecentBloodPressureAssertion, valence);
		}

		private function createBloodPressureAssertion(mostRecentSystolicBloodPressure:VitalSign,
													  mostRecentDiastolicBloodPressure:VitalSign):String
		{
			return BLOOD_PRESSURE_VALUE_ASSERTION + " (" + mostRecentSystolicBloodPressure.result.value + "/" + mostRecentDiastolicBloodPressure.result.value + ") ";
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
