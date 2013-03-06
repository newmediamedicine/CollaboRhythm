package collaboRhythm.plugins.bloodPressure.view.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationDecisionPanelController;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;
	import collaboRhythm.shared.model.medications.view.TitrationDecisionPanelBase;

	import flash.events.MouseEvent;

	import flashx.textLayout.container.ScrollPolicy;

	import mx.core.ClassFactory;

	import mx.core.IFactory;
	import mx.core.IVisualElementContainer;

	import mx.events.PropertyChangeEvent;
	import mx.managers.IFocusManagerComponent;

	import spark.components.Button;

	import spark.components.Group;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.skins.mobile.ButtonSkin;

	public class HypertensionMedicationTitrationDecisionPanel extends TitrationDecisionPanelBase implements IFocusManagerComponent
	{
		public static const TITRATION_DECISION_PANEL_WIDTH:Number = 567;
		private static const SELECTION_LIST_VERTICAL_OFFSET:int = 6;

		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var _controller:HypertensionMedicationTitrationDecisionPanelController;
		private var _showMapButton:Button;
		private var _mapSelectionsList:List;
		private var _currentAccountSelectionsList:List;
		private var _mapView:TitrationMapView;

		public function HypertensionMedicationTitrationDecisionPanel()
		{
			super();
			numSteps = 3;
			updateMinSize();
			_instructionsTitle = "Medication Adjustment Plan (MAP)";
			_learnMoreLinkText = "Learn more about hypertension";
			_instructionsTitleFontSize = 24;
		}

		override protected function createChildren():void
		{
			_stepBadges.push(new Step1Badge());
			_stepBadges.push(new Step2Badge());
			_stepBadges.push(new Step3Badge());
			_averagePlotItemRenderer = new AverageSystolicPotItemRenderer();

			super.createChildren();

			_showMapButton = new Button();
			_showMapButton.setStyle("fontSize", SEND_BUTTON_FONT_SIZE);
			updateShowMapButtonLabel();
			_showMapButton.x = getStepX(1);
			updateArrowButtonY(_showMapButton);
			_showMapButton.width = STEP_WIDTH;
			_showMapButton.setStyle("skinClass", ButtonSkin);
			_showMapButton.addEventListener(MouseEvent.CLICK, showMapButton_clickHandler);
			addElement(_showMapButton);

			_mapSelectionsList = createSelectionsList(2);
			_mapSelectionsList.itemRenderer = new ClassFactory(HypertensionMedicationDoseSelectionSmallItemRenderer);
			_mapSelectionsList.dataProvider = _model.currentSelectionsArrayCollection;
			addElement(_mapSelectionsList);

			_currentAccountSelectionsList = createSelectionsList(3);
			_currentAccountSelectionsList.itemRenderer = new ClassFactory(HypertensionMedicationDoseSelectionSmallItemRenderer);
			_currentAccountSelectionsList.dataProvider = _model.currentActiveAccountSelectionsArrayCollection;
			addElement(_currentAccountSelectionsList);

			updateSelectionListsY();

			_mapView = new TitrationMapView();
			_mapView.controller = controller;
			_mapView.visible = false;
			_mapView.includeInLayout = false;
			updateMapView();
			var mapViewContainer:IVisualElementContainer = getHealthChartsView();
			if (mapViewContainer == null) mapViewContainer = this;
			mapViewContainer.addElement(_mapView);
		}

		protected function getHealthChartsView():IVisualElementContainer
		{
			var chartsContainer:VGroup = getChartsContainer();

			return chartsContainer && chartsContainer.parent ? (chartsContainer.parent as IVisualElementContainer) : null;
		}

		private function createSelectionsList(stepNumber:int):List
		{
			var selectionsList:List = new List();
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.gap = 1;
			selectionsList.layout = horizontalLayout;
			selectionsList.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
			selectionsList.setStyle("contentBackgroundAlpha", 0);
			selectionsList.maxWidth = STEP_WIDTH;
			selectionsList.height = 32;
			selectionsList.x = getStepX(stepNumber - 1);

			return selectionsList;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// update components unique to this subclass
			updateArrowButtonY(_showMapButton);
			updateSelectionListsY();
			updateMapView();
		}

		protected function updateMapView():void
		{
			var chartsContainer:VGroup = getChartsContainer();
			_mapView.height = chartsContainer ? chartsContainer.height : this.height;
			_mapView.width = chartsContainer ? (chartsContainer.width - chartsContainer.paddingLeft -
					chartsContainer.paddingRight - this.width) : this.width;
		}

		private function updateSelectionListsY():void
		{
			var yPosition:int = _showMapButton.y + _showMapButton.height + SELECTION_LIST_VERTICAL_OFFSET;
			_mapSelectionsList.y = yPosition;
			_currentAccountSelectionsList.y = yPosition;
		}

		protected function getChartsContainer():VGroup
		{
			var chartsContainer:VGroup = this.owner && this.owner.parent ? this.owner.parent as VGroup : null;
			return chartsContainer;
		}

		public function get model():PersistableHypertensionMedicationTitrationModel
		{
			return _model;
		}

		public function set model(value:PersistableHypertensionMedicationTitrationModel):void
		{
			if (_model)
				_model.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler);

			_model = value;

			_model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler, false, 0, true);
		}

		override public function get modelBase():TitrationDecisionModelBase
		{
			return model;
		}

		public function get controller():HypertensionMedicationTitrationDecisionPanelController
		{
			return _controller;
		}

		public function set controller(controller:HypertensionMedicationTitrationDecisionPanelController):void
		{
			_controller = controller;
		}

		override protected function get controllerBase():TitrationDecisionPanelControllerBase
		{
			return controller;
		}

		private function showMapButton_clickHandler(event:MouseEvent):void
		{
			_controller.toggleMapViewVisibility();
		}

		override protected function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			super.model_propertyChangeHandler(event);
			if (event.property == "isMapViewVisible")
			{
				updateMapViewVisibility();
			}
		}

		private function updateMapViewVisibility():void
		{
			_mapView.visible = _model.isMapViewVisible;

			updateShowMapButtonLabel();
		}

		protected function updateShowMapButtonLabel():void
		{
			if (_model.isMapViewVisible)
			{
				_showMapButton.label = "Hide\nMAP";
			}
			else
			{
				_showMapButton.label = "Show\nMAP";
			}
		}
	}
}
