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
	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	public class MedicationsAdherencePerformanceEvaluator extends AdherencePerformanceEvaluatorBase
	{
		public static const SCHEDULE_ITEM_TYPE:String = "http://indivo.org/vocab/xml/documents#MedicationScheduleItem";

		public static const MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_ALL:String = "All of your medications are above goal concentration.";
		public static const MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_SOME:String = "Some of your medications are above goal concentration.";
		public static const MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_ONE:String = "is above goal concentration.";

		public static const MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_ALL:String = "All of your medications are below goal concentration.";
		public static const MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_SOME:String = "Some of your medications are below goal concentration.";
		public static const MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_ONE:String = "is below goal concentration.";

		public static const MEDICATION_CONCENTRATION_WITHIN_GOAL_ALL:String = "All of your medications are within goal concentration.";

		public static const MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_YESTERDAY:String = "You took all of your scheduled blood pressure medications yesterday.";
		public static const MEDICATIONS_ADHERENCE_PERFECT_ASSERTION_TODAY:String = "You have taken all of your scheduled blood pressure medications today.";
		public static const MEDICATIONS_NONADHERENCE_ASSERTION_YESTERDAY:String = "You did not take all of your scheduled blood pressure medications yesterday.";
		public static const MEDICATIONS_NONADHERENCE_ASSERTION_TODAY:String = "You have not taken all of your scheduled blood pressure medications today.";
		public static const MEDICATIONS_NONE_SCHEDULED_ASSERTION:String = "You do not have any scheduled blood pressure medications to take";

		private var _numberOfMedications:int;
		private var _medicationsBelowGoal:Vector.<CodedValue>;
		private var _medicationsWithinGoal:Vector.<CodedValue>;
		private var _medicationsAboveGoal:Vector.<CodedValue>;

		public function MedicationsAdherencePerformanceEvaluator()
		{
			super(SCHEDULE_ITEM_TYPE);
		}

		override public function evaluateAdherencePerformance(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
															  record:Record,
															  adherencePerformanceInterval:String):AdherencePerformanceAssertion
		{
			evaluateMedicationConcentrations(record);
			if (_medicationsAboveGoal.length == _numberOfMedications)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_ALL, false);
			}
			else if (_medicationsAboveGoal.length > 1)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_SOME, false);
			}
			else if (_medicationsAboveGoal.length == 1)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 "Your " + getSimpleMedicationName(_medicationsAboveGoal[0].text) + MEDICATION_CONCENTRATION_ABOVE_GOAL_ASSERTION_ONE,
														 false);
			}
			else
			{
				var subAssertion:String;
				if (_medicationsBelowGoal.length == _numberOfMedications)
				{
					subAssertion = createAllMedicationsBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						adherencePerformanceInterval);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_ALL, false,
															 subAssertion);
				}
				else if (_medicationsBelowGoal.length > 1)
				{
					subAssertion = createSomeMedicationsBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						 adherencePerformanceInterval);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_SOME, false,
															 subAssertion);
				}
				else if (_medicationsBelowGoal.length == 1)
				{
					subAssertion = createOneMedicationBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																					   adherencePerformanceInterval);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 "Your " + getSimpleMedicationName(_medicationsBelowGoal[0].text) + MEDICATION_CONCENTRATION_BELOW_GOAL_ASSERTION_ONE,
															 false, subAssertion);
				}
				else
				{
					subAssertion = createAllMedicationsWithinGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						 adherencePerformanceInterval);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.THUMBS_UP,
															 MEDICATION_CONCENTRATION_WITHIN_GOAL_ALL, true,
															 subAssertion);
				}
			}
		}

		private function createAllMedicationsWithinGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																	adherencePerformanceInterval:String):String
		{
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesVector))
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "And you have taken all of your scheduled medications " + adherencePerformanceInterval + ". Nice work!";
				}
				else
				{
					return "And you took all of your scheduled medications " + adherencePerformanceInterval + ". Nice work!";
				}
			}
			else
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "But you have not taken all of your scheduled medications " + adherencePerformanceInterval + ". The concentrations will fall.";

				}
				else
				{
					return "But you did not take all of your scheduled medications " + adherencePerformanceInterval + ". The concentrations will fall.";
				}
			}
		}

		private function createOneMedicationBelowGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																  adherencePerformanceInterval:String):String
		{
			var medicationScheduleItemOccurrencesSubsetVector:Vector.<ScheduleItemOccurrence> = getMedicationScheduleItemOccurrenceSubset(medicationScheduleItemOccurrencesVector);
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesSubsetVector))
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "But you have taken this medication as scheduled " + adherencePerformanceInterval + ". The concentration will rise.";
				}
				else
				{
					return "But you took this medication as scheduled " + adherencePerformanceInterval + ". The concentration will rise.";
				}
			}
			else
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "And you have not taken this medication as scheduled " + adherencePerformanceInterval + ". The concentration will stay low.";
				}
				else
				{
					return "And you did not take this medication as scheduled " + adherencePerformanceInterval + ". The concentration will stay low.";
				}
			}
		}

		private function createSomeMedicationsBelowGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																	adherencePerformanceInterval:String):String
		{
			var medicationScheduleItemOccurrencesSubsetVector:Vector.<ScheduleItemOccurrence> = getMedicationScheduleItemOccurrenceSubset(medicationScheduleItemOccurrencesVector);
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesSubsetVector))
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "But you have taken these medications as scheduled " + adherencePerformanceInterval + ". The concentrations will rise.";
				}
				else
				{
					return "But you took these medications as scheduled " + adherencePerformanceInterval + ". The concentrations will rise.";
				}
			}
			else
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "And you have not taken these medications as scheduled " + adherencePerformanceInterval + ". The concentrations will stay low.";
				}
				else
				{
					return "And you did not take these medications as scheduled " + adherencePerformanceInterval + ". The concentrations will stay low.";
				}
			}
		}

		private function createAllMedicationsBelowGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																   adherencePerformanceInterval:String):String
		{
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesVector))
			{
				return "But you took all of your scheduled medications " + adherencePerformanceInterval + ". The concentrations will rise.";
			}
			else
			{
				return "And you have not taken all of your scheduled medications " + adherencePerformanceInterval + ". The concentrations will stay low.";
			}
		}

		private function getMedicationScheduleItemOccurrenceSubset(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>):Vector.<ScheduleItemOccurrence>
		{
			var medicationScheduleItemOccurrencesSubsetVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var medicationScheduleItemOccurrence:ScheduleItemOccurrence in medicationScheduleItemOccurrencesVector)
			{
				if (_medicationsBelowGoal.indexOf(medicationScheduleItemOccurrence.scheduleItem.name) != -1)
				{
					medicationScheduleItemOccurrencesSubsetVector.push(medicationScheduleItemOccurrence);
				}
			}
			return medicationScheduleItemOccurrencesSubsetVector
		}

		private function evaluateMedicationConcentrations(record:Record):void
		{
			_medicationsBelowGoal = new Vector.<CodedValue>();
			_medicationsWithinGoal = new Vector.<CodedValue>();
			_medicationsAboveGoal = new Vector.<CodedValue>();

			var medicationComponentAdherenceModelsVector:Vector.<MedicationComponentAdherenceModel> = record.bloodPressureModel.simulation.medications;
			_numberOfMedications = medicationComponentAdherenceModelsVector.length;
			for each (var medicationComponentAdherenceModel:MedicationComponentAdherenceModel in medicationComponentAdherenceModelsVector)
			{
				if (medicationComponentAdherenceModel.concentrationSeverityLevel < 2)
				{
					_medicationsBelowGoal.push(medicationComponentAdherenceModel.name);
				}
				else if (medicationComponentAdherenceModel.concentrationSeverityLevel == 2)
				{
					_medicationsWithinGoal.push(medicationComponentAdherenceModel.name);
				}
				else
				{
					_medicationsAboveGoal.push(medicationComponentAdherenceModel.name);
				}
			}
		}

		private function getSimpleMedicationName(nameString:String):String
		{
			var medicationName:MedicationName = MedicationNameUtil.parseName(nameString);
			return medicationName.medicationName;
		}
	}
}
