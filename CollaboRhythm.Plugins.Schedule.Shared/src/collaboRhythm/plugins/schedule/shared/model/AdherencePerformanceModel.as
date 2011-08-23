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

	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.binding.utils.BindingUtils;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class AdherencePerformanceModel
	{
		/**
		 * Key to the CurrentPerformanceModel instance in Record.appData
		 */
		public static const ADHERENCE_PERFORMANCE_MODEL_KEY:String = "adherencePerformanceModel";

		public static const ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY:String = "yesterday";
		public static const ADHERENCE_PERFORMANCE_INTERVAL_TODAY:String = "today";

		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		private var _scheduleCollectionsProvider:IScheduleCollectionsProvider;
		private var _record:Record;

		private var _adherenceReportingDue:Boolean = false;
		private var _adherencePerformanceAssertionsCollection:ArrayCollection = new ArrayCollection();

		private var _currentDateSource:ICurrentDateSource;
		private var _simulationModel:SimulationModel;
		private var _scheduleModelIsInitialized:Boolean;

		public function AdherencePerformanceModel(scheduleCollectionsProvider:IScheduleCollectionsProvider,
												  record:Record)
		{
			if (record.bloodPressureModel == null)
			{
				throw new Error("record.bloodPressureModel must be initialized before AdherencePerformanceModel is created");
			}
			
			_scheduleCollectionsProvider = scheduleCollectionsProvider;
			_record = record;
			_simulationModel = _record.bloodPressureModel.currentSimulation;

			BindingUtils.bindSetter(simulationModelInitialized_changeHandler, _simulationModel, "isInitialized");

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		private function simulationModelInitialized_changeHandler(isInitialized:Boolean):void
		{
			if (isInitialized && _scheduleModelIsInitialized)
			{
				bindConcentrationSeverityLevels();
			}
		}

		public function set scheduleModelIsInitialized(isInitialized:Boolean):void
		{
			_scheduleModelIsInitialized = isInitialized;
			if (isInitialized && _simulationModel.isInitialized)
			{
				bindConcentrationSeverityLevels();
			}
		}

		private function bindConcentrationSeverityLevels():void
		{
			for each (var medicationComponentAdherenceModel:MedicationComponentAdherenceModel in _simulationModel.medications)
			{
				BindingUtils.bindSetter(medicationConcentrationSeverityLevel_changeHandler, medicationComponentAdherenceModel,
									"concentrationSeverityLevel");
			}
		}

		private function medicationConcentrationSeverityLevel_changeHandler(value:int):void
		{
			updateAdherencePerformance();
		}

		/**
		 * Updates the _adherencePerformanceAssertionsCollection and _adherenceReportingDue so that the AdherencePerformanceWidget
		 * gets updates with the appropriate user feedback.
		 */
		public function updateAdherencePerformance():void
		{
			var currentDate:Date = _currentDateSource.now();

			_adherencePerformanceAssertionsCollection.removeAll();
			adherenceReportingDue = isAdherenceReportingDue();

			if (!_adherenceReportingDue)
			{
				var scheduleItemOccurrencesForTodayThusFar:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForTodayThusFar(currentDate);
				if (scheduleItemOccurrencesForTodayThusFar.length != 0)
				{
					updateAdherencePerformanceForInterval(scheduleItemOccurrencesForTodayThusFar,
														  ADHERENCE_PERFORMANCE_INTERVAL_TODAY);
				}
				else
				{
					var scheduleItemOccurrencesForYesterday:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForYesterday(currentDate);
					if (scheduleItemOccurrencesForYesterday.length != 0)
					{
						updateAdherencePerformanceForInterval(scheduleItemOccurrencesForYesterday,
															  ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY);
					}
				}
			}
		}

		/**
		 * Determines if adherence reporting is currently due so that the user can be informed. The function loops through
		 * each ScheduleGroup and determines if the current time falls between its dateStart and dateEnd. Then it determines
		 * if any of its ScheduleItemOccurrence instances have an AdherenceItem. If none of them have an AdherenceItem,
		 * then true is returned. Otherwise false is returned. The reasoning is that, once the user reports adherence on
		 * any of the ScheduleItemOccurrence instances, then he or she already knows that adherence reporting is true
		 * and should therefore be updated on the adherence performance.
		 *
		 * @return
		 */
		private function isAdherenceReportingDue():Boolean
		{
			var adherenceReportingDue:Boolean = false;
			for each (var scheduleGroup:ScheduleGroup in _scheduleCollectionsProvider.scheduleGroupsCollection)
			{
				if (_currentDateSource.now().valueOf() > scheduleGroup.dateStart.valueOf() && _currentDateSource.now().valueOf() < scheduleGroup.dateEnd.valueOf())
				{
					adherenceReportingDue = true;
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
					{
						if (scheduleItemOccurrence.adherenceItem)
						{
							adherenceReportingDue = false;
						}
					}
				}
			}
			return adherenceReportingDue;
		}

		/**
		 * Returns all of the ScheduleItemOccurrence instances for today for which the dateStart is before the current
		 * time. These instances are obtained from the ScheduleModel, which already has a collection of all of the
		 * ScheduleItemOccurrence instances for today. It is important to get these instances rather than create a new set
		 * because the instances from the ScheduleModel get updated when the user reports adherence to any of the
		 * ScheduleItemOccurrence instances.
		 *
		 * @param currentDate
		 * @return
		 */
		private function getScheduleItemOccurrencesForTodayThusFar(currentDate:Date):Vector.<ScheduleItemOccurrence>
		{
			var allScheduleItemOccurrencesForToday:Vector.<ScheduleItemOccurrence> = _scheduleCollectionsProvider.scheduleItemOccurrencesVector;
			var scheduleItemOccurrencesForTodayThusFar:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in allScheduleItemOccurrencesForToday)
			{
				if (scheduleItemOccurrence.dateStart.valueOf() < currentDate.valueOf())
				{
					scheduleItemOccurrencesForTodayThusFar.push(scheduleItemOccurrence);
				}
			}
			return scheduleItemOccurrencesForTodayThusFar;
		}

		private function getScheduleItemOccurrencesForYesterday(currentDate:Date):Vector.<ScheduleItemOccurrence>
		{
			var dateStart:Date = new Date(new Date(currentDate.getFullYear(), currentDate.getMonth(),
												   currentDate.getDate()).valueOf() - MILLISECONDS_IN_DAY);
			var dateEnd:Date = new Date(dateStart.valueOf() + MILLISECONDS_IN_DAY - 1);
			return _scheduleCollectionsProvider.getScheduleItemOccurrences(dateStart, dateEnd);
		}

		/**
		 * Creates an AdherencePerformanceAssertion for each scheduleItemsCollection defined in ScheduleModel and adds the
		 * assertions to _adherencePerformanceAssertionsCollection. An AdherencePerformanceEvaluator is created for each
		 * scheduleItemsCollection through a method on the ViewFactory for the corresponding plugin. For example, the
		 * Medications plugin defines a MedicationsAdherencePerformanceEvaluator that creates an assertion for medication
		 * adherence performance.
		 *
		 * @param scheduleItemOccurrencesVector
		 * @param adherencePerformanceInterval
		 */
		private function updateAdherencePerformanceForInterval(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
															   adherencePerformanceInterval:String):void
		{
			for each (var scheduleItemsCollection:ArrayCollection in _scheduleCollectionsProvider.scheduleItemsCollectionsArray)
			{
				// There needs to be at least one ScheduleItem instance in the scheduleItemsCollection to evaluate performance
				// The first instance is used to determine what type of ScheduleItem the scheduleItemsCollection contains
				// For example, MedicationScheduleItem or EquipmentScheduleItem
				if (scheduleItemsCollection.length > 0)
				{
					var adherencePerformanceEvaluator:AdherencePerformanceEvaluatorBase = _scheduleCollectionsProvider.viewFactory.createAdherencePerformanceEvaluator(scheduleItemsCollection[0]);
					var adherencePerformanceAssertion:AdherencePerformanceAssertion = adherencePerformanceEvaluator.evaluateAdherencePerformance(scheduleItemOccurrencesVector,
																																				 _record,
																																				 adherencePerformanceInterval);
					_adherencePerformanceAssertionsCollection.addItem(adherencePerformanceAssertion);
				}
			}
		}

		public function get adherenceReportingDue():Boolean
		{
			return _adherenceReportingDue;
		}

		public function set adherenceReportingDue(value:Boolean):void
		{
			_adherenceReportingDue = value;
		}

		public function get adherencePerformanceAssertionsCollection():ArrayCollection
		{
			return _adherencePerformanceAssertionsCollection;
		}

		public function set adherencePerformanceAssertionsCollection(value:ArrayCollection):void
		{
			_adherencePerformanceAssertionsCollection = value;
		}
	}
}
