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
package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.shared.apps.healthCharts.model.*;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	public class HealthChartsInitializationService extends DocumentStorageServiceBase
	{
		private var _record:Record;


		public function HealthChartsInitializationService(consumerKey:String, consumerSecret:String, baseURL:String,
																  account:Account, debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, null,
				  null, null);
		}


		override public function loadDocuments(record:Record):void
		{
			initializeBloodPressureModel(record);
		}

		override public function closeRecord():void
		{
			_record.healthChartsModel.record = null;
			super.closeRecord();
		}

		/**
		 * Initializes the medication simulation model of the HealthChartsModel for the primary record, and does any
		 * other initialization needed to prepare the HealthChartsModel for use.
		 * @param record
		 */
		private function initializeBloodPressureModel(record:Record):void
		{
			_record = record;
			_record.healthChartsModel = new HealthChartsModel();
			_record.healthChartsModel.record = _record;
			attemptInitializeMedicationSimulationModel();
			BindingUtils.bindSetter(record_isLoadingHandler, record, "isLoading");
		}

		private function record_isLoadingHandler(isLoading:Boolean):void
		{
			attemptInitializeMedicationSimulationModel();
		}

		private function attemptInitializeMedicationSimulationModel():void
		{
			if (isDoneLoading)
			{
				initializeMedicationSimulationModel(record.healthChartsModel.focusSimulation,
													record.medicationAdministrationsModel);
				initializeMedicationSimulationModel(record.healthChartsModel.currentSimulation,
													record.medicationAdministrationsModel);
				initializeVitalSignSimulationModel(record.healthChartsModel.focusSimulation);
				initializeVitalSignSimulationModel(record.healthChartsModel.currentSimulation);
			}
		}

		private function initializeVitalSignSimulationModel(simulation:SimulationModel):void
		{
			for each (var vitalSignKey:String in record.vitalSignsModel.vitalSignsByCategory.keys)
			{
				var vitalSigns:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[vitalSignKey];

				if (vitalSigns && vitalSigns.length > 0)
				{
					simulation.addVitalSign(vitalSigns[vitalSigns.length - 1]);
				}
			}
		}

		public function get isDoneLoading():Boolean
		{
			return !record.isLoading && record.medicationAdministrationsModel && record.medicationAdministrationsModel.isInitialized;
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
			if (!simulation.isInitialized)
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

							simulation.addMedication(medication);
						}
					}
				}
				simulation.isInitialized = true;
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
					concentrationSeverityProvider = bidConcentrationSeverityProvider;
					break;
				case "866427":
					drugClass = SimulationModel.BETA_BLOCKER;
					stepsProvider = afterloadAndContractilityStepsProvider;
					concentrationSeverityProvider = qdConcentrationSeverityProvider;
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
			{
				medication.concentrationSeverityProvider = concentrationSeverityProvider;
				medication.goalConcentrationMinimum = concentrationSeverityProvider.concentrationRanges[1];
				medication.goalConcentrationMaximum = concentrationSeverityProvider.concentrationRanges[2];
				medication.concentrationAxisMaximum = concentrationSeverityProvider.concentrationRanges[3];
			}

			// TODO: find a more robust way to get a medicationScheduleItem without depending on an AdherenceItem
			medication.medicationScheduleItem = getMedicationScheduleItem(medication.name.value);
		}

		private function getMedicationScheduleItem(medicationCode:String):MedicationScheduleItem
		{
			var adherenceItemsCollection:ArrayCollection = record.adherenceItemsModel.adherenceItemsCollectionsByCode.getItem(medicationCode);
			if (adherenceItemsCollection)
			{
				for each (var adherenceItem:AdherenceItem in adherenceItemsCollection)
				{
					var medicationScheduleItem:MedicationScheduleItem = adherenceItem.scheduleItem as MedicationScheduleItem;
					if (medicationScheduleItem)
					{
						return medicationScheduleItem;
					}
				}
			}

			for each (medicationScheduleItem in record.medicationScheduleItemsModel.documents)
			{
				if (medicationScheduleItem.name.value == medicationCode)
				{
					return medicationScheduleItem;
				}
			}

			return null;
		}


		private function get qdConcentrationSeverityProvider():ConcentrationSeverityProvider
		{
			return new ConcentrationSeverityProvider(SimulationModel.qdConcentrationRanges,
													 SimulationModel.concentrationColors);
		}

		private function get bidConcentrationSeverityProvider():ConcentrationSeverityProvider
		{
			return new ConcentrationSeverityProvider(SimulationModel.bidConcentrationRanges,
													 SimulationModel.concentrationColors);
		}

		private function get preloadReducerStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
									 new <Vector.<String>>[
										 new <String>[
											 "Less salt and urine output",
											 "More blood in veins (blue)",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "Less salt and urine output",
											 "More blood volume",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "More salt and urine output",
											 "Less blood volume",
											 "Less work for your heart",
											 "Decreased blood pressure"]]);
		}

		private function get preloadAndAfterloadStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
									 new <Vector.<String>>[
										 new <String>[
											 "Less salt and urine output",
											 "More blood in veins (blue)",
											 "More constricted arteries (red)",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "Less salt and urine output",
											 "More blood in veins (blue)",
											 "More constricted arteries (red)",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "More salt and urine output",
											 "Less blood in veins (blue)",
											 "Less constricted arteries (red)",
											 "Less work for your heart",
											 "Decreased blood pressure"]]);
		}

		private function get afterloadAndContractilityStepsProvider():StepsProvider
		{
			return new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
									 new <Vector.<String>>[
										 new <String>[
											 "Harder contractions of heart",
											 "More constricted arteries (red)",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "Harder contractions of heart",
											 "More constricted arteries (red)",
											 "More work for your heart",
											 "Increased blood pressure"],
										 new <String>[
											 "Softer contractions of heart",
											 "Less constricted arteries (red)",
											 "Less work for your heart",
											 "Decreased blood pressure"]]);
		}

		protected function get record():Record
		{
			return _record;
		}
	}
}