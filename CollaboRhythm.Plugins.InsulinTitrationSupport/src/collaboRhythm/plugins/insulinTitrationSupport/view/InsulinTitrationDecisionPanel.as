package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.skins.SolidFillButtonSkin;
	import collaboRhythm.plugins.insulinTitrationSupport.view.skins.TransparentButtonSkin;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.ui.healthCharts.view.DashedGraphicUtilities;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import flashx.textLayout.conversion.TextConverter;

	import mx.core.IVisualElement;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import spark.components.Button;
	import spark.components.CalloutButton;
	import spark.components.Group;
	import spark.components.RichText;
	import spark.components.TextInput;
	import spark.primitives.Rect;
	import spark.skins.mobile.StageTextInputSkin;

	public class InsulinTitrationDecisionPanel extends Group
	{
		private var _model:InsulinTitrationDecisionPanelModel;

		private var _dosageChangeTextInput:TextInput;
		private var _arrow1CalloutButton:CalloutButton;
		private var _arrow2CalloutButton:CalloutButton;
		private var _arrow3CalloutButton:CalloutButton;
		private var _dosageIncreaseButton:Button;
		private var _dosageNoChangeButton:Button;
		private var _dosageDecreaseButton:Button;

		private static const SUGGESTED_CHANGE_LABEL_COLOR:int = 0x000000;
		private static const OTHER_CHANGE_LABEL_COLOR:int = 0xBFBFBF;
		private static const SUGGESTED_CHANGE_BACKGROUND_COLOR:int = 0xF7941E;
		private static const OTHER_CHANGE_BACKGROUND_COLOR:int = 0xFFFFFF;

		private const PREREQUISITE_SATISFIED_ARROW_ALPHA:Number = 1;
		private const PREREQUISITE_NOT_SATISFIED_ARROW_ALPHA:Number = 0.25;

		public var _chartY:Number;
		private var _chartHeight:Number;

		private static const STEP_ARROW_BUTTON_WIDTH:int = 48;

		private static const STEP1_X:int = 48;
		private static const STEP2_X:int = 208;
		private static const STEP3_X:int = 368;

		private static const STEP_WIDTH:int = 110;
		private var _step1Chart:Array;
		private var _step2Chart:Array;

		public function InsulinTitrationDecisionPanel()
		{
			minHeight = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT * 2;
			minWidth = STEP3_X + STEP_WIDTH;
		}

		override protected function measure():void
		{
			super.measure();
		}

		private var _averagePlotItemRenderer:AverageBloodGlucosePotItemRenderer;

		override protected function createChildren():void
		{
			super.createChildren();
			var titrationPanelMockup:TitrationPanelMockup = new TitrationPanelMockup();
			titrationPanelMockup.bottom = 0;
			addElement(titrationPanelMockup);

			_arrow1CalloutButton = createArrowCalloutButton(0, _model.step1State);
			_arrow2CalloutButton = createArrowCalloutButton(STEP2_X - STEP_ARROW_BUTTON_WIDTH, _model.step2State);
			_arrow3CalloutButton = createArrowCalloutButton(STEP3_X - STEP_ARROW_BUTTON_WIDTH, _model.step3State);

			_chartY = 1;
			determineChartHeight();
			_step1Chart = createChart(STEP1_X);
			_step2Chart = createChart(STEP2_X);
			_dosageIncreaseButton = createDosageChangeButton(_chartY, 57, _model.dosageIncreaseText + " Units", getDosageChangeLabelColor(_model.algorithmSuggestsIncreaseDose), _model.dosageIncreaseText);
			_dosageNoChangeButton = createDosageChangeButton(58, 48, "No Change", getDosageChangeLabelColor(_model.algorithmSuggestsNoChangeDose), "0");
			_dosageDecreaseButton = createDosageChangeButton(106, 33, _model.dosageDecreaseText + " Units", getDosageChangeLabelColor(_model.algorithmSuggestsDecreaseDose), _model.dosageDecreaseText);
			updateDosageChangeButtons();

			_averagePlotItemRenderer = new AverageBloodGlucosePotItemRenderer();
			_averagePlotItemRenderer.x = 102 - _averagePlotItemRenderer.width / 2;
			updateAveragePlotItemRenderer();
			addElement(_averagePlotItemRenderer);

			_dosageChangeTextInput = new TextInput();
			_dosageChangeTextInput.x = STEP3_X;
			_dosageChangeTextInput.bottom = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT;
			_dosageChangeTextInput.width = STEP_WIDTH;
			_dosageChangeTextInput.setStyle("skinClass", StageTextInputSkin);
			_dosageChangeTextInput.setStyle("fontSize", 32);
			_dosageChangeTextInput.setStyle("textAlign", "right");
			_dosageChangeTextInput.restrict = "\\-+0-9";
//			_dosageChangeTextInput.maxChars = 3;
			_dosageChangeTextInput.softKeyboardType = "number";
			_dosageChangeTextInput.addEventListener(Event.CHANGE, dosageChangeTextInput_changeHandler);

			addElement(_dosageChangeTextInput);
		}

		private function updateAveragePlotItemRenderer():void
		{
			if (_model.isAverageAvailable)
			{
				if (_model.areBloodGlucoseRequirementsMet)
				{
					_averagePlotItemRenderer.alpha = 1;
				}
				else
				{
					_averagePlotItemRenderer.alpha = 0.5
				}

				_averagePlotItemRenderer.y = chartValueToPosition(_model.bloodGlucoseAverage) -
						_averagePlotItemRenderer.height / 2;
				_averagePlotItemRenderer.visible = true;
			}
			else
			{
				_averagePlotItemRenderer.visible = false;
			}
		}

		private function updateDosageChangeButtons():void
		{
			_dosageNoChangeButton.y = chartValueToPosition(_model.goalZoneMaximum) + 1;
			_dosageDecreaseButton.y = chartValueToPosition(_model.goalZoneMinimum) + 1;
			_dosageIncreaseButton.height = _dosageNoChangeButton.y - _dosageIncreaseButton.y - 1;
			_dosageNoChangeButton.height = _dosageDecreaseButton.y - _dosageNoChangeButton.y - 1;
			_dosageDecreaseButton.height = chartValueToPosition(_model.verticalAxisMinimum) - _dosageDecreaseButton.y + 1;

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

		private function determineChartHeight():void
		{
			_chartHeight = Math.max(height, minHeight) - SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT - 1 - 2;
		}

		public function createChart(x:int):Array
		{
			var chartBorder:Rect = new Rect();
			chartBorder.x = x;
			chartBorder.width = STEP_WIDTH;
			chartBorder.stroke = new SolidColorStroke();
			chartBorder.fill = new SolidColor(0xFFFFFF);

			var goalMaxLine:DottedLine = createGoalLine(x);
			var goalMinLine:DottedLine = createGoalLine(x);
			var chart:Array = [chartBorder, goalMaxLine, goalMinLine];
			resizeChart(chart);

			addElement(chartBorder);
			addElement(goalMaxLine);
			addElement(goalMinLine);

			return chart;
		}

		private function createGoalLine(x:int):DottedLine
		{
			var goalMaxLine:DottedLine = new DottedLine();
			goalMaxLine.dotColor = 0x808285;
			goalMaxLine.dotWidth = 12;
			goalMaxLine.spacerWidth = 12;
			goalMaxLine.dotHeight = 1;
			goalMaxLine.spacerHeight = 1;
			goalMaxLine.x = x + 1;
			goalMaxLine.width = STEP_WIDTH - 1;
			goalMaxLine.height = 1;
			return goalMaxLine;
		}

		private function resizeChart(chart:Array):void
		{
			var chartBorder:Rect = chart[0];
			var goalMaxLine:DottedLine = chart[1];
			var goalMinLine:DottedLine = chart[2];

			chartBorder.y = _chartY - 1;
			chartBorder.height = _chartHeight + 2;
			goalMaxLine.y = chartValueToPosition(_model.goalZoneMaximum);
			goalMinLine.y = chartValueToPosition(_model.goalZoneMinimum);
		}

		private function chartValueToPosition(bloodGlucoseAverage:Number):Number
		{
			return Math.round(map(bloodGlucoseAverage, _model.verticalAxisMinimum, _model.verticalAxisMaximum, _chartY + _chartHeight, _chartY));
		}

		private static function map(x:Number, inMin:Number, inMax:Number, outMin:Number, outMax:Number):Number
		{
			return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
		}

		private function getDosageChangeLabelColor(isSuggested:Boolean):int
		{
			return isSuggested ? SUGGESTED_CHANGE_LABEL_COLOR : OTHER_CHANGE_LABEL_COLOR;
		}

		private function createDosageChangeButton(y:int, height:int, label:String, labelColor:int,
												  dosageChangeTextInputText:String):Button
		{
			var button:Button = new Button();
			button.setStyle("skinClass", TransparentButtonSkin);
			button.x = STEP2_X + 1;
			button.y = y;
			button.width = STEP_WIDTH - 1;
			button.height = height;
			button.label = label;
			button.setStyle("color", labelColor);
			button.addEventListener(MouseEvent.CLICK,
			            function(event:MouseEvent):void {
			                _dosageChangeTextInput.text = dosageChangeTextInputText;
			            });
			addElement(button);
			return button;
		}

		private function createArrowCalloutButton(x:int, stepState:String):CalloutButton
		{
			var calloutButton:CalloutButton = new CalloutButton();
			calloutButton.setStyle("skinClass", TransparentButtonSkin);
			calloutButton.setStyle("paddingLeft", 8);
			calloutButton.setStyle("paddingRight", 8);
			calloutButton.setStyle("paddingTop", 8);
			calloutButton.setStyle("paddingBottom", 8);
			updateArrow(calloutButton, stepState);
			calloutButton.x = x;
			updateArrowButtonY(calloutButton);
			addElement(calloutButton);
			return calloutButton;
		}

		private function updateArrowButtonY(calloutButton:CalloutButton):void
		{
			calloutButton.y = _chartHeight / 2 - calloutButton.height / 2;
		}

		private function updateArrow(calloutButton:CalloutButton, stepState:String):void
		{
			var arrow:IVisualElement;
			var contentArray:Array = new Array();
			var richText:RichText = new RichText();
			richText.setStyle("paddingTop", 5);
			richText.setStyle("paddingBottom", 5);
			richText.setStyle("paddingLeft", 5);
			richText.setStyle("paddingRight", 5);
			richText.setStyle("fontSize", 32);
			richText.percentWidth = 100;
			richText.percentHeight = 100;
			switch (stepState)
			{
				case InsulinTitrationDecisionPanelModel.STEP_SATISFIED:
					arrow = new DecisionSupportArrow();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have been satisfied.", TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				case InsulinTitrationDecisionPanelModel.STEP_STOP:
					arrow = new DecisionSupportArrowStop();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have <b>not</b> been satisfied.", TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				default:
					arrow = new DecisionSupportArrowDisabled();
					richText.textFlow = TextConverter.importToFlow("The requirements for a <b>previous</b> step of the algorithm have <b>not</b> been satisfied.", TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
			}
			calloutButton.setStyle("icon", arrow);
			contentArray.push(richText);
			calloutButton.calloutContent = contentArray;
		}

		private function dosageChangeTextInput_changeHandler(event:Event):void
		{
			_model.dosageChangeValue = StringUtils.isEmpty(_dosageChangeTextInput.text) ? NaN : Number(_dosageChangeTextInput.text);
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

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "step1State")
			{
				updateArrow(_arrow1CalloutButton, _model.step1State);
			}
			if (event.property == "step2State")
			{
				updateArrow(_arrow2CalloutButton, _model.step2State);
			}
			if (event.property == "step3State")
			{
				updateArrow(_arrow3CalloutButton, _model.step3State);
			}
			if (event.property == "bloodGlucoseAverage")
			{
				invalidateDisplayList();
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			determineChartHeight();
			resizeChart(_step1Chart);
			resizeChart(_step2Chart);
			updateDosageChangeButtons();
			updateAveragePlotItemRenderer();
			updateArrowButtonY(_arrow1CalloutButton);
			updateArrowButtonY(_arrow2CalloutButton);
			updateArrowButtonY(_arrow3CalloutButton);
		}
	}
}
