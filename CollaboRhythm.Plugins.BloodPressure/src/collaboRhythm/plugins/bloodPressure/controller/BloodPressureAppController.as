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
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureHealthRecordService;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureFullView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureWidgetView;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.UIComponent;

	public class BloodPressureAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:BloodPressureWidgetView;
		private var _fullView:BloodPressureFullView;

		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}

		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as BloodPressureWidgetView;
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
			_fullView = value as BloodPressureFullView;
		}
		
		public function BloodPressureAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

//		override public function showWidget(left:Number=-1, top:Number=-1):void
//		{
//			// do nothing	
//		}
//
//		override protected function prepareWidgetView():void
//		{
//			// do nothing
//		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:BloodPressureWidgetView = new BloodPressureWidgetView();
			if (_user != null)
				newWidgetView.model = _user.bloodPressureModel;
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:BloodPressureFullView = new BloodPressureFullView();
			if (_user != null)
				newFullView.model = _user.bloodPressureModel;
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (_user.bloodPressureModel.data == null)
			{
				loadBloodPressureData();
			}
			if (_widgetView)
				_widgetView.model = _user.bloodPressureModel;
			
			prepareFullView();
		}
		
		protected function loadBloodPressureData():void
		{
			var bloodPressureHealthRecordService:BloodPressureHealthRecordService = new BloodPressureHealthRecordService(_healthRecordService.consumerKey, _healthRecordService.consumerSecret, _healthRecordService.baseURL);
			bloodPressureHealthRecordService.copyLoginResults(_healthRecordService);
			bloodPressureHealthRecordService.loadBloodPressure(_user);
		}
		
		override protected function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
			{
				_fullView.model = _user.bloodPressureModel;
				_fullView.simulationView.initializeModel(_user.bloodPressureModel.simulation, _user.bloodPressureModel);
			}
		}

		override public function showWidgetAsDraggable(value:Boolean):void
		{
		}
		
		override public function showWidgetAsSelected(value:Boolean):void
		{
		}
		
		override public function reloadUserData():void
		{
			loadBloodPressureData();
			if (_fullView)
			{
				_fullView.refresh();
				_fullView.simulationView.refresh();
			}
			if (_widgetView)
				_widgetView.refresh();
		}
		
		override protected function showFullViewComplete():void
		{
			_fullView.simulationView.isRunning = true;
		}
		
		override protected function hideFullViewComplete():void
		{
			_fullView.simulationView.isRunning = false;
		}
		
		override public function destroyViews():void
		{
			if (_fullView)
				_fullView.simulationView.isRunning = false;

			super.destroyViews();
		}

		public override function get defaultName():String
		{
			return "Blood Pressure Review";
		}
		
		override protected function removeUserData():void
		{
			user.bloodPressureModel = new BloodPressureModel();
		}
	}
}