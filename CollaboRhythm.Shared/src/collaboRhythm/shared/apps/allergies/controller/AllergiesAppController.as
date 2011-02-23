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
package collaboRhythm.shared.apps.allergies.controller
{
//	import collaboRhythm.workstation.apps.allergies.view.AllergiesFullView;
	import collaboRhythm.shared.apps.allergies.view.AllergiesWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class AllergiesAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:AllergiesWidgetView;
//		private var _fullView:AllergiesFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as AllergiesWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as AllergiesFullView;
//		}
		
		public function AllergiesAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new AllergiesWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new AllergiesFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.allergies == null)
//			{
//				_healthRecordService.loadAllergies(_sharedUser);
//			}
//			(_widgetView as AllergiesWidgetView).model = _sharedUser.allergies;
//			_fullView.model = _sharedUser.allergies;
		}
	}
}