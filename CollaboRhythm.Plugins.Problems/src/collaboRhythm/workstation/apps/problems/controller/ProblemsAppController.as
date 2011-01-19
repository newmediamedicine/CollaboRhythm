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
package collaboRhythm.workstation.apps.problems.controller
{
	import collaboRhythm.workstation.apps.problems.view.ProblemsFullView;
	import collaboRhythm.workstation.apps.problems.view.ProblemsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ProblemsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ProblemsWidgetView;
		private var _fullView:ProblemsFullView;
			
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ProblemsWidgetView;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as ProblemsFullView;
		}

		public function ProblemsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ProblemsWidgetView = new ProblemsWidgetView();
			if (_user != null)
				newWidgetView.model = _user.problemsModel;
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ProblemsFullView = new ProblemsFullView();
			if (_user != null)
				newFullView.model = _user.problemsModel;
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (_user.problemsModel.initialized == false)
			{
				_healthRecordService.loadProblems(_user);
			}
			if (_widgetView)
				(_widgetView as ProblemsWidgetView).model = _user.problemsModel;

			if (_fullView)
				_fullView.model = _user.problemsModel;
		}
	}
}