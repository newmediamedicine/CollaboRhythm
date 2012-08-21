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
	import collaboRhythm.plugins.schedule.model.ScheduleTimelineModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationController;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionCreationControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	import collaboRhythm.plugins.schedule.view.ScheduleTimelineFullView;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import flash.events.EventDispatcher;

	import spark.components.ViewNavigator;

	public class ScheduleTimelineController extends EventDispatcher
	{
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleTimelineFullView:ScheduleTimelineFullView;
		private var _scheduleTimelineModel:ScheduleTimelineModel;
		private var _viewNavigator:ViewNavigator;

		private var _healthActionCreationControllerFactory:MasterHealthActionCreationControllerFactory;

		public function ScheduleTimelineController(activeAccount:Account,
												   activeRecordAccount:Account,
												   scheduleModel:ScheduleModel,
												   scheduleTimelineFullView:ScheduleTimelineFullView,
												   componentContainter:IComponentContainer,
												   viewNavigator:ViewNavigator)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_scheduleModel = scheduleModel;
			_scheduleTimelineFullView = scheduleTimelineFullView;
			_scheduleTimelineModel = _scheduleModel.scheduleTimelineModel;
			_viewNavigator = viewNavigator;

			_healthActionCreationControllerFactory = new MasterHealthActionCreationControllerFactory(componentContainter);
		}

		public function grabScheduleGroup(moveData:MoveData):void
		{
			_scheduleTimelineModel.grabScheduleGroup(moveData);
		}

		public function moveScheduleGroup(moveData:MoveData):void
		{
			_scheduleTimelineModel.moveScheduleGroup(moveData, _scheduleTimelineFullView.width,
													 _scheduleTimelineFullView.height,
													 _scheduleTimelineModel.timeWidth);
		}

		public function dropScheduleGroup(moveData:MoveData):void
		{
			_scheduleTimelineModel.dropScheduleGroup(moveData);
		}

		public function grabScheduleGroupSpotlight(moveData:MoveData):void
		{
			_scheduleTimelineModel.grabScheduleGroupSpotlight(moveData);
		}

		public function resizeScheduleGroupSpotlight(moveData:MoveData, leftEdge:Boolean):void
		{
			_scheduleTimelineModel.resizeScheduleGroupSpotlight(moveData, _scheduleTimelineFullView.width,
																_scheduleTimelineFullView.height,
																_scheduleTimelineModel.timeWidth, leftEdge);
		}

		public function dropScheduleGroupSpotlight(moveData:MoveData):void
		{
			_scheduleTimelineModel.dropScheduleGroupSpotlight(moveData);
		}

		public function grabScheduleItemOccurrence(moveData:MoveData):void
		{
			_scheduleTimelineModel.grabScheduleItemOccurrence(moveData);
		}

		public function editItem(moveData:MoveData):void
		{
			var healthActionCreationController:IHealthActionCreationController = _healthActionCreationControllerFactory.createHealthActionCreationControllerFromScheduleItemOccurrence(_activeAccount, _activeRecordAccount, _scheduleModel.scheduleItemOccurrencesHashMap[moveData.id], _viewNavigator)
			healthActionCreationController.showHealthActionEditView(_scheduleModel.scheduleItemOccurrencesHashMap[moveData.id]);
		}

		public function unscheduleItem(moveData:MoveData):void
		{
			_scheduleTimelineModel.unscheduleItem(moveData);
		}
	}
}