package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.InsulinTitrationDecisionPanelController;
	import collaboRhythm.plugins.insulinTitrationSupport.model.DosageChangeValueProxy;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;
	import collaboRhythm.shared.model.medications.view.TitrationDecisionPanelBase;
	import collaboRhythm.shared.ui.buttons.view.skins.SolidFillButtonSkin;
	import collaboRhythm.shared.ui.buttons.view.skins.TransparentButtonSkin;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import flashx.textLayout.events.FlowElementMouseEvent;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;
	import mx.managers.IFocusManagerComponent;

	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.RichEditableText;
	import spark.components.SpinnerList;
	import spark.components.SpinnerListContainer;
	import spark.core.SpriteVisualElement;
	import spark.skins.mobile.SpinnerListContainerSkin;
	import spark.skins.mobile.SpinnerListSkin;

	public class InsulinTitrationDecisionPanel extends TitrationDecisionPanelBase implements IFocusManagerComponent
	{
//		public static const INSULIN_TITRATION_DECISION_PANEL_WIDTH:int = 567;
		public static const INSULIN_TITRATION_DECISION_PANEL_WIDTH:int = STEP4_X + STEP_WIDTH;

		private static const SUGGESTED_CHANGE_LABEL_COLOR:int = 0x000000;
		private static const OTHER_CHANGE_LABEL_COLOR:int = 0xBFBFBF;
		private static const SUGGESTED_CHANGE_BACKGROUND_COLOR:int = 0xF7941E;
		private static const OTHER_CHANGE_BACKGROUND_COLOR:int = 0xFFFFFF;

		private static const STEP1_X:int = 46;
		private static const STEP2_X:int = 188;
		private static const STEP3_X:int = 330;
		private static const STEP4_X:int = 472;

		public static const INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX:int = 6;

		public static const NO_CHANGE_LABEL:String = "No Change";

		private static const DOSAGE_CHANGE_BUTTON_FONT_SIZE:int = 21;
		private static const DOSAGE_NO_CHANGE_BUTTON_FONT_SIZE:int = 18;
		private static const DOSAGE_SPINNER_FONT_SIZE:int = 20;

		private var _model:InsulinTitrationDecisionPanelModel;

		private var _dosageChangeSpinnerList:SpinnerList;
		private var _dosageChangeSpinnerListContainer:SpinnerListContainer;
		private var _dosageIncreaseButton:Button;
		private var _dosageNoChangeButton:Button;
		private var _dosageDecreaseButton:Button;

		private var _step2Chart:Array;

		private var _dosageChangeSpinnerListData:ArrayCollection;

		private var _decisionClinicianNew:DecisionClinicianNew;
		private var _decisionClinicianAgree:DecisionClinicianAgree;
		private var _decisionPatientNew:DecisionPatientNew;
		private var _decisionPatientAgree:DecisionPatientAgree;
		private var _controller:InsulinTitrationDecisionPanelController;

		public function InsulinTitrationDecisionPanel()
		{
			super();
			updateMinSize();
			_instructionsTitle = "Insulin Titration (guided by 303 Protocol)";
			_learnMoreLinkText = "Learn more about insulin titration";
		}

		override protected function createChildren():void
		{
			_stepBadges.push(new Step1Badge());
			_stepBadges.push(new Step2Badge());
			_stepBadges.push(new Step3Badge());
			_stepBadges.push(new Step4Badge());
			_averagePlotItemRenderer = new AverageBloodGlucosePotItemRenderer();

			super.createChildren();

			_step2Chart = createChart(STEP2_X, false);
			_dosageIncreaseButton = createDosageChangeButton(_chartY, 57, _model.dosageIncreaseText + " Units",
					getDosageChangeLabelColor(_model.algorithmSuggestsIncreaseDose), _model.dosageIncreaseValue, DOSAGE_CHANGE_BUTTON_FONT_SIZE);
			_dosageNoChangeButton = createDosageChangeButton(58, 48, "No Change",
					getDosageChangeLabelColor(_model.algorithmSuggestsNoChangeDose), 0, DOSAGE_NO_CHANGE_BUTTON_FONT_SIZE);
			_dosageDecreaseButton = createDosageChangeButton(106, 33, _model.dosageDecreaseText + " Units",
					getDosageChangeLabelColor(_model.algorithmSuggestsDecreaseDose), _model.dosageDecreaseValue, DOSAGE_CHANGE_BUTTON_FONT_SIZE);
			updateDosageChangeButtons();

			_dosageChangeSpinnerListContainer = new SpinnerListContainer();
			_dosageChangeSpinnerListContainer.x = STEP3_X;
			_dosageChangeSpinnerListContainer.bottom = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT + 1;
			_dosageChangeSpinnerListContainer.width = STEP_WIDTH;
			_dosageChangeSpinnerList = new SpinnerList();
			_dosageChangeSpinnerListContainer.addElement(_dosageChangeSpinnerList);
			_dosageChangeSpinnerList.setStyle("skinClass", SpinnerListSkin);
			_dosageChangeSpinnerList.setStyle("textAlign", "right");
			_dosageChangeSpinnerList.setStyle("paddingLeft", 1);
			_dosageChangeSpinnerList.setStyle("paddingRight", 1);
			_dosageChangeSpinnerList.setStyle("fontSize", DOSAGE_SPINNER_FONT_SIZE);
			_dosageChangeSpinnerListContainer.setStyle("skinClass", SpinnerListContainerSkin);
			_dosageChangeSpinnerList.percentWidth = 100;
			var spinnerData:ArrayCollection = new ArrayCollection();
			for (var i:Number = INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX; i >= -INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX; i--)
			{
				spinnerData.addItem(new DosageChangeValueProxy(i, model));
			}
			_dosageChangeSpinnerListData = spinnerData;
			_dosageChangeSpinnerList.labelFunction = dosageChangeLabelFunction;
			_dosageChangeSpinnerList.itemRenderer = new ClassFactory(DosageChangeSpinnerItemRenderer);
			_dosageChangeSpinnerList.dataProvider = spinnerData;
			setDosageChangeSpinnerListSelectedItem(_model.dosageChangeValue, false);
			_dosageChangeSpinnerList.addEventListener(Event.CHANGE, dosageChangeSpinnerList_changeHandler);
			_dosageChangeSpinnerList.wrapElements = false;

			BindingUtils.bindSetter(model_dosageChangeValue_changeHandler, _model, "dosageChangeValue");

			addElement(_dosageChangeSpinnerListContainer);

			_decisionClinicianNew = new DecisionClinicianNew();
			initializeIcon(_decisionClinicianNew);
			_decisionClinicianAgree = new DecisionClinicianAgree();
			initializeIcon(_decisionClinicianAgree);
			_decisionPatientNew = new DecisionPatientNew();
			initializeIcon(_decisionPatientNew);
			_decisionPatientAgree = new DecisionPatientAgree();
			initializeIcon(_decisionPatientAgree);
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			resizeChart(_step2Chart);
			updateDosageChangeButtons();
			// TODO: determine why the +3 is necessary to make the spinner the same height as the chart boxes
			_dosageChangeSpinnerListContainer.height = _chartHeight + 3;
		}

		override protected function updateSendButtonLabel():void
		{
			if (model.isNewDoseDifferentFromOtherPartyLatest)
			{
				_sendButton.label = model.isPatient ? "Send" : "Advise";
				_sendButton.setStyle("icon", model.isPatient ? _decisionPatientNew : _decisionClinicianNew);
			} else
			{
				_sendButton.label = "Agree";
				_sendButton.setStyle("icon", model.isPatient ? _decisionPatientAgree : _decisionClinicianAgree);
			}
		}

		protected function dosageChangeLabelFunction(valueProxy:DosageChangeValueProxy):String
		{
			var value:Number = valueProxy.value;
			if (isNaN(value))
				return "";
			else if (value == 0)
				return NO_CHANGE_LABEL;
			else
				return (value > 0 ? "+" : "") + value.toString() + " Units";
		}

		private function model_dosageChangeValue_changeHandler(value:Number):void
		{
			setDosageChangeSpinnerListSelectedItem(_model.dosageChangeValue);
		}

		protected function setDosageChangeSpinnerListSelectedItem(value:Number, animate:Boolean = true):void
		{
			var selectedItemValue:Number = isNaN(value) ? 0 : value;
			var selectedItem:DosageChangeValueProxy;
			for each (var item:DosageChangeValueProxy in _dosageChangeSpinnerListData)
			{
				if (item.value == selectedItemValue)
				{
					selectedItem = item;
					break;
				}
			}

			if (animate)
			{
				var index:int = _dosageChangeSpinnerListData.getItemIndex(selectedItem);
				_dosageChangeSpinnerList.mx_internal::animateToSelectedIndex(index);
			}
			else
			{
				_dosageChangeSpinnerList.selectedItem = selectedItem;
			}
		}

		private function updateDosageChangeButtons():void
		{
			_dosageNoChangeButton.y = chartValueToPosition(modelBase.goalZoneMaximum) + 1;
			_dosageDecreaseButton.y = chartValueToPosition(modelBase.goalZoneMinimum) + 1;
			_dosageIncreaseButton.height = _dosageNoChangeButton.y - _dosageIncreaseButton.y - 1;
			_dosageNoChangeButton.height = _dosageDecreaseButton.y - _dosageNoChangeButton.y - 1;
			// TODO: figure out why the +2 is required to make this button fit
			_dosageDecreaseButton.height = chartValueToPosition(modelBase.verticalAxisMinimum) - _dosageDecreaseButton.y + 2;

			// TODO: need to invalidateDisplayList when any inputs to algorithm change so that the button label colors will be updated
			setStylesForSuggestedAction(_dosageIncreaseButton, _model.algorithmSuggestsIncreaseDose);
			setStylesForSuggestedAction(_dosageNoChangeButton, _model.algorithmSuggestsNoChangeDose);
			setStylesForSuggestedAction(_dosageDecreaseButton, _model.algorithmSuggestsDecreaseDose);
		}

		private function setStylesForSuggestedAction(button:Button, isSuggested:Boolean):void
		{
			button.setStyle("color", getDosageChangeLabelColor(isSuggested));
			button.setStyle("chromeColor", isSuggested ? SUGGESTED_CHANGE_BACKGROUND_COLOR : OTHER_CHANGE_BACKGROUND_COLOR);
			button.setStyle("skinClass", isSuggested ? SolidFillButtonSkin : TransparentButtonSkin);
		}

		private function getDosageChangeLabelColor(isSuggested:Boolean):int
		{
			return isSuggested ? SUGGESTED_CHANGE_LABEL_COLOR : OTHER_CHANGE_LABEL_COLOR;
		}

		private function createDosageChangeButton(y:int, height:int, label:String, labelColor:int,
												  dosageChangeValue:Number, fontSize:int):Button
		{
			var button:Button = new Button();
			button.setStyle("skinClass", TransparentButtonSkin);
			button.x = STEP2_X + 1;
			button.y = y;
			button.width = STEP_WIDTH - 1;
			button.height = height;
			button.label = label;
			button.setStyle("color", labelColor);
			button.setStyle("fontSize", fontSize);
			button.addEventListener(MouseEvent.CLICK,
			            function(event:MouseEvent):void {
							_controller.setDosageChangeValue(dosageChangeValue);
			            });
			addElement(button);
			return button;
		}

		private function dosageChangeSpinnerList_changeHandler(event:Event):void
		{
			_controller.setDosageChangeValue((_dosageChangeSpinnerList.selectedItem as DosageChangeValueProxy).value);
		}

		public function get model():InsulinTitrationDecisionPanelModel
		{
			return _model;
		}

		public function set model(value:InsulinTitrationDecisionPanelModel):void
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

		public function get controller():InsulinTitrationDecisionPanelController
		{
			return _controller;
		}

		public function set controller(controller:InsulinTitrationDecisionPanelController):void
		{
			_controller = controller;
		}

		override protected function get controllerBase():TitrationDecisionPanelControllerBase
		{
			return _controller;
		}

		override protected function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			super.model_propertyChangeHandler(event);
			if (event.property == "isNewDoseDifferentFromOtherPartyLatest")
			{
				updateSendButtonLabel();
			}
			if (event.property == "dosageChangeValue")
			{
				setDosageChangeSpinnerListSelectedItem(_model.dosageChangeValue);
			}
		}
	}
}
