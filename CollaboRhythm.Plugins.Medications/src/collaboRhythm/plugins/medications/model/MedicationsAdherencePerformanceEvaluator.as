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

		public static const ALL_ABOVE_GOAL_ASSERTION:String = "All of your medications are above goal concentration.";
		public static const SOME_ABOVE_GOAL_ASSERTION:String = "Some of your medications are above goal concentration.";
		public static const ONE_ABOVE_GOAL_ASSERTION:String = "is above goal concentration.";

		public static const ALL_BELOW_GOAL_ASSERTION:String = "All of your medications are below goal concentration.";
		public static const SOME_BELOW_GOAL_ASSERTION:String = "Some of your medications are below goal concentration.";
		public static const ONE_BELOW_GOAL_ASSERTION:String = "is below goal concentration.";

		private static const ALL_OF_YOUR_MEDICATIONS:String = "all of your medications";
		private static const THESE_MEDICATIONS:String = "these medications";
		private static const THIS_MEDICATION:String = "this medication";

		public static const ALL_WITHIN_GOAL_ASSERTION:String = "All of your medications are within goal concentration.";

		public static const NO_CONCENTRATIONS_AVAILABLE_ASSERTION:String = "No medication concentrations are available";

		public static const NO_MEDICATION_SCHEDULE_ITEM_OCCURRENCES_ASSERTION:String = "You don't have any scheduled medications";

		private var _numberOfMedications:int;
		private var _medicationsBelowGoal:Vector.<String>;
		private var _medicationsWithinGoal:Vector.<String>;
		private var _medicationsAboveGoal:Vector.<String>;

		public function MedicationsAdherencePerformanceEvaluator()
		{
			super(SCHEDULE_ITEM_TYPE);
		}


		private static const CONCENTRATION:String = "concentration";

		private static const CONCENTRATIONS:String = "concentrations";

		override public function evaluateAdherencePerformance(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
															  record:Record,
															  adherencePerformanceInterval:String):AdherencePerformanceAssertion
		{
			evaluateMedicationConcentrations(record);
			if (_numberOfMedications == 0)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING, NO_CONCENTRATIONS_AVAILABLE_ASSERTION, false);
			}
			else if (_medicationsAboveGoal.length == _numberOfMedications)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 ALL_ABOVE_GOAL_ASSERTION, false);
			}
			else if (_medicationsAboveGoal.length > 1)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 SOME_ABOVE_GOAL_ASSERTION, false);
			}
			else if (_medicationsAboveGoal.length == 1)
			{
				return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.WARNING,
														 "Your " + getSimpleMedicationName(_medicationsAboveGoal[0]) + ONE_ABOVE_GOAL_ASSERTION,
														 false);
			}
			else
			{
				var subAssertion:String;
				if (_medicationsBelowGoal.length == _numberOfMedications)
				{
					subAssertion = createMedicationBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						adherencePerformanceInterval, ALL_OF_YOUR_MEDICATIONS, CONCENTRATIONS);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 ALL_BELOW_GOAL_ASSERTION, false,
															 subAssertion);
				}
				else if (_medicationsBelowGoal.length > 1)
				{
					subAssertion = createMedicationBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						 adherencePerformanceInterval, THESE_MEDICATIONS, CONCENTRATIONS);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 SOME_BELOW_GOAL_ASSERTION, false,
															 subAssertion);
				}
				else if (_medicationsBelowGoal.length == 1)
				{
					subAssertion = createMedicationBelowGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																					   adherencePerformanceInterval, THIS_MEDICATION, CONCENTRATION);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.LIGHTNING,
															 "Your " + getSimpleMedicationName(_medicationsBelowGoal[0]) + ONE_BELOW_GOAL_ASSERTION,
															 false, subAssertion);
				}
				else
				{
					subAssertion = createAllMedicationsWithinGoalSubAssertion(getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector),
																						 adherencePerformanceInterval);
					return new AdherencePerformanceAssertion(AdherencePerformanceAssertion.THUMBS_UP,
															 ALL_WITHIN_GOAL_ASSERTION, true,
															 subAssertion);
				}
			}
		}

		private function createAllMedicationsWithinGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																	adherencePerformanceInterval:String):String
		{
			if (medicationScheduleItemOccurrencesVector.length == 0)
			{
				return NO_MEDICATION_SCHEDULE_ITEM_OCCURRENCES_ASSERTION;
			}
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesVector))
			{
				return "And you have taken all of your scheduled medications " + adherencePerformanceInterval + ". Nice work!";
			}
			else
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "But you have not taken all of your scheduled medications " + adherencePerformanceInterval + ".";

				}
				else
				{
					return "But you did not take all of your scheduled medications " + adherencePerformanceInterval + ".";
				}
			}
		}

		private function createMedicationBelowGoalSubAssertion(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
																  adherencePerformanceInterval:String, numberOfMedicationsText:String, concentrationText:String):String
		{
			if (medicationScheduleItemOccurrencesVector.length == 0)
			{
				return NO_MEDICATION_SCHEDULE_ITEM_OCCURRENCES_ASSERTION;
			}
			var medicationScheduleItemOccurrencesSubsetVector:Vector.<ScheduleItemOccurrence> = getMedicationScheduleItemOccurrenceSubset(medicationScheduleItemOccurrencesVector);
			if (isAdherencePerformancePerfect(medicationScheduleItemOccurrencesSubsetVector))
			{
				return "But you have taken " + numberOfMedicationsText + " as scheduled " + adherencePerformanceInterval + ". Nice work!";
			}
			else
			{
				if (adherencePerformanceInterval == AdherencePerformanceModel.ADHERENCE_PERFORMANCE_INTERVAL_TODAY)
				{
					return "You have not taken " + numberOfMedicationsText + " as scheduled " + adherencePerformanceInterval + ".";
				}
				else
				{
					return "You did not take " + numberOfMedicationsText + " as scheduled " + adherencePerformanceInterval + ".";
				}
			}
		}

		private function getMedicationScheduleItemOccurrenceSubset(medicationScheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>):Vector.<ScheduleItemOccurrence>
		{
			var medicationScheduleItemOccurrencesSubsetVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var medicationScheduleItemOccurrence:ScheduleItemOccurrence in medicationScheduleItemOccurrencesVector)
			{
				if (_medicationsBelowGoal.indexOf(medicationScheduleItemOccurrence.scheduleItem.name.text) != -1)
				{
					medicationScheduleItemOccurrencesSubsetVector.push(medicationScheduleItemOccurrence);
				}
			}
			return medicationScheduleItemOccurrencesSubsetVector
		}

		private function evaluateMedicationConcentrations(record:Record):void
		{
			_medicationsBelowGoal = new Vector.<String>();
			_medicationsWithinGoal = new Vector.<String>();
			_medicationsAboveGoal = new Vector.<String>();

			var medicationComponentAdherenceModelsVector:Vector.<MedicationComponentAdherenceModel> = record.bloodPressureModel.simulation.medications;
			_numberOfMedications = medicationComponentAdherenceModelsVector.length;
			for each (var medicationComponentAdherenceModel:MedicationComponentAdherenceModel in medicationComponentAdherenceModelsVector)
			{
				if (medicationComponentAdherenceModel.concentrationSeverityLevel < 2)
				{
					_medicationsBelowGoal.push(medicationComponentAdherenceModel.name.text);
				}
				else if (medicationComponentAdherenceModel.concentrationSeverityLevel == 2)
				{
					_medicationsWithinGoal.push(medicationComponentAdherenceModel.name.text);
				}
				else
				{
					_medicationsAboveGoal.push(medicationComponentAdherenceModel.name.text);
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