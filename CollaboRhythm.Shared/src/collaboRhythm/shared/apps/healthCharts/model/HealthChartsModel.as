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
package collaboRhythm.shared.apps.healthCharts.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.derived.MedicationConcentrationSample;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import com.dougmccune.controls.SynchronizedScrollData;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import j2as3.collection.HashMap;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;

	/**
	 * Dispatched when updates to one or more medication concentration curve is complete.
	 */
	[Event(name="updateComplete", type="mx.events.FlexEvent")]

	/**
	 * Dispatched when a change, such as adding or removing a relevant document (VitalSign or AdherenceItem), occurs.
	 */
	[Event(name="change", type="flash.events.Event")]

	[Bindable]
	public class HealthChartsModel extends EventDispatcher
	{
		private var _record:Record;
		private var _currentDateSource:ICurrentDateSource;
		private var _showFps:Boolean;
		private var _showAdherence:Boolean = true;
		private var _showHeartRate:Boolean = false;
		private var _focusSimulation:SimulationModel = new SimulationModel();
		private var _currentSimulation:SimulationModel = new SimulationModel();

		public static const RXNORM_HYDROCHLOROTHIAZIDE:String = "310798";
		public static const RXNORM_ATENOLOL:String = "197381";
		private var _isInitialized:Boolean;
		private var _decisionPending:Boolean = false;
		private var _decisionTitle:String;
		private var _decisionData:Object;
		private var _synchronizedScrollData:SynchronizedScrollData;

		/**
		 * The simulation state corresponding to the time currently being focused on (the time specified by the focus
		 * time marker in the chart).
		 */
		public function get focusSimulation():SimulationModel
		{
			return _focusSimulation;
		}

		public function set focusSimulation(value:SimulationModel):void
		{
			_focusSimulation = value;
		}

		/**
		 * The simulation state corresponding to the most recent (current) data available.
		 */
		public function get currentSimulation():SimulationModel
		{
			return _currentSimulation;
		}

		public function set currentSimulation(value:SimulationModel):void
		{
			_currentSimulation = value;
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

		public function updateSimulationModelToCurrent(targetSimulation:SimulationModel):void
		{
			if (isAdherenceLoaded && isSystolicReportLoaded && isDiastolicReportLoaded)
			{
				targetSimulation.date = _currentDateSource.now();

				for each (var medication:MedicationComponentAdherenceModel in targetSimulation.medications)
				{
					if (record.medicationAdministrationsModel.hasMedicationConcentrationCurve(medication.name.value))
					{
						var medicationConcentrationCurve:ArrayCollection = record.medicationAdministrationsModel.medicationConcentrationCurvesByCode[medication.name.value];
						if (medicationConcentrationCurve.length > 0)
						{
							var medicationConcentrationSample:MedicationConcentrationSample = medicationConcentrationCurve[medicationConcentrationCurve.length -
									1];

							targetSimulation.dataPointDate = medicationConcentrationSample.date;
							medication.concentration = medicationConcentrationSample.concentration;
						}
					}
				}

				for each (var vitalSignKey:String in targetSimulation.vitalSignsByCategory.arrayOfKeys)
				{
					var arrayCollection:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[vitalSignKey];
					if (arrayCollection.length > 0)
					{
						var vitalSign:VitalSign = arrayCollection[arrayCollection.length - 1];
						targetSimulation.updateVitalSignSimulationModel(vitalSign);
					}
				}

				if (record.vitalSignsModel.isInitialized && record.vitalSignsModel.hasCategory(VitalSignsModel.SYSTOLIC_CATEGORY))
				{
					var systolicCollection:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
					if (systolicCollection.length > 0)
					{
						var systolicVitalSign:VitalSign = systolicCollection[systolicCollection.length - 1];
						targetSimulation.systolic = systolicVitalSign.resultAsNumber;
					}
				}

				if (record.vitalSignsModel.isInitialized && record.vitalSignsModel.hasCategory(VitalSignsModel.DIASTOLIC_CATEGORY))
				{
					var diastolicCollection:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.DIASTOLIC_CATEGORY];
					if (diastolicCollection.length > 0)
					{
						var diastolicVitalSign:VitalSign = diastolicCollection[diastolicCollection.length - 1];
						targetSimulation.diastolic = diastolicVitalSign.resultAsNumber;
					}
				}

				targetSimulation.mode = SimulationModel.MOST_RECENT_MODE;
			}
		}

		public function HealthChartsModel()
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
			updateSimulationModelToCurrent(_focusSimulation);
			updateSimulationModelToCurrent(_currentSimulation);
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
				BindingUtils.bindSetter(focusSimulation_isInitialized_setterHandler, focusSimulation, "isInitialized");
				BindingUtils.bindSetter(currentSimulation_isInitialized_setterHandler, currentSimulation, "isInitialized");

				if (record.medicationAdministrationsModel)
					record.medicationAdministrationsModel.addEventListener(FlexEvent.UPDATE_COMPLETE, medicationAdministrationsModel_updateCompleteHandler);
			}
			else
			{
				// TODO: unbind or use weak references
				currentSimulation = null;
				focusSimulation = null;
			}
		}

		private function vitalSignsDocuments_collectionChangeEvent(event:CollectionEvent):void
		{
			if (record.vitalSignsModel.isInitialized && (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE))
			{
				updateSimulationModelToCurrent(_currentSimulation);
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		private function medicationAdministrationsModel_updateCompleteHandler(event:FlexEvent):void
		{
			updateSimulationModelToCurrent(currentSimulation);
			dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
		}

		private function focusSimulation_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function currentSimulation_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function record_isLoading_setterHandler(isLoading:Boolean):void
		{
			this.isInitialized = determineIsInitialized();
		}

		private function vitalSignModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
			{
				var vitalSignsSystolic:ArrayCollection = record.vitalSignsModel.vitalSignsByCategory[VitalSignsModel.SYSTOLIC_CATEGORY];
				if (vitalSignsSystolic)
				{
					vitalSignsSystolic.addEventListener(CollectionEvent.COLLECTION_CHANGE,
														vitalSignsDocuments_collectionChangeEvent);
				}
			}
			this.isInitialized = determineIsInitialized();
		}

		private function determineIsInitialized():Boolean
		{
			return isAdherenceLoaded && isSystolicReportLoaded && isDiastolicReportLoaded && isDoneLoading && isFocusSimulationInitialized && isCurrentSimulationInitialized;
		}

		private function get isFocusSimulationInitialized():Boolean
		{
			return focusSimulation && focusSimulation.isInitialized;
		}

		private function get isCurrentSimulationInitialized():Boolean
		{
			return currentSimulation && currentSimulation.isInitialized;
		}

		private function medicationAdministrationsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			showAdherence = determineShowAdherence();
			this.isInitialized = determineIsInitialized();
		}

		private function adherenceItemsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
				record.adherenceItemsModel.adherenceItems.addEventListener(CollectionEvent.COLLECTION_CHANGE, adherenceItems_collectionChangeHandler);
			showAdherence = determineShowAdherence();
			this.isInitialized = determineIsInitialized();
		}

		private function adherenceItems_collectionChangeHandler(event:CollectionEvent):void
		{
			if (record.adherenceItemsModel.isInitialized && (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE))
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		private function determineShowAdherence():Boolean
		{
			return record && record.medicationAdministrationsModel &&
					(record.medicationAdministrationsModel.isInitialized && record.adherenceItemsModel.isInitialized) &&
					(record.medicationAdministrationsModel.medicationAdministrationsCollection.length > 0 || record.adherenceItemsModel.adherenceItems.size() > 0);
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			if (_isInitialized != value)
			{
				_isInitialized = value;
				if (_isInitialized)
					updateModel();
			}
		}

		public function get systolicData():ArrayCollection
		{
			return record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.SYSTOLIC_CATEGORY);
		}

		public function get diastolicData():ArrayCollection
		{
			return record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.DIASTOLIC_CATEGORY);
		}

		public function get medicationConcentrationCurvesByCode():HashMap
		{
			return record.medicationAdministrationsModel.medicationConcentrationCurvesByCode;
		}
		
		public function set medicationConcentrationCurvesByCode(value:HashMap):void
		{
			throw new Error("Property is read-only. Setter exists to facilitate data binding.");
		}

		public function prepareForDecision(decisionTitle:String,
										   decisionData:Object):void
		{
			_decisionPending = true;
			_decisionTitle = decisionTitle;
			_decisionData = decisionData;
		}

		public function finishedDecision():void
		{
			_decisionPending = false;
		}

		public function get decisionPending():Boolean
		{
			return _decisionPending;
		}

		public function get decisionTitle():String
		{
			return _decisionTitle;
		}

		public function set decisionTitle(value:String):void
		{
			_decisionTitle = value;
		}

		public function get decisionData():Object
		{
			return _decisionData;
		}

		/**
		 * Starts or continues the save process by dispatching an event (generally to the HealthChartsAppController)
		 * signalling that the user wants to save/proceed.
		 */
		public function save():void
		{
			dispatchEvent(new HealthChartsEvent(HealthChartsEvent.SAVE));
		}

		public function getAdherenceItemsCollectionByCode(medicationCode:String):ArrayCollection
		{
			return record.adherenceItemsModel.getAdherenceItemsCollectionByCode(medicationCode);
		}

		public function getMedicationConcentrationCurveByCode(medicationCode:String):ArrayCollection
		{
			return record.medicationAdministrationsModel.getMedicationConcentrationCurveByCode(medicationCode);
		}

		public function set synchronizedScrollData(synchronizedScrollData:SynchronizedScrollData):void
		{
			_synchronizedScrollData = synchronizedScrollData;
		}

		public function get synchronizedScrollData():SynchronizedScrollData
		{
			return _synchronizedScrollData;
		}
	}
}