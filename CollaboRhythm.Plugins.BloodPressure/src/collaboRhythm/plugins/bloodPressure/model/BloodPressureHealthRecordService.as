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
package collaboRhythm.plugins.bloodPressure.model
{

	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.apps.bloodPressure.model.ConcentrationSeverityProvider;
	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;
	import collaboRhythm.shared.apps.bloodPressure.model.StepsProvider;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	public class BloodPressureHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _record:Record;

		public function BloodPressureHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		/**
		 * Initializes the medication simulation model of the BloodPressureModel for the primary record, and does any
		 * other initialization needed to prepare the BloodPressureModel for use.
		 * @param recordAccount
		 */
		public function initializeBloodPressureModel(recordAccount:Account):void
		{
			_record = recordAccount.primaryRecord;

			if (record.medicationAdministrationsModel.isInitialized)
			{
				initializeMedicationSimulationModel(record.bloodPressureModel.simulation, record.medicationAdministrationsModel);
			}

			BindingUtils.bindSetter(medicationAdministrationsModelInitializedHandler, record.medicationAdministrationsModel, "isInitialized");
		}

		private function medicationAdministrationsModelInitializedHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
			{
				initializeMedicationSimulationModel(record.bloodPressureModel.simulation, record.medicationAdministrationsModel);
			}
		}

		/**
		 * Initializes the SimulationModel with instances of MedicationComponentAdherenceModel corresponding to all of the
		 * medications for which there are MedicationAdministration instances.
		 *
		 * @param simulation The simulation model to initialize.
		 * @param medicationAdministrationsModel The model to use to initialize from.
		 */
		private function initializeMedicationSimulationModel(simulation:SimulationModel,
															 medicationAdministrationsModel:MedicationAdministrationsModel):void
		{
			for each (var medicationAdministrationCollection:ArrayCollection in medicationAdministrationsModel.medicationAdministrationsCollectionsByCode)
			{
				if (medicationAdministrationCollection.length > 0)
				{
					var medicationAdministration:MedicationAdministration = medicationAdministrationCollection[0];
					var name:CodedValue = medicationAdministration.name;

					var index:int = simulation.medicationsByCode.getIndexByKey(name.value);
					if (index == -1)
					{
						var medication:MedicationComponentAdherenceModel = new MedicationComponentAdherenceModel();

						medication.name = name;
						initializeMedication(medication);

						// TODO: get steps from an external source
//						if (name.value == BloodPressureModel.RXNORM_HYDROCHLOROTHIAZIDE)
//						{
//							initializeHydrochlorothiazideModel(medication);
//						}
//						else if (name.value == BloodPressureModel.RXNORM_ATENOLOL)
//						{
//							initializeAtenololModel(medication);
//						}

						simulation.addMedication(medication);
					}
				}
			}
		}

		private function initializeMedication(medication:MedicationComponentAdherenceModel):void
		{
			var drugClass:String;
			var stepsProvider:StepsProvider;
			var concentrationSeverityProvider:ConcentrationSeverityProvider;
			switch (medication.name.value)
			{
				case "310798":
				case "429503":
					drugClass = SimulationModel.THIAZIDE_DIURETIC;
					stepsProvider = preloadReducerStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				case "866511":
				case "866924":
				case "866429":
					drugClass = SimulationModel.BETA_BLOCKER;
					stepsProvider = afterloadAndContractilityStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				case "866427":
					drugClass = SimulationModel.BETA_BLOCKER;
					stepsProvider = afterloadAndContractilityStepsProvider;
					concentrationSeverityProvider = bidConcentrationSeverityProvider;
					break;
				case "979487":
				case "979492":
					drugClass = SimulationModel.ANGIOTENSIN_RECEPTOR_BLOCKER;
					stepsProvider = preloadAndAfterloadStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				case "212575":
				case "212549":
				case "830837":
					drugClass = SimulationModel.CALCIUM_CHANNEL_BLOCKER;
					stepsProvider = afterloadAndContractilityStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				case "197628":
					drugClass = SimulationModel.ALPHA_BLOCKER;
					stepsProvider = afterloadAndContractilityStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				case "104375":
				case "206766":
					drugClass = SimulationModel.ACE_INHIBITOR;
					stepsProvider = preloadAndAfterloadStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
					break;
				default:
					drugClass = SimulationModel.DRUG_CLASS_UNKNOWN;
			}
			medication.drugClass = drugClass;
			if (stepsProvider)
				medication.stepsProvider = stepsProvider;
			if (concentrationSeverityProvider)
				medication.concentrationSeverityProvider = concentrationSeverityProvider;
		}

		private function get qdConcentrationSeverityProvider():ConcentrationSeverityProvider
		{
			return new ConcentrationSeverityProvider(SimulationModel.qdConcentrationRanges, SimulationModel.concentrationColors);
		}

		private function get bidConcentrationSeverityProvider():ConcentrationSeverityProvider
		{
			return new ConcentrationSeverityProvider(SimulationModel.bidConcentrationRanges, SimulationModel.concentrationColors);
		}

		private function get preloadReducerStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "Less salt in urine",
																"Less urine output",
																 "More salt in blood",
																 "More blood volume",
															 	 "More work for your heart",
															 	 "Increased blood pressure"],
															 new <String>[
																 "Less salt in urine",
																"Less urine output",
																 "More salt in blood",
																 "More blood volume",
															 	 "More work for your heart",
															 	 "Increased blood pressure"],
															 new <String>[
																 "More salt in urine",
																"More urine output",
																 "Less salt in blood",
																 "Less blood volume",
															 	 "Less work for your heart",
															 	 "Decreased blood pressure"]]);
		}

		private function get preloadAndAfterloadStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																	 "More blood volume",
																 "More constricted arteries",
																"More work for heart",
															 	 "Increased blood pressure"],
															 new <String>[
																	 "More blood volume",
																 "More constricted arteries",
																"More work for heart",
															 	 "Increased blood pressure"],
															 new <String>[
																	 "Less blood volume",
																 "Less constricted arteries",
																"Less work for heart",
															 	 "Decreased blood pressure"]]);
		}

		private function get afterloadAndContractilityStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "More constricted arteries",
																"More work for heart",
															 	 "Increased blood pressure"],
															 new <String>[
																 "More constricted arteries",
																"More work for heart",
															 	 "Increased blood pressure"],
															 new <String>[
																 "Less constricted arteries",
																"Less work for heart",
															 	 "Decreased blood pressure"]]);
		}

		private function initializeHydrochlorothiazideModel(medication:MedicationComponentAdherenceModel):void
		{
//			medication.drugClass = SimulationModel.THIAZIDE_DIURETIC;
			medication.stepsProvider = new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "Urine volume decreased",
																 "Venous blood volume increased",
																 "Preload on heart increased",
															 	 "Stroke volume of heart increased",
															 	 "Blood pressure increased"],
															 new <String>[
																 "Urine volume increased",
																 "Venous blood volume decreased",
																 "Preload on heart decreased",
															 	 "Stroke volume of heart decreased",
															 	 "Blood pressure decreased"],
															 new <String>[
																 "Urine volume increased",
																 "Venous blood volume decreased",
																 "Preload on heart decreased",
															 	 "Stroke volume of heart decreased",
															 	 "Blood pressure decreased"]]);
			medication.concentrationSeverityProvider = new ConcentrationSeverityProvider(SimulationModel.concentrationRanges,
																						 SimulationModel.concentrationColors);
		}

		private function initializeAtenololModel(medication:MedicationComponentAdherenceModel):void
		{
//			medication.drugClass = SimulationModel.BETA_BLOCKER;
			medication.stepsProvider = new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "Atenolol very low step 1",
																 "Atenolol very low step 2",
																 "Atenolol very low step 3",
																 "Atenolol very low step 4",
																 "Atenolol very low step 5"
															 	 ],
															 new <String>[
																 "Atenolol low step 1",
																 "Atenolol low step 2",
																 "Atenolol low step 3",
															 	 "Atenolol low step 4",
															 	 "Atenolol low step 5"
															 	 ],
															 new <String>[
																 "Atenolol at goal step 1",
																 "Atenolol at goal step 2",
																 "Atenolol at goal step 3",
															 	 "Atenolol at goal step 4",
															 	 "Atenolol at goal step 5"]]);
			medication.concentrationSeverityProvider = new ConcentrationSeverityProvider(SimulationModel.concentrationRanges,
																						 SimulationModel.concentrationColors);
		}

//		private function datesAreClose(date1:Date, date2:Date):Boolean
//		{
//			return (Math.abs(date1.time - date2.time) < millisecondsPerHour * 12);
//		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			_record = value;
		}
	}
}