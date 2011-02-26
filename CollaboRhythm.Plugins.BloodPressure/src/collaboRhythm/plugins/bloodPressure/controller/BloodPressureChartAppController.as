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
package collaboRhythm.plugins.bloodPressure.controller
{
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMobileChartView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class BloodPressureChartAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:BloodPressureMobileChartView;

		public function BloodPressureChartAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}

		override public function get defaultName():String
		{
			return "Blood Pressure Chart";
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as BloodPressureMobileChartView;
		}

		protected override function createWidgetView():UIComponent
		{
			_widgetView = new BloodPressureMobileChartView();
			if (_widgetView)
				_widgetView.model = _user.bloodPressureModel;
			return _widgetView;
		}

		public override function initialize():void
		{
			super.initialize();
			prepareWidgetView();
		}

		override protected function prepareWidgetView():void
		{
			super.prepareWidgetView();
			if (_widgetView)
				_widgetView.model = _user.bloodPressureModel;
		}
	}
}
