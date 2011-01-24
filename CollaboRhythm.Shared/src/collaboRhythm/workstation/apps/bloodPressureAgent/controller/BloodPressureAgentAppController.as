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
package collaboRhythm.workstation.apps.bloodPressureAgent.controller
{
	import collaboRhythm.workstation.apps.bloodPressureAgent.view.BloodPressureAgentFullView;
	import collaboRhythm.workstation.apps.bloodPressureAgent.view.BloodPressureAgentWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppEvent;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class BloodPressureAgentAppController extends WorkstationAppControllerBase
	{
		private var _bloodPressureFullViewController:BloodPressureAgentFullViewController;
		private var _widgetView:BloodPressureAgentWidgetView;
		private var _fullView:BloodPressureAgentFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as BloodPressureAgentWidgetView;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as BloodPressureAgentFullView;
		}
		
		public function BloodPressureAgentAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:BloodPressureAgentWidgetView = new BloodPressureAgentWidgetView();
//			if (_user != null)
//				newWidgetView.initializeClock(_user.scheduleModel);
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:BloodPressureAgentFullView = new BloodPressureAgentFullView();
//			if (_user != null)
//				newFullView.initializeControllerModel(null, _user.scheduleModel);
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
//			(_widgetView as BloodPressureWidgetView).initializeClock(_user.scheduleModel);
			prepareFullView();
		}
		
		protected override function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
			{
				_bloodPressureFullViewController = new BloodPressureAgentFullViewController(_fullView as BloodPressureAgentFullView);
				_bloodPressureFullViewController.addEventListener(WorkstationAppEvent.SHOW_FULL_VIEW, launchBloodPressureFullViewHandler);
				_fullView.initializeControllerModel(_bloodPressureFullViewController, user.bloodPressureModel);
			}
		}
		
		private function launchBloodPressureFullViewHandler(event:WorkstationAppEvent):void
		{
			dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, null, null, event.applicationName));
		}
		
		public override function close():void
		{
			super.close();
		}
		
		override public function reloadUserData():void
		{
			if (_fullView)
				_fullView.refresh();
		}
	}
}