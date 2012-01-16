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
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.collections.ArrayCollection;

	public class MasterReportingViewAdapterFactory implements IReportingViewAdapterFactory
	{
		private var _factoryArray:Array;

		public function MasterReportingViewAdapterFactory(componentContainer:IComponentContainer)
		{
			_factoryArray = componentContainer.resolveAll(IReportingViewAdapterFactory);
		}
		
		public function get allReportingViewAdaptersCollection():ArrayCollection
		{
			var allReportingViewAdaptersCollection:ArrayCollection = new ArrayCollection();
			for each (var reportingViewAdapterFactory:IReportingViewAdapterFactory in _factoryArray)
			{
				var reportingViewAdaptersCollection:ArrayCollection = reportingViewAdapterFactory.reportingViewAdaptersCollection;
				if (reportingViewAdaptersCollection)
					allReportingViewAdaptersCollection.addAll(reportingViewAdaptersCollection);
			}
			return allReportingViewAdaptersCollection;
		}

		public function isMatchingReportingViewAdapterFactory(name:String = null,
															  scheduleItem:ScheduleItemBase = null):Boolean
		{
			return false;
		}

		public function createAdherencePerformanceEvaluator(scheduleItemOccurrence:ScheduleItemOccurrence):AdherencePerformanceEvaluatorBase
		{
			var matchingReportingViewAdapterFactory:IReportingViewAdapterFactory;
			for each (var reportingViewAdapterFactory:IReportingViewAdapterFactory in _factoryArray)
			{
				if (reportingViewAdapterFactory.isMatchingReportingViewAdapterFactory(null,
						scheduleItemOccurrence.scheduleItem))
					matchingReportingViewAdapterFactory = reportingViewAdapterFactory;
			}

			if (matchingReportingViewAdapterFactory)
				return matchingReportingViewAdapterFactory.createAdherencePerformanceEvaluator(scheduleItemOccurrence);
			else
				return null;
		}

		public function createReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence):IReportingViewAdapter
		{
			var matchingReportingViewAdapterFactory:IReportingViewAdapterFactory;
			for each (var dataInputControllerFactory:IReportingViewAdapterFactory in _factoryArray)
			{
				if (dataInputControllerFactory.isMatchingReportingViewAdapterFactory(null,
						scheduleItemOccurrence.scheduleItem))
					matchingReportingViewAdapterFactory = dataInputControllerFactory;
			}

			if (matchingReportingViewAdapterFactory)
				return matchingReportingViewAdapterFactory.createReportingViewAdapter(scheduleItemOccurrence);
			else
				return null;
		}

		public function createReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
											 scheduleModel:IScheduleModel):ScheduleItemOccurrenceReportingModelBase
		{
			var matchingReportingViewAdapterFactory:IReportingViewAdapterFactory;
			for each (var dataInputControllerFactory:IReportingViewAdapterFactory in _factoryArray)
			{
				if (dataInputControllerFactory.isMatchingReportingViewAdapterFactory(null,
						scheduleItemOccurrence.scheduleItem))
					matchingReportingViewAdapterFactory = dataInputControllerFactory;
			}

			if (matchingReportingViewAdapterFactory)
				return matchingReportingViewAdapterFactory.createReportingModel(scheduleItemOccurrence, scheduleModel);
			else
				return null;
		}

		public function get reportingViewAdaptersCollection():ArrayCollection
		{
			return null;
		}
	}
}
