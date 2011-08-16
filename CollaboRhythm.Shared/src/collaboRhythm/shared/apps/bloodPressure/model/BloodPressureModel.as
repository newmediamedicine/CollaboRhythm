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
package collaboRhythm.shared.apps.bloodPressure.model
{

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.derived.MedicationConcentrationSample;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import j2as3.collection.HashMap;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class BloodPressureModel
	{
		private var _record:Record;
		private var _currentDateSource:ICurrentDateSource;
		private var _adherenceDataCollection:ArrayCollection;
		private var _showFps:Boolean;
		private var _showAdherence:Boolean = true;
		private var _showHeartRate:Boolean = false;
		private var _simulation:SimulationModel = new SimulationModel();

		public static const RXNORM_HYDROCHLOROTHIAZIDE:String = "310798";
		public static const RXNORM_ATENOLOL:String = "197381";
		private var _isInitialized:Boolean;

		public function get simulation():SimulationModel
		{
			return _simulation;
		}

		public function set simulation(value:SimulationModel):void
		{
			_simulation = value;
		}

		public function get showHeartRate():Boolean
		{
			return _showHeartRate;
		}

		public function get showAdherence():Boolean
		{
			return _showAdherence;
		}

		public function get showFps():Boolean
		{
			return _showFps;
		}

		public function set showFps(value:Boolean):void
		{
			_showFps = value;
		}


		public function get adherenceDataCollection():ArrayCollection
		{
			return _adherenceDataCollection;
		}

		public function set adherenceDataCollection(value:ArrayCollection):void
		{
			_adherenceDataCollection = value;
		}

		public function initializeSimulationModel():void
		{
			if (isAdherenceLoaded && isSystolicReportLoaded && isDiastolicReportLoaded)
			{
				_simulation.date = _currentDateSource.now();

				for each (var medication:MedicationComponentAdherenceModel in _simulation.medications)
				{
					if (record.medicationAdministrationsModel.hasMedicationConcentrationCurve(medication.name.value))
					{
						var medicationConcentrationCurve:ArrayCollection = record.medicationAdministrationsModel.medicationConcentrationCurvesByCode[medication.name.value];
						var medicationConcentrationSample:MedicationConcentrationSample = medicationConcentrationCurve[medicationConcentrationCurve.length - 1];

						_simulation.dataPointDate = medicationConcentrationSample.date;
						medication.concentration = medicationConcentrationSample.concentration;
					}
				}

				if (record.vitalSignsModel.isInitialized && record.vitalSignsModel.hasCategory(VitalSignsModel.SYSTOLIC_CATEGORY))
				{
					var systolicCollection:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
					var systolicVitalSign:VitalSign = systolicCollection[systolicCollection.length - 1];
					_simulation.systolic = systolicVitalSign.resultAsNumber;
				}

				if (record.vitalSignsModel.isInitialized && record.vitalSignsModel.hasCategory(VitalSignsModel.DIASTOLIC_CATEGORY))
				{
					var diastolicCollection:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];
					var diastolicVitalSign:VitalSign = diastolicCollection[diastolicCollection.length - 1];
					_simulation.diastolic = diastolicVitalSign.resultAsNumber;
				}

				_simulation.mode = SimulationModel.MOST_RECENT_MODE;
			}
		}

		public function BloodPressureModel()
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function get isAdherenceLoaded():Boolean
		{
			return record && record.adherenceItemsModel && record.adherenceItemsModel.isInitialized &&
					record.medicationAdministrationsModel && record.medicationAdministrationsModel.isInitialized;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function get isSystolicReportLoaded():Boolean
		{
			return record.vitalSignsModel.isInitialized;
		}

		public function get isDiastolicReportLoaded():Boolean
		{
			return record.vitalSignsModel.isInitialized;
		}

		public function get isDoneLoading():Boolean
		{
			return !record.isLoading;
		}

		public function set currentDateSource(value:ICurrentDateSource):void
		{
			_currentDateSource = value;
		}

		public function set showAdherence(value:Boolean):void
		{
			_showAdherence = value;
		}

		public function set showHeartRate(value:Boolean):void
		{
			_showHeartRate = value;
		}

		private function updateModel():void
		{
			initializeSimulationModel();
		}

		public function get adherenceItemsCollectionsByCode():HashMap
		{
			return record.adherenceItemsModel.adherenceItemsCollectionsByCode;
		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			isInitialized = false;
			showAdherence = false;

			_record = value;
			if (record)
			{
				showAdherence = determineShowAdherence();
				isInitialized = determineIsInitialized();
				BindingUtils.bindSetter(medicationAdministrationsModel_isInitialized_setterHandler,
										record.medicationAdministrationsModel, "isInitialized");
				BindingUtils.bindSetter(adherenceItemsModel_isInitialized_setterHandler, record.adherenceItemsModel,
										"isInitialized");
				BindingUtils.bindSetter(vitalSignModel_isInitialized_setterHandler, record.vitalSignsModel,
										"isInitialized");
				BindingUtils.bindSetter(record_isLoading_setterHandler, record,
										"isLoading");
				BindingUtils.bindSetter(simulation_isInitialized_setterHandler, simulation, "isInitialized")
			}
			else
			{
				// TODO: unbind or use weak references
			}
		}

		private function simulation_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function record_isLoading_setterHandler(isLoading:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function vitalSignModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function determineIsInitialized():Boolean
		{
			return isAdherenceLoaded && isSystolicReportLoaded && isDiastolicReportLoaded && isDoneLoading && isSimulationModelInitialized;
		}

		private function get isSimulationModelInitialized():Boolean
		{
			return simulation && simulation.isInitialized;
		}

		private function medicationAdministrationsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			showAdherence = determineShowAdherence();
			this.isInitialized = determineIsInitialized();
		}

		private function adherenceItemsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			showAdherence = determineShowAdherence();
			this.isInitialized = determineIsInitialized();
		}

		private function determineShowAdherence():Boolean
		{
			return (record.medicationAdministrationsModel.isInitialized && record.adherenceItemsModel.isInitialized) &&
					record.medicationAdministrationsModel.medicationAdministrationsCollection.length > 0 || record.adherenceItemsModel.adherenceItems.size() > 0;
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}

		public function get systolicData():ArrayCollection
		{
			return record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
		}

		public function get diastolicData():ArrayCollection
		{
			return record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];
		}

		public function get medicationConcentrationCurvesByCode():HashMap
		{
			return record.medicationAdministrationsModel.medicationConcentrationCurvesByCode;
		}
		
		public function set medicationConcentrationCurvesByCode(value:HashMap):void
		{
			throw new Error("Property is read-only. Setter exists to facilitate data binding.");
		}
	}
}