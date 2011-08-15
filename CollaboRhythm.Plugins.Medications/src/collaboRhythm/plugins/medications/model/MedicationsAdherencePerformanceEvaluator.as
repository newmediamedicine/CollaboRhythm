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
package collaboRhythm.plugins.medications.model
{

	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceAssertion;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class MedicationsAdherencePerformanceEvaluator extends AdherencePerformanceEvaluatorBase
	{
		public static const SCHEDULE_ITEM_TYPE:String = "http://indivo.org/vocab/xml/documents#MedicationScheduleItem";

		public static const MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_YESTERDAY:String = "You took all of your scheduled blood pressure medications yesterday.";
		public static const MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_TODAY:String = "You have taken all of your scheduled blood pressure medications today.";
		public static const MEDICATIONS_NONADHERENCE_ASSERTION_YESTERDAY:String = "You did not take all of your scheduled blood pressure medications yesterday.";
		public static const MEDICATIONS_NONADHERENCE_ASSERTION_TODAY:String = "You have not taken all of your scheduled blood pressure medications today.";
		public static const MEDICATIONS_NONE_SCHEDULED_ASSERTION:String = "You do not have any scheduled blood pressure medications to take";

		public function MedicationsAdherencePerformanceEvaluator()
		{
			super(SCHEDULE_ITEM_TYPE);
		}

		override public function evaluateAdherencePerformance(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																 record:Record,
																 adherencePerformanceInterval:String):AdherencePerformanceAssertion
		{
			var medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector);
			if (medicationScheduleItemOccurrencesVector.length > 0)
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesVector))
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.THUMBS_UP, MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_TODAY, true);
					}
					else
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING, MEDICATIONS_NONADHERENCE_ASSERTION_TODAY, false);
					}
				}
				else if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY)
				{
					if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesVector))
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.THUMBS_UP, MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_YESTERDAY, true);
					}
					else
					{
						return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING, MEDICATIONS_NONADHERENCE_ASSERTION_YESTERDAY, false);
					}
				}
			}
			return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING, MEDICATIONS_NONE_SCHEDULED_ASSERTION, false);
		}
	}
}
