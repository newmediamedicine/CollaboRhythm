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

	import collaboRhythm.plugins.bloodPressure.model.HealthChartsInitializationService;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureButtonWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureFullView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMobileWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureSimulationWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureSynchronizedCharts;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureFullView;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureWidgetView;
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import flash.display.Loader;

	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;

	import spark.primitives.Rect;

	public class BloodPressureAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Blood Pressure Review";

		private var _fullView:IBloodPressureFullView;
		private var _widgetView:IBloodPressureWidgetView;
		public static const useSingleCirculatorySystemMovieClip:Boolean = false;

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
			return _fullView as UIComponent;
		}

		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as IBloodPressureFullView;
		}

		public function BloodPressureAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
			cacheFullView = true;
			createFullViewOnInitialize = true;
		}

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:IBloodPressureWidgetView;
			if (isWorkstationMode)
				newWidgetView = new BloodPressureSimulationWidgetView();
			else if (isTabletMode)
				newWidgetView = new BloodPressureButtonWidgetView();
			else
				newWidgetView = new BloodPressureMobileWidgetView();

			return newWidgetView as UIComponent;
		}

		protected override function createFullView():UIComponent
		{
			if (isWorkstationMode)
				_fullView = new BloodPressureFullView();
			else
				_fullView = new BloodPressureSynchronizedCharts();

			return _fullView as UIComponent;
		}

		public override function initialize():void
		{
			super.initialize();

			if (!_activeRecordAccount.primaryRecord.healthChartsModel ||
					!_activeRecordAccount.primaryRecord.healthChartsModel.isInitialized)
			{
				loadBloodPressureData();
			}

			// TODO: We should either 1) make sure that the healthChartsModel is created when the record is created
			// or 2) lazy initialize it or 3) rework the timing of initialize and updateWidgetViewModel
			updateWidgetViewModel();
			doPrecreationForFullView();
		}

		protected override function listenForModelInitialized():void
		{
			if (_activeRecordAccount.primaryRecord.healthChartsModel.isInitialized)
			{
				listenForFullViewUpdateComplete();
			}
			else
			{
				_activeRecordAccount.primaryRecord.healthChartsModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
						model_propertyChangeHandler,
						false, 0, true);
			}
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "isInitialized" &&
					_activeRecordAccount.primaryRecord.healthChartsModel.isInitialized)
			{
				_activeRecordAccount.primaryRecord.healthChartsModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
						model_propertyChangeHandler);
				listenForFullViewUpdateComplete();
			}
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount && _activeRecordAccount.primaryRecord &&
					_activeRecordAccount.primaryRecord.healthChartsModel)
			{
				_widgetView.model = _activeRecordAccount.primaryRecord.healthChartsModel;
				_widgetView.controller = this;
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView && _activeRecordAccount)
			{
				_fullView.model = _activeRecordAccount.primaryRecord.healthChartsModel;
				_fullView.modality = modality;
				_fullView.componentContainer  = _componentContainer;
				_fullView.activeAccountId = activeAccount.accountId;
			}
		}

		protected function loadBloodPressureData():void
		{
			if (_activeRecordAccount)
			{
				// first cleanup any existing healthChartsModel
				removeUserData();
				_activeRecordAccount.primaryRecord.healthChartsModel.record = _activeRecordAccount.primaryRecord;

				var healthChartsInitializationService:HealthChartsInitializationService = new HealthChartsInitializationService();
				healthChartsInitializationService.initializeBloodPressureModel(_activeRecordAccount);
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
			if (fullViewWithSimulation)
				fullViewWithSimulation.simulationView.isRunning = true;
		}

		private function get fullViewWithSimulation():BloodPressureFullView
		{
			return _fullView as BloodPressureFullView;
		}

		override protected function hideFullViewComplete():void
		{
			if (fullViewWithSimulation)
			{
				fullViewWithSimulation.simulationView.isRunning = false;
				moveMovieClipToWidgetView();
			}
		}

		override public function destroyViews():void
		{
			if (fullViewWithSimulation)
				fullViewWithSimulation.simulationView.isRunning = false;

			super.destroyViews();
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		override protected function removeUserData():void
		{
			if (_activeRecordAccount.primaryRecord.healthChartsModel)
				_activeRecordAccount.primaryRecord.healthChartsModel.record = null;

			_activeRecordAccount.primaryRecord.healthChartsModel = new HealthChartsModel();
		}

		private function moveMovieClipToFullView():void
		{
			if (fullViewWithSimulation && useSingleCirculatorySystemMovieClip)
			{
				var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as
						BloodPressureSimulationWidgetView);
				if (_fullView && bloodPressureSimulationWidgetView)
				{
					var loader:Loader = bloodPressureSimulationWidgetView.circulatorySystemSimulationView.removeMovieClipLoader();
					if (loader)
						fullViewWithSimulation.simulationView.hypertensionCirculatorySystemGroup.circulatorySystemSimulationView.injectMovieClipLoader(loader);
				}
			}
		}

		private function moveMovieClipToWidgetView():void
		{
			if (fullViewWithSimulation && useSingleCirculatorySystemMovieClip)
			{
				var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as
						BloodPressureSimulationWidgetView);
				if (_fullView && bloodPressureSimulationWidgetView)
				{
					var loader:Loader = fullViewWithSimulation.simulationView.hypertensionCirculatorySystemGroup.circulatorySystemSimulationView.removeMovieClipLoader();
					if (loader)
						bloodPressureSimulationWidgetView.circulatorySystemSimulationView.injectMovieClipLoader(loader);
				}
			}
		}
	}
}