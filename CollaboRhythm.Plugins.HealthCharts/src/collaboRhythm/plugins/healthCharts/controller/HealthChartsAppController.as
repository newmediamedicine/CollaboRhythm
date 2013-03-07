package collaboRhythm.plugins.healthCharts.controller
{
	import collaboRhythm.plugins.healthCharts.view.HealthChartsButtonWidgetView;
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsEvent;
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.BackgroundProcessCollectionModel;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.ui.healthCharts.model.HealthChartsScrollEvent;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import com.dougmccune.controls.ChartDataTipsLocation;

	import com.dougmccune.controls.SynchronizedScrollData;

	import flash.events.Event;

	import flash.events.MouseEvent;

	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;

	import spark.components.Button;
	import spark.components.View;
	import spark.skins.mobile.TransparentActionButtonSkin;

	public class HealthChartsAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Health Charts";
		private static const HEALTHCHARTSAPPCONTROLLER_UPDATINGVIEW:String = "HealthChartsAppController_UpdatingView";

		private var _widgetView:HealthChartsButtonWidgetView;
		private var _fullView:SynchronizedHealthCharts;
		private var _healthChartsModel:HealthChartsModel;
		private var _synchronizationService:SynchronizationService;
		private var _backgroundProcessModel:BackgroundProcessCollectionModel;

		public function HealthChartsAppController(constructorParams:AppControllerConstructorParams)
		{
			_backgroundProcessModel = BackgroundProcessCollectionModel(WorkstationKernel.instance.resolve(BackgroundProcessCollectionModel));
			super(constructorParams);
			cacheFullView = true;
			createFullViewOnInitialize = true;

			_synchronizationService = new SynchronizationService(this,
					_collaborationLobbyNetConnectionServiceProxy as CollaborationLobbyNetConnectionServiceProxy);
		}

		override public function initialize():void
		{
			super.initialize();
			if (!_fullView && _fullContainer)
			{
				createFullView();
				prepareFullView();
			}
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

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new HealthChartsButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new SynchronizedHealthCharts();
			return _fullView;
		}

		override public function reloadUserData():void
		{
			removeUserData();
			doPrecreationForFullView();
			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, healthChartsModel);
			}
		}

		override protected function prepareFullView():void
		{
			super.prepareFullView();
			_fullView.addEventListener(HealthChartsScrollEvent.SCROLL_CHARTS, fullView_scrollChartsHandler);
			_fullView.addEventListener(HealthChartsEvent.CHART_DATA_TIPS_UPDATE, fullView_chartDataTipsUpdateHandler);
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.model = healthChartsModel;
				_fullView.modality = modality;
				_fullView.componentContainer = _componentContainer;
				_fullView.activeAccountId = activeAccount.accountId;
				_fullView.viewNavigator = _viewNavigator;
				_fullView.collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			}
		}

		override protected function prepareFullViewContainer(view:View):void
		{
			super.prepareFullViewContainer(view);
			if (_fullView)
				_fullView.createActionButtons(view);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get healthChartsModel():HealthChartsModel
		{
			if (!_healthChartsModel)
			{
				_healthChartsModel = _activeRecordAccount.primaryRecord.healthChartsModel;
				_healthChartsModel.addEventListener(HealthChartsEvent.SAVE, healthChartsModel_saveHandler)
			}
			return _healthChartsModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as HealthChartsButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as SynchronizedHealthCharts;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		protected override function removeUserData():void
		{
			if (_fullView)
			{
				_fullView.destroy();
				_fullView = null;
			}
			_healthChartsModel = null;
		}

		override public function close():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
				_synchronizationService = null;
			}

			super.close();
		}

		override protected function hideFullViewComplete():void
		{
			super.hideFullViewComplete();
			updateFullViewTitle();
		}

		override protected function updateFullViewTitle():void
		{
			if (healthChartsModel.decisionPending && healthChartsModel.decisionTitle)
				fullViewTitle = healthChartsModel.decisionTitle;
			else
				fullViewTitle = name;
		}

		override protected function showFullViewStart():void
		{
			super.showFullViewStart();
			updateFullViewTitle();
			if (fullView)
			{
				backgroundProcessModel.updateProcess(HEALTHCHARTSAPPCONTROLLER_UPDATINGVIEW, "Updating...", true);
				fullView.addEventListener(FlexEvent.UPDATE_COMPLETE, view_updateCompleteHandler2,
						false, 0, true);

				_fullView.prepareToShowView(sparkView);
				updateSaveButton(healthChartsModel.decisionPending);
			}
		}

		private function updateSaveButton(decisionPending:Boolean):void
		{
			if (sparkView && sparkView.actionContent)
			{
				var foundSaveButton:Boolean = false;
				for each (var component:IVisualElement in sparkView.actionContent)
				{
					var button:Button = component as Button;
					if (button && button.label == "Save")
					{
						foundSaveButton = true;

						// hide save button if it is not needed
						button.visible = decisionPending;
						button.includeInLayout = decisionPending;

						break;
					}
				}

				if (foundSaveButton)
					return;

				if (decisionPending)
				{
					var saveButton:Button = new Button();
					saveButton.label = "Save";
					saveButton.addEventListener(MouseEvent.CLICK, saveButton_clickHandler, false, 0, true);
					saveButton.setStyle("skinClass", TransparentActionButtonSkin);
					sparkView.actionContent.unshift(saveButton);
				}
			}

		}

		private function saveButton_clickHandler(event:MouseEvent):void
		{
			save();
		}

		private function save():void
		{
			if (_fullView.save())
			{
				if (_healthChartsModel && _healthChartsModel.record)
					_healthChartsModel.record.saveAllChanges();

				if (_collaborationLobbyNetConnectionServiceProxy.collaborationState != CollaborationModel.COLLABORATION_ACTIVE)
					closeFullView();
			}
		}

		private function healthChartsModel_saveHandler(event:HealthChartsEvent):void
		{
			save();
		}

		public function showHealthChartsFullView(viaMechanism:String):void
		{
			if (_synchronizationService.synchronize("showHealthChartsFullView", viaMechanism))
			{
				return;
			}

			if (_healthChartsModel)
			{
				healthChartsModel.finishedDecision();
				dispatchShowFullView(viaMechanism);
			}
		}

		private function fullView_addedToStageHandler(event:Event):void
		{
			var view:UIComponent = event.target as UIComponent;
			if (view)
			{
				backgroundProcessModel.updateProcess(HEALTHCHARTSAPPCONTROLLER_UPDATINGVIEW, "Updating...", true);
				event.target.addEventListener(FlexEvent.UPDATE_COMPLETE, view_updateCompleteHandler2,
						false, 0, true);
			}
		}

		private function view_updateCompleteHandler1(event:FlexEvent):void
		{
			event.target.removeEventListener(FlexEvent.UPDATE_COMPLETE, view_updateCompleteHandler1);
			event.target.addEventListener(FlexEvent.UPDATE_COMPLETE, view_updateCompleteHandler2,
					false, 0, true);
		}

		private function view_updateCompleteHandler2(event:FlexEvent):void
		{
			event.target.removeEventListener(FlexEvent.UPDATE_COMPLETE, view_updateCompleteHandler2);
			backgroundProcessModel.updateProcess(HEALTHCHARTSAPPCONTROLLER_UPDATINGVIEW, "Updating...", false);
		}

		public function get backgroundProcessModel():BackgroundProcessCollectionModel
		{
			return _backgroundProcessModel;
		}

		public function updateVisibleChartsScrollPositions(synchronizedScrollData:SynchronizedScrollData):void
		{
			if (_synchronizationService.synchronize("updateVisibleChartsScrollPositions", synchronizedScrollData, false))
			{
				return;
			}

			if (_healthChartsModel)
			{
				_healthChartsModel.synchronizedScrollData = synchronizedScrollData;
			}
		}

		private function fullView_scrollChartsHandler(event:HealthChartsScrollEvent):void
		{
			event.synchronizedScrollData.sourceId = "collaboration-" + event.synchronizedScrollData.sourceId;
			updateVisibleChartsScrollPositions(event.synchronizedScrollData);
		}

		public function updateChartDataTips(chartDataTipsLocation:ChartDataTipsLocation):void
		{
			if (_synchronizationService.synchronize("updateChartDataTips", chartDataTipsLocation, false))
			{
				return;
			}

			if (_healthChartsModel)
			{
				_healthChartsModel.chartDataTipsLocation = chartDataTipsLocation;
			}
		}

		private function fullView_chartDataTipsUpdateHandler(event:HealthChartsEvent):void
		{
			updateChartDataTips(_fullView.chartDataTipsLocation);
		}
	}
}
