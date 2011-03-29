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
package collaboRhythm.plugins.problems.controller
{
	import collaboRhythm.plugins.problems.model.ProblemsHealthRecordService;
	import collaboRhythm.plugins.problems.model.ProblemsModel;
	import collaboRhythm.plugins.problems.view.ProblemsFullView;
	import collaboRhythm.plugins.problems.view.ProblemsWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.UIComponent;

	public class ProblemsAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Problems";

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
			_fullView = value as ProblemsFullView;
		}

		public function ProblemsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ProblemsWidgetView = new ProblemsWidgetView();
			if (_user != null)
				newWidgetView.model = _user.getAppData(ProblemsModel.PROBLEMS_KEY, ProblemsModel) as ProblemsModel;
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ProblemsFullView = new ProblemsFullView();
			if (_user != null)
				newFullView.model = _user.getAppData(ProblemsModel.PROBLEMS_KEY, ProblemsModel) as ProblemsModel;
			return newFullView;
		}
		
		private function get problemsModel():ProblemsModel
		{
			if (_user != null)
			{
				if (_user.appData[ProblemsModel.PROBLEMS_KEY] == null)
				{
					_user.appData[ProblemsModel.PROBLEMS_KEY] = new ProblemsModel();
				}
				return _user.getAppData(ProblemsModel.PROBLEMS_KEY, ProblemsModel) as ProblemsModel;
			}
			return null;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (!problemsModel.initialized)
			{
				var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(_healthRecordService.consumerKey, _healthRecordService.consumerSecret, _healthRecordService.baseURL);
				problemsHealthRecordService.copyLoginResults(_healthRecordService);
				problemsHealthRecordService.loadProblems(_user);
			}

			if (_widgetView)
				(_widgetView as ProblemsWidgetView).model = problemsModel;
			prepareFullView();
		}
		
//		protected override function prepareWidgetView():void
//		{
//			super.prepareWidgetView()();
//			if (_widgetView)
//				(_widgetView as ProblemsWidgetView).model = problemsModel;
//		}
		
		protected override function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
				(_fullView as ProblemsFullView).model = problemsModel;
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}