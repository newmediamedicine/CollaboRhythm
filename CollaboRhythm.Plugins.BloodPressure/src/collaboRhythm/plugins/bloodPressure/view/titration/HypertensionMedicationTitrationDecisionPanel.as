package collaboRhythm.plugins.bloodPressure.view.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationDecisionPanelController;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;
	import collaboRhythm.shared.model.medications.view.TitrationDecisionPanelBase;

	import flash.events.MouseEvent;

	import mx.events.PropertyChangeEvent;

	import spark.components.Button;

	import spark.components.Group;
	import spark.components.VGroup;
	import spark.skins.mobile.ButtonSkin;

	public class HypertensionMedicationTitrationDecisionPanel extends TitrationDecisionPanelBase
	{
		public static const TITRATION_DECISION_PANEL_WIDTH:Number = 567;
		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var _controller:HypertensionMedicationTitrationDecisionPanelController;
		private var _showMapButton:Button;
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
			_showMapButton.label = "Show\nMAP";
			_showMapButton.x = getStepX(1);
			updateArrowButtonY(_showMapButton);
			_showMapButton.width = STEP_WIDTH;
			_showMapButton.setStyle("skinClass", ButtonSkin);
			_showMapButton.addEventListener(MouseEvent.CLICK, showMapButton_clickHandler);
			addElement(_showMapButton);

			_mapView = new TitrationMapView();
			_mapView.controller = controller;
			_mapView.visible = false;
			_mapView.includeInLayout = false;
			updateMapView();
			addElement(_mapView);
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// update components unique to this subclass
			updateArrowButtonY(_showMapButton);
			updateMapView();
		}

		protected function updateMapView():void
		{
			var chartsContainer:VGroup = this.owner.parent as VGroup;
			var chartsContainerPaddingTop:Number = (chartsContainer ? chartsContainer.paddingTop : 0);
			_mapView.height = chartsContainer ? chartsContainer.height : this.height;
			_mapView.y = -_instructionsScroller.height - (chartsContainerPaddingTop * 2);
			_mapView.width = chartsContainer ? (chartsContainer.width - chartsContainer.paddingLeft - chartsContainer.paddingRight - this.width) : 0;
			_mapView.x = -_mapView.width;
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
			_mapView.visible = !_mapView.visible;

			if (_mapView.visible)
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
