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
package collaboRhythm.shared.apps.procedures.controller
{
//	import collaboRhythm.workstation.apps.procedures.view.ProceduresFullView;
	import collaboRhythm.shared.apps.procedures.view.ProceduresWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ProceduresAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ProceduresWidgetView;
//		private var _fullView:ProceduresFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ProceduresWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as ProceduresFullView;
//		}
		
		public function ProceduresAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new ProceduresWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new ProceduresFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.procedures == null)
//			{
//				_healthRecordService.loadProcedures(_sharedUser);
//			}
//			(_widgetView as ProceduresWidgetView).model = _sharedUser.procedures;
//			_fullView.model = _sharedUser.procedures;
		}
	}
}