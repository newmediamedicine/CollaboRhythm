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
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMobileWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureSimulationWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureWidgetView;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import flash.display.Loader;

	import flash.display.MovieClip;

	import mx.core.UIComponent;

	import spark.primitives.Rect;

	public class BloodPressureAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Blood Pressure Review";

		private var _fullView:BloodPressureFullView;
		private var _widgetView:IBloodPressureWidgetView;
		private var _createFullViewOnInitialize:Boolean = true;

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

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:IBloodPressureWidgetView;
			if (isWorkstationMode || isTabletMode)
				newWidgetView = new BloodPressureSimulationWidgetView();
			else
				newWidgetView = new BloodPressureMobileWidgetView();

			return newWidgetView as UIComponent;
		}

		protected override function createFullView():UIComponent
		{
			_fullView = new BloodPressureFullView();
			return _fullView;
		}

		public override function initialize():void
		{
			super.initialize();

			if (!_activeRecordAccount.primaryRecord.bloodPressureModel || !_activeRecordAccount.primaryRecord.bloodPressureModel.isInitialized)
			{
				loadBloodPressureData();
			}

			if (!_fullView && _createFullViewOnInitialize && _fullContainer && isFullViewSupported)
			{
				createFullView();
				prepareFullView();
			}
		}


		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.model = _activeRecordAccount.primaryRecord.bloodPressureModel;
				var currentPerformanceModel:AdherencePerformanceModel = _activeRecordAccount.primaryRecord.getAppData(AdherencePerformanceModel.ADHERENCE_PERFORMANCE_MODEL_KEY, AdherencePerformanceModel) as AdherencePerformanceModel;
				_widgetView.currentPerformanceModel = currentPerformanceModel;
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView && _activeRecordAccount)
			{
				_fullView.model = _activeRecordAccount.primaryRecord.bloodPressureModel;
			}
		}

		protected function loadBloodPressureData():void
		{
			if (_activeRecordAccount)
			{
				// first cleanup any existing bloodPressureModel
				removeUserData();
				_activeRecordAccount.primaryRecord.bloodPressureModel.record = _activeRecordAccount.primaryRecord;

				var bloodPressureHealthRecordService:BloodPressureHealthRecordService = new BloodPressureHealthRecordService(_settings.oauthChromeConsumerKey,
																															 _settings.oauthChromeConsumerSecret,
																															 _settings.indivoServerBaseURL,
																															 _activeAccount);
				bloodPressureHealthRecordService.initializeBloodPressureModel(_activeRecordAccount);
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

			super.reloadUserData();

			if (_fullView)
			{
				_fullView.refresh();
			}
			if (_widgetView)
			{
				_widgetView.refresh();
			}
		}

		override public function showFullView(startRect:Rect):Boolean
		{
			if (super.showFullView(startRect))
			{
				moveMovieClipToFullView();
				return true;
			}
			else
				return false;
		}

		override protected function showFullViewComplete():void
		{
			_fullView.simulationView.isRunning = true;
		}

		override protected function hideFullViewComplete():void
		{
			_fullView.simulationView.isRunning = false;
			moveMovieClipToWidgetView();
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
			if (_activeRecordAccount.primaryRecord.bloodPressureModel)
				_activeRecordAccount.primaryRecord.bloodPressureModel.record = null;

			_activeRecordAccount.primaryRecord.bloodPressureModel = new BloodPressureModel();
		}

		private function moveMovieClipToFullView():void
		{
			var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as BloodPressureSimulationWidgetView);
			if (_fullView && bloodPressureSimulationWidgetView)
			{
				var loader:Loader = bloodPressureSimulationWidgetView.circulatorySystemSimulationView.removeMovieClipLoader();
				if (loader)
					_fullView.simulationView.hypertensionCirculatorySystemGroup.circulatorySystemSimulationView.injectMovieClipLoader(loader);
			}
		}

		private function moveMovieClipToWidgetView():void
		{
			var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as BloodPressureSimulationWidgetView);
			if (_fullView && bloodPressureSimulationWidgetView)
			{
				var loader:Loader = _fullView.simulationView.hypertensionCirculatorySystemGroup.circulatorySystemSimulationView.removeMovieClipLoader();
				if (loader)
					bloodPressureSimulationWidgetView.circulatorySystemSimulationView.injectMovieClipLoader(loader);
			}
		}
	}
}