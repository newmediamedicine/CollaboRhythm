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
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureSimulationWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureFullView;
	import collaboRhythm.plugins.bloodPressure.view.IBloodPressureWidgetView;
	import collaboRhythm.plugins.bloodPressure.view.SynchronizedCharts;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import flash.display.Loader;

	import flash.display.MovieClip;
	import flash.events.Event;

	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;

	import spark.primitives.Rect;

	public class BloodPressureAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Blood Pressure Review";

		private var _fullView:IBloodPressureFullView;
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
		}

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:IBloodPressureWidgetView;
			if (isWorkstationMode || isTabletMode)
//				newWidgetView = new BloodPressureSimulationWidgetView();
				newWidgetView = new BloodPressureMeterView();
			else
				newWidgetView = new BloodPressureMobileWidgetView();

			return newWidgetView as UIComponent;
		}

		protected override function createFullView():UIComponent
		{
			if (isWorkstationMode)
				_fullView = new BloodPressureFullView();
			else
				_fullView = new SynchronizedCharts();

			return _fullView as UIComponent;
		}

		public override function initialize():void
		{
			super.initialize();

			if (!_activeRecordAccount.primaryRecord.bloodPressureModel || !_activeRecordAccount.primaryRecord.bloodPressureModel.isInitialized)
			{
				loadBloodPressureData();
			}

			// TODO: We should either 1) make sure that the bloodPressureModel is created when the record is created
			// or 2) lazy initialize it or 3) rework the timing of initialize and updateWidgetViewModel
			updateWidgetViewModel();

			if (shouldPreCreateFullView)
			{
				createFullView();
				prepareFullView();

				// special handling to get a bitmap snapshot of the fullView so we can do a quick transition the first time it is shown
				if (isTabletMode)
				{
					if (_activeRecordAccount.primaryRecord.bloodPressureModel.isInitialized)
					{
						listenForFullViewUpdateComplete();
					}
					else
					{
						_activeRecordAccount.primaryRecord.bloodPressureModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
																							   model_propertyChangeHandler,
																							   false, 0, true);
					}
					if (_viewNavigator)
					{
						_viewNavigator.activeView.addElement(fullView);
					}
				}
			}
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "isInitialized" && _activeRecordAccount.primaryRecord.bloodPressureModel.isInitialized)
			{
				_activeRecordAccount.primaryRecord.bloodPressureModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler);
				listenForFullViewUpdateComplete();
			}
		}

		private function listenForFullViewUpdateComplete():void
		{
			fullView.addEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler, false, 0, true);
		}

		private function fullView_updateCompleteHandler(event:FlexEvent):void
		{
			takeFullViewSnapshot();
			removeFromParent(fullView);
			fullView.visible = false;
			fullView.removeEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler);
		}

		protected function get shouldPreCreateFullView():Boolean
		{
			return !_fullView && _createFullViewOnInitialize && cacheFullView && isFullViewSupported;
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount && _activeRecordAccount.primaryRecord && _activeRecordAccount.primaryRecord.bloodPressureModel)
			{
				_widgetView.model = _activeRecordAccount.primaryRecord.bloodPressureModel;
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView && _activeRecordAccount)
			{
				_fullView.model = _activeRecordAccount.primaryRecord.bloodPressureModel;
				_fullView.modality = modality;
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
			if (_activeRecordAccount.primaryRecord.bloodPressureModel)
				_activeRecordAccount.primaryRecord.bloodPressureModel.record = null;

			_activeRecordAccount.primaryRecord.bloodPressureModel = new BloodPressureModel();
		}

		private function moveMovieClipToFullView():void
		{
			if (fullViewWithSimulation)
			{
				var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as BloodPressureSimulationWidgetView);
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
			if (fullViewWithSimulation)
			{
				var bloodPressureSimulationWidgetView:BloodPressureSimulationWidgetView = (_widgetView as BloodPressureSimulationWidgetView);
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