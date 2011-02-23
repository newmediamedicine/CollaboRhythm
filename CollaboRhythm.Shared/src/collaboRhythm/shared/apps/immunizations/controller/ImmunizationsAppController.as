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
package collaboRhythm.shared.apps.immunizations.controller
{
//	import collaboRhythm.workstation.apps.immunizations.view.ImmunizationsFullView;
	import collaboRhythm.shared.apps.immunizations.view.ImmunizationsWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ImmunizationsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ImmunizationsWidgetView;
//		private var _fullView:ImmunizationsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ImmunizationsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as ImmunizationsFullView;
//		}
		
		public function ImmunizationsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new ImmunizationsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new ImmunizationsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.immunizations == null)
//			{
//				_healthRecordService.loadImmunizations(_sharedUser);
//			}
//			(_widgetView as ImmunizationsWidgetView).model = _sharedUser.immunizations;
//			_fullView.model = _sharedUser.immunizations;
		}
	}
}