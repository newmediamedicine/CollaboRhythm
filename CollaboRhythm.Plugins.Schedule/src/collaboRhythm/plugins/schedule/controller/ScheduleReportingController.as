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
package collaboRhythm.plugins.schedule.controller
{

	import collaboRhythm.plugins.schedule.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.model.ScheduleReportingModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	import flash.events.EventDispatcher;

	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;

	public class ScheduleReportingController extends EventDispatcher
	{
		private var _scheduleModel:ScheduleModel;
		private var _scheduleReportingFullView:ScheduleReportingFullView;
		[Bindable]
		private var _scheduleReportingModel:ScheduleReportingModel;

		public function ScheduleReportingController(scheduleModel:ScheduleModel,
													scheduleReportingFullView:ScheduleReportingFullView)
		{
			_scheduleModel = scheduleModel;
			_scheduleReportingFullView = scheduleReportingFullView;
			_scheduleReportingModel = _scheduleModel.scheduleReportingModel;
			_scheduleReportingModel.isReportingCompleted = false;

			BindingUtils.bindSetter(reportingCompletedHandler, _scheduleReportingModel, "isReportingCompleted");
		}

		private function reportingCompletedHandler(isReportingCompleted:Boolean):void
		{
			if (isReportingCompleted)
			{
				dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, null, null, "HypertensionEducation"));
			}
		}

		public function goBack():void
		{
			_scheduleReportingModel.viewStack.removeItemAt(_scheduleReportingModel.viewStack.length - 1)
		}

		public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence,
											adherenceItem:AdherenceItem):void
		{
			_scheduleReportingModel.createAdherenceItem(scheduleGroup, scheduleItemOccurrence, adherenceItem);
		}

		public function showAdditionalInformationView(additionalInformationView:UIComponent):void
		{
			_scheduleReportingModel.showAdditionalInformationView(additionalInformationView);
		}

		public function voidAdherenceItem(scheduleItemOccurrence:ScheduleItemOccurrence):void
		{
			_scheduleReportingModel.voidAdherenceItem(scheduleItemOccurrence);
		}
	}
}
