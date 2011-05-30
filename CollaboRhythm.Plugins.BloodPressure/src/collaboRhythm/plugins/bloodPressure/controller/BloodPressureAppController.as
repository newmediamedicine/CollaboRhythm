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
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMeterView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMobileWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureWidgetView;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.UIComponent;

	public class BloodPressureAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Blood Pressure Review";

		private var _fullView:BloodPressureFullView;
		private var _widgetView:IBloodPressureWidgetView;

		public override function get widgetView():UIComponent
		{
			return _widgetView as UIComponent;
		}

		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as IBloodPressureWidgetView;
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
			var newWidgetView:IBloodPressureWidgetView;
			if (isWorkstationMode)
				newWidgetView = new BloodPressureMeterView();
			else
				newWidgetView = new BloodPressureMobileWidgetView();

			if (_activeRecordAccount != null)
				newWidgetView.model = _activeRecordAccount.bloodPressureModel;

			return newWidgetView as UIComponent;
		}

		protected override function createFullView():UIComponent
		{
			var newFullView:BloodPressureFullView = new BloodPressureFullView();
			if (_activeRecordAccount != null)
				newFullView.model = _activeRecordAccount.bloodPressureModel;
			return newFullView;
		}

		public override function initialize():void
		{
			super.initialize();
			if (_activeRecordAccount.bloodPressureModel.data == null)
			{
				loadBloodPressureData();
			}
			if (_widgetView)
				_widgetView.model = _activeRecordAccount.bloodPressureModel;

			prepareFullView();
		}

		protected function loadBloodPressureData():void
		{
            // TODO: Get the right account here
			var bloodPressureHealthRecordService:BloodPressureHealthRecordService = new BloodPressureHealthRecordService(_settings.oauthChromeConsumerKey, _settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _activeAccount);
//			bloodPressureHealthRecordService.copyLoginResults(_healthRecordService);
			bloodPressureHealthRecordService.loadBloodPressure(_activeRecordAccount);
		}

		override protected function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
			{
				_fullView.model = _activeRecordAccount.bloodPressureModel;
				_fullView.simulationView.initializeModel(_activeRecordAccount.bloodPressureModel.simulation, _activeRecordAccount.bloodPressureModel);
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
			return DEFAULT_NAME;
		}
		
		override protected function removeUserData():void
		{
			_activeRecordAccount.bloodPressureModel = new BloodPressureModel();
		}
	}
}