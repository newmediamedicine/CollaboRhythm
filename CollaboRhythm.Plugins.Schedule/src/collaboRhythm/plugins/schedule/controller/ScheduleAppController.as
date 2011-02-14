/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.schedule.controller
{
	import collaboRhythm.plugins.schedule.view.ScheduleWidgetView;
	import collaboRhythm.plugins.schedule.shared.controller.ScheduleFullViewController;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleFullView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ScheduleAppController extends WorkstationAppControllerBase
	{
		private var _scheduleFullViewController:ScheduleFullViewController;
		private var _widgetView:ScheduleWidgetView;
		private var _fullView:ScheduleFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ScheduleWidgetView;
		}
		
		public override function get isFullViewSupported():Boolean
		{
			return true;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as ScheduleFullView;
		}
		
		public function ScheduleAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ScheduleWidgetView = new ScheduleWidgetView();
			if (_user != null)
				newWidgetView.init(scheduleModel);
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ScheduleFullView = new ScheduleFullView();
			if (_user != null)
				_scheduleFullViewController = new ScheduleFullViewController(scheduleModel, _fullView as ScheduleFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				newFullView.init(_scheduleFullViewController, scheduleModel);
			return newFullView;
		}
		
		private function get scheduleModel():ScheduleModel
		{
			if (_user != null)
			{
				if (_user.appData[ScheduleModel.SCHEDULE_KEY] == null)
				{
					_user.appData[ScheduleModel.SCHEDULE_KEY] = new ScheduleModel();
				}
				return _user.getAppData(ScheduleModel.SCHEDULE_KEY, ScheduleModel) as ScheduleModel;
			}
			return null;
		}
		
		public override function initialize():void
		{
			super.initialize();
			
			if (_widgetView)
				(_widgetView as ScheduleWidgetView).init(scheduleModel);
			prepareFullView();
		}
		
		protected override function prepareFullView():void
		{
			super.prepareFullView();
//			if (_fullView)
//			{
//				_scheduleFullViewController = new ScheduleFullViewController(scheduleModel, _fullView as ScheduleFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
//				_fullView.init(_scheduleFullViewController, scheduleModel);
//			}
		}
		
		public override function close():void
		{
			super.close();
//			for each (var adherenceGroupView:AdherenceGroupView in _fullView.adherenceGroupViews)
//			{
//				adherenceGroupView.unwatchAll();
//				adherenceGroupView.adherenceWindowView.unwatchAll();
//			}
//			for each (var medicationView:MedicationView in _fullView.medicationViews)
//			{
//				medicationView.unwatchAll();
//			}
		}
		
		public override function get defaultName():String
		{
			return "Schedule";
		}
	}
}