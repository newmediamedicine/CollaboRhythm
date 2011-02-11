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
package collaboRhythm.workstation.apps.schedule.controller
{
	import collaboRhythm.workstation.apps.schedule.view.ScheduleFullView;
	import collaboRhythm.workstation.apps.schedule.view.ScheduleWidgetView;
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
				newWidgetView.initializeClock(_user.scheduleModel);
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ScheduleFullView = new ScheduleFullView();
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (!_user.medicationsModel.initialized && !_user.medicationsModel.isLoading)
			{
				_healthRecordService.loadMedications(_user);
			}
			
			if (_widgetView)
				(_widgetView as ScheduleWidgetView).initializeClock(_user.scheduleModel);
			
			prepareFullView();
		}
		
		protected override function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
			{
				_scheduleFullViewController = new ScheduleFullViewController(_user.scheduleModel, _fullView as ScheduleFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				_fullView.initializeControllerModel(_scheduleFullViewController, _user.scheduleModel);
			}
		}
		
		public override function get defaultName():String
		{
			return "Schedule";
		}
	}
}