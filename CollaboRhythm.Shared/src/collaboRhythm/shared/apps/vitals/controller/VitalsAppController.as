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
package collaboRhythm.shared.apps.vitals.controller
{
//	import collaboRhythm.workstation.apps.vitals.view.VitalsFullView;

	import collaboRhythm.shared.apps.vitals.view.VitalsWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppControllerBase;

	import mx.core.UIComponent;

	public class VitalsAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Vitals";

		private var _widgetView:VitalsWidgetView;
//		private var _fullView:VitalsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as VitalsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as VitalsFullView;
//		}
		
		public function VitalsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new VitalsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new VitalsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.vitals == null)
//			{
//				_healthRecordService.loadVitals(_sharedUser);
//			}
//			(_widgetView as VitalsWidgetView).model = _sharedUser.vitals;
//			_fullView.model = _sharedUser.vitals;
		}

		override public function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}