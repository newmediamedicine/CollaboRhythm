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
package collaboRhythm.workstation.apps.labs.controller
{
//	import collaboRhythm.workstation.apps.labs.view.LabsFullView;
	import collaboRhythm.workstation.apps.labs.view.LabsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class LabsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:LabsWidgetView;
//		private var _fullView:LabsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as LabsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as LabsFullView;
//		}
		
		public function LabsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new LabsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new LabsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.labs == null)
//			{
//				_healthRecordService.loadLabs(_sharedUser);
//			}
//			(_widgetView as LabsWidgetView).model = _sharedUser.labs;
//			_fullView.model = _sharedUser.labs;
		}
	}
}