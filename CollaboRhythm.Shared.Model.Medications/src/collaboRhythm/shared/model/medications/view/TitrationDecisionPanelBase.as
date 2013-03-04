package collaboRhythm.shared.model.medications.view
{
	import collaboRhythm.shared.insulinTitrationSupport.model.states.Step;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;
	import collaboRhythm.shared.model.medications.view.instructions.*;
	import collaboRhythm.shared.ui.buttons.view.skins.TransparentButtonSkin;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;

	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.core.InteractionMode;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import spark.components.Button;
	import spark.components.CalloutButton;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.core.SpriteVisualElement;
	import spark.filters.ColorMatrixFilter;
	import spark.filters.GlowFilter;
	import spark.primitives.Rect;
	import spark.skins.mobile.ButtonSkin;

	public class TitrationDecisionPanelBase extends Group
	{
		private static const PREREQUISITE_SATISFIED_ARROW_ALPHA:Number = 1;
		private static const PREREQUISITE_NOT_SATISFIED_ARROW_ALPHA:Number = 0.25;

		protected static const STEP_ARROW_BUTTON_WIDTH:int = 46;

		protected static const GOAL_LABEL_VERTICAL_OFFSET:Number = 3;

		private static const RANGE_EXCEEDED_INDICATOR_HORIZONTAL_GAP:int = 2;

		protected static const AVERAGE_PLOT_ITEM_RENDERER_X:int = 63;

		protected static const GOAL_LABEL_FONT_SIZE:int = 21;
		protected static const ARROW_CALLOUT_INSTRUCTIONS_FONT_SIZE:int = 24;
		protected static const SEND_BUTTON_FONT_SIZE:int = 16;
		private static const SEND_BUTTON_FONT_SIZE_SMALL:int = 14;

		protected var _chartY:Number;
		protected var _chartHeight:Number;

		protected var _averageLabel:Label;

		protected var _greyScaleFilter:ColorMatrixFilter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);

		protected var _maximumExceededIndicator:MaximumExceededIndicator;
		protected var _minimumExceededIndicator:MaximumExceededIndicator;
		protected var _sendButton:Button;

		protected var _instructionsScroller:Scroller;

		protected static const STEP_WIDTH:int = 95;

		protected var _averagePlotItemRenderer:SpriteVisualElement;

		protected var _connectorMaxLine:DottedLine;
		protected var _connectorMinLine:DottedLine;

		protected var _instructionsGroup:VGroup;

		protected var _step1Chart:Array;

		private var _numSteps:int = 4;
		protected var _stepBadges:Vector.<SpriteVisualElement> = new <SpriteVisualElement>[];
		protected var _arrowCalloutButtons:Vector.<CalloutButton> = new <CalloutButton>[];
		private var _stepWidth:Number = STEP_WIDTH;
		private var _stepGap:Number = 46;

		protected var _instructionsTitle:String;
		protected var _learnMoreLinkText:String;
		protected var _instructionsTitleFontSize:int;

		public function TitrationDecisionPanelBase()
		{
			_instructionsTitleFontSize = 30;
		}

		protected function updateMinSize():void
		{
			minHeight = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT * 2;
			minWidth = (stepGap + stepWidth) * numSteps;
		}

		public function get numSteps():int
		{
			return _numSteps;
		}

		public function set numSteps(value:int):void
		{
			_numSteps = value;
		}

		public function get stepWidth():Number
		{
			return _stepWidth;
		}

		public function set stepWidth(value:Number):void
		{
			_stepWidth = value;
		}

		public function get stepGap():Number
		{
			return _stepGap;
		}

		public function set stepGap(value:Number):void
		{
			_stepGap = value;
		}

		protected static const INSTRUCTIONS_FONT_SIZE:int = 18;

		override protected function createChildren():void
		{
			super.createChildren();

			_instructionsScroller = new Scroller();
			_instructionsScroller.includeInLayout = false;
			addElement(_instructionsScroller);

			_instructionsGroup = new VGroup();
			_instructionsGroup.setStyle("fontSize", INSTRUCTIONS_FONT_SIZE);
			_instructionsScroller.viewport = _instructionsGroup;
			BindingUtils.bindSetter(instructionsScroller_viewport_verticalScrollPositionSetterHandler, _instructionsScroller.viewport, "verticalScrollPosition");
			BindingUtils.bindSetter(model_instructionsScrollPositionSetterHandler, modelBase, "instructionsScrollPosition");
			updateInstructionsText();

			for (var step:int = 0; step < _stepBadges.length; step++)
			{
				_stepBadges[step].bottom = 0;
				_stepBadges[step].x = getStepX(step);
				updateBadge(_stepBadges[step], modelBase.getStepState(step));
				addElement(_stepBadges[step]);
				_arrowCalloutButtons[step] = createArrowCalloutButton(getStepX(step) - STEP_ARROW_BUTTON_WIDTH,
						modelBase.getStepState(step), modelBase.getStepStateDescription(step));
			}

			_chartY = 1;
			determineChartHeight();
			_step1Chart = createChart(getStepX(0), true);

			_connectorMaxLine = createConnectorLine();
			addElement(_connectorMaxLine);

			_connectorMinLine = createConnectorLine();
			addElement(_connectorMinLine);

			_averagePlotItemRenderer.x = Math.round(AVERAGE_PLOT_ITEM_RENDERER_X);
			addElement(_averagePlotItemRenderer);

			_averageLabel = new Label();
			var averageLabelGlowFilter:GlowFilter = new GlowFilter();
			averageLabelGlowFilter.color = 0xFFFFFF;
			averageLabelGlowFilter.strength = 8;
			averageLabelGlowFilter.blurX = 16;
			averageLabelGlowFilter.blurY = 16;
			_averageLabel.filters = [averageLabelGlowFilter];
			_averageLabel.x = Math.round(AVERAGE_PLOT_ITEM_RENDERER_X + _averagePlotItemRenderer.width + 5);
			_averageLabel.setStyle("fontSize", GOAL_LABEL_FONT_SIZE);
			addElement(_averageLabel);

			_maximumExceededIndicator = new MaximumExceededIndicator();
			_maximumExceededIndicator.x = getStepX(0) + STEP_WIDTH - _maximumExceededIndicator.width / 2 + 1;
			addElement(_maximumExceededIndicator);

			_minimumExceededIndicator = new MaximumExceededIndicator();
			_minimumExceededIndicator.x = getStepX(0) + STEP_WIDTH - _minimumExceededIndicator.width / 2 + 1;
			addElement(_minimumExceededIndicator);

			updateAveragePlotItemRenderer();

			_sendButton = new Button();
			_sendButton.setStyle("fontSize", SEND_BUTTON_FONT_SIZE);
			updateSendButtonLabel();
			_sendButton.x = getStepX(numSteps - 1);
			updateArrowButtonY(_sendButton);
			_sendButton.width = STEP_WIDTH;
			_sendButton.setStyle("skinClass", ButtonSkin);
			_sendButton.addEventListener(MouseEvent.CLICK, sendButton_clickHandler);
			addElement(_sendButton);
		}

		private function sendButton_clickHandler(event:MouseEvent):void
		{
			controllerBase.send();
		}

		protected function updateSendButtonLabel():void
		{
			_sendButton.label = "Send";
		}

		protected function getStepX(step:int):Number
		{
			return stepGap * (step + 1) + stepWidth * (step);
		}

		private function model_instructionsScrollPositionSetterHandler(value:Number):void
		{
			if (!isNaN(value) && _instructionsScroller && _instructionsScroller.viewport)
			{
				_instructionsScroller.viewport.verticalScrollPosition = value;
			}
		}

		private function instructionsScroller_viewport_verticalScrollPositionSetterHandler(value:Number):void
		{
			controllerBase.setInstructionsScrollPosition(value);
		}

		protected function get controllerBase():TitrationDecisionPanelControllerBase
		{
			return null;
		}

		protected function updateInstructionsText():void
		{
			_instructionsGroup.removeAllElements();
			createInstructionsRichText("<p align='center'><Font size='" + _instructionsTitleFontSize + "'>" + _instructionsTitle + "</Font></p>",
					_instructionsGroup, false);

			var steps:ArrayCollection = modelBase.instructionsSteps;
			var stepIcons:Vector.<SpriteVisualElement> = new Vector.<SpriteVisualElement>();
			stepIcons.push(new Step1Icon());
			stepIcons.push(new Step2Icon());
			stepIcons.push(new Step3Icon());
			stepIcons.push(new Step4Icon());

			var isGrey:Boolean = false;
			var currentStep:int = 0;
			for each (var step:Step in steps)
			{
				var subStepsHtml:String = "";
				if (step.subSteps && step.subSteps.length > 0)
				{
					subStepsHtml = "<ul>";
					for each (var subStep:String in step.subSteps)
					{
						subStepsHtml += "<li>" +
								escapeHtml(subStep) +
								"</li>";
					}
					subStepsHtml += "</ul>";
				}

				// Once a grey step is found, stay grey for subsequent steps
				if (step.stepColor == "grey")
				{
					isGrey = true;
				}

				var stepHtml:String = "<Font color='" +
						(isGrey ? "0x888888" : "0x000000") +
						"'>" +
						escapeHtml(step.stepText) +
						subStepsHtml +
						"</Font>";

				var stepIcon:SpriteVisualElement = null;
				if (currentStep < stepIcons.length)
				{
					stepIcon = stepIcons[currentStep];
				}
				var stepGroup:HGroup = createStepGroup(stepIcon, isGrey);
				currentStep++;

				if (step.stepIcon == "warning")
				{
					var warningIcon:WarningIcon = new WarningIcon();
					warningIcon.includeInLayout = false;
					warningIcon.x = 1;
					warningIcon.y = 2;
					stepGroup.addElement(warningIcon);
				}

				createInstructionsRichText(stepHtml, stepGroup);
				_instructionsGroup.addElement(stepGroup);
			}

			var spacerIcon:Step1Icon = new Step1Icon();
			spacerIcon.visible = false;
			var learnMoreGroup:HGroup = createStepGroup(spacerIcon, false);
			var learnMoreLinkRichText:RichEditableText = createInstructionsRichText("<a>" + _learnMoreLinkText + "</a>",
					learnMoreGroup);
			addLinkClickHandler(learnMoreLinkRichText.textFlow, learnMoreLinkClickEventHandler);
			_instructionsGroup.addElement(learnMoreGroup);
		}

		protected function escapeHtml(subStep:String):String
		{
			return new XMLNode(XMLNodeType.TEXT_NODE, subStep).toString();
		}

		private function learnMoreLinkClickEventHandler(event:FlowElementMouseEvent):void
		{
			controllerBase.showFaq();
		}

		public function get modelBase():TitrationDecisionModelBase
		{
			return null;
		}

		protected function createInstructionsRichText(source:String, parentGroup:Group,
													  addPaddingTop:Boolean = true):RichEditableText
		{
			var richText:RichEditableText = new RichEditableText();
			richText.editable = false;
			richText.selectable = false;
			richText.setStyle("interactionMode", InteractionMode.TOUCH);
			if (addPaddingTop)
				richText.setStyle("paddingTop", 5);
			richText.setStyle("paddingBottom", 5);
			richText.setStyle("paddingLeft", 5);

			richText.textFlow = TextConverter.importToFlow(source, TextConverter.TEXT_FIELD_HTML_FORMAT);
			richText.percentWidth = 100;

			parentGroup.addElement(richText);
			return richText;
		}

		protected function updateBadge(badge:SpriteVisualElement, stepState:String):void
		{
			if (stepState != TitrationDecisionModelBase.STEP_SATISFIED)
			{
				badge.filters = [_greyScaleFilter];
				badge.alpha = 0.3;
			}
			else
			{
				badge.filters = [];
				badge.alpha = 1;
			}
		}

		protected function createArrowCalloutButton(x:int, stepState:String,
													stepStateDescription:String):CalloutButton
		{
			var calloutButton:CalloutButton = new CalloutButton();
			calloutButton.setStyle("skinClass", TransparentButtonSkin);
			calloutButton.setStyle("paddingLeft", 8);
			calloutButton.setStyle("paddingRight", 8);
			calloutButton.setStyle("paddingTop", 8);
			calloutButton.setStyle("paddingBottom", 8);
			updateArrow(calloutButton, stepState, stepStateDescription);
			calloutButton.x = x;
			updateArrowButtonY(calloutButton);
			addElement(calloutButton);
			return calloutButton;
		}

		protected function updateArrowButtonY(button:Button):void
		{
			button.y = Math.round(_chartHeight / 2 - button.height / 2);
		}

		protected function updateArrow(calloutButton:CalloutButton, stepState:String,
									   stepStateDescription:String):void
		{
			var arrow:IVisualElement;
			var contentArray:Array = new Array();
			var richText:RichText = new RichText();
			richText.setStyle("paddingTop", 5);
			richText.setStyle("paddingBottom", 5);
			richText.setStyle("paddingLeft", 5);
			richText.setStyle("paddingRight", 5);
			richText.setStyle("fontSize", ARROW_CALLOUT_INSTRUCTIONS_FONT_SIZE);
			richText.percentWidth = 100;
			richText.percentHeight = 100;
			// This is a workaround for an what seems to be a bug in the CalloutButton. Without setting the width the
			// Callout will be positioned incorrectly, perhaps because of the way that the flow layout of the RichText
			// elements work.
			richText.addEventListener(Event.ADDED_TO_STAGE, function (event:Event):void
			{
				richText.width = stage.width * 0.5;
				stage.addEventListener(Event.RESIZE, function (event:Event):void
				{
					richText.width = stage.width * 0.5;
				});
			});
			switch (stepState)
			{
				case TitrationDecisionModelBase.STEP_SATISFIED:
					arrow = new DecisionSupportArrow();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have been satisfied. " +
							stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				case TitrationDecisionModelBase.STEP_STOP:
					arrow = new DecisionSupportArrowStop();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have <b>not</b> been satisfied. " +
							stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				default:
					arrow = new DecisionSupportArrowDisabled();
					richText.textFlow = TextConverter.importToFlow("The requirements for a <b>previous</b> step of the algorithm have <b>not</b> been satisfied. " +
							stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
			}
			calloutButton.setStyle("icon", arrow);
			contentArray.push(richText);
			calloutButton.calloutContent = contentArray;
		}

		protected function createStepGroup(stepIcon:SpriteVisualElement, isGrey:Boolean):HGroup
		{
			var stepGroup:HGroup = new HGroup();
			stepGroup.percentWidth = 100;
			stepGroup.paddingLeft = 20;
			if (stepIcon)
			{
				if (isGrey)
				{
					stepIcon.filters = [_greyScaleFilter];
					stepIcon.alpha = 0.3;
				}
				stepGroup.addElement(stepIcon);
			}
			return stepGroup;
		}

		/**
		 * Converts the html string (from the resources) into a TextFlow object
		 * using the TextConverter class. Then it iterates through all the
		 * elements in the TextFlow until it finds a LinkElement, and adds a
		 * FlowElementMouseEvent.CLICK event handler to that Link Element.
		 *
		 * @author http://flexdevtips.blogspot.com/2010/10/displaying-html-text-in-labels.html
		 */
		public static function addLinkClickHandler(textFlow:TextFlow, linkClickedHandler:Function):TextFlow
		{
			var link:LinkElement = findLinkElement(textFlow);
			if (link != null)
			{
				link.addEventListener(FlowElementMouseEvent.CLICK,
						linkClickedHandler, false, 0, true);
			} else
			{
				trace("Warning - couldn't find link tag");
			}
			return textFlow;
		}

		/**
		 * Finds the first LinkElement recursively and returns it.
		 */
		private static function findLinkElement(group:FlowGroupElement):LinkElement
		{
			var childGroups:Array = [];
			// First check all the child elements of the current group,
			// Also save any children that are FlowGroupElement
			for (var i:int = 0; i < group.numChildren; i++)
			{
				var element:FlowElement = group.getChildAt(i);
				if (element is LinkElement)
				{
					return (element as LinkElement);
				} else if (element is FlowGroupElement)
				{
					childGroups.push(element);
				}
			}
			// Recursively check the child FlowGroupElements now
			for (i = 0; i < childGroups.length; i++)
			{
				var childGroup:FlowGroupElement = childGroups[i];
				var link:LinkElement = findLinkElement(childGroup);
				if (link != null)
				{
					return link;
				}
			}
			return null;
		}

		protected function chartValueToPosition(value:Number):Number
		{
			return Math.round(map(value, modelBase.verticalAxisMinimum, modelBase.verticalAxisMaximum,
					_chartY + _chartHeight, _chartY));
		}

		private static function map(x:Number, inMin:Number, inMax:Number, outMin:Number, outMax:Number):Number
		{
			return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
		}

		public function createChart(x:int, showLabels:Boolean):Array
		{
			var chartBorder:Rect = new Rect();
			chartBorder.x = x;
			chartBorder.width = STEP_WIDTH;
			chartBorder.stroke = new SolidColorStroke();
			chartBorder.fill = new SolidColor(0xFFFFFF);

			var goalMaxLine:DottedLine = createGoalLine(x);
			var goalMinLine:DottedLine = createGoalLine(x);
			if (showLabels)
			{
				var goalMaxLabel:Label = createGoalLabel(x, modelBase.goalZoneMaximum);
				var goalMinLabel:Label = createGoalLabel(x, modelBase.goalZoneMinimum);
			}
			var chart:Array = [chartBorder, goalMaxLine, goalMinLine, goalMaxLabel, goalMinLabel];
			resizeChart(chart);

			addElement(chartBorder);
			addElement(goalMaxLine);
			addElement(goalMinLine);
			if (showLabels)
			{
				addElement(goalMaxLabel);
				addElement(goalMinLabel);
			}

			return chart;
		}

		private function createGoalLabel(x:int, value:Number):Label
		{
			var goalLabel:Label = new Label();
			goalLabel.setStyle("fontSize", GOAL_LABEL_FONT_SIZE);
			goalLabel.setStyle("color", 0x231F20);
			goalLabel.text = value.toString();
			goalLabel.right = minWidth - (x + STEP_WIDTH);
			return goalLabel;
		}

		private function createGoalLine(x:int):DottedLine
		{
			var goalLine:DottedLine = createDottedLine();
			goalLine.x = x + 1;
			goalLine.width = STEP_WIDTH - 1;
			return goalLine;
		}

		protected function createDottedLine():DottedLine
		{
			var goalLine:DottedLine = new DottedLine();
			goalLine.dotColor = 0x808285;
			goalLine.dotWidth = 12;
			goalLine.spacerWidth = 12;
			goalLine.dotHeight = 1;
			goalLine.spacerHeight = 1;
			goalLine.height = 1;
			return goalLine;
		}

		protected function resizeChart(chart:Array):void
		{
			var chartBorder:Rect = chart[0];
			var goalMaxLine:DottedLine = chart[1];
			var goalMinLine:DottedLine = chart[2];
			var goalMaxLabel:Label = chart[3];
			var goalMinLabel:Label = chart[4];

			chartBorder.y = _chartY - 1;
			chartBorder.height = _chartHeight + 2;
			goalMaxLine.y = chartValueToPosition(modelBase.goalZoneMaximum);
			goalMinLine.y = chartValueToPosition(modelBase.goalZoneMinimum);
			if (goalMaxLabel)
				goalMaxLabel.y = goalMaxLine.y - goalMaxLabel.height + GOAL_LABEL_VERTICAL_OFFSET;
			if (goalMinLabel)
				goalMinLabel.y = goalMinLine.y - goalMinLabel.height + GOAL_LABEL_VERTICAL_OFFSET;
		}

		public function initializeIcon(icon:SpriteVisualElement):void
		{
			icon.width = icon.height = 20;
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xFFFFFF;
			glowFilter.alpha = 0.7;
			glowFilter.blurX = icon.width / 8;
			glowFilter.blurY = icon.width / 8;
			glowFilter.strength = icon.width / 8;

			icon.filters = [glowFilter];
		}

		protected function createConnectorLine():DottedLine
		{
			var line:DottedLine = createDottedLine();
			line.x = 0;
			line.alpha = 0.5;
			return line;
		}

		protected function updateAveragePlotItemRenderer():void
		{
			if (modelBase.isAverageAvailable)
			{
				if (modelBase.areProtocolMeasurementRequirementsMet)
				{
					_averagePlotItemRenderer.alpha = 1;
				}
				else
				{
					_averagePlotItemRenderer.alpha = 0.5;
				}

				_averagePlotItemRenderer.y = Math.round(chartValueToPosition(modelBase.protocolMeasurementAverageRangeLimited)
						- _averagePlotItemRenderer.height / 2 + (modelBase.isVerticalAxisMaximumExceeded ? -1 : 0) +
						(modelBase.isVerticalAxisMinimumExceeded ? +1 : 0));
				_maximumExceededIndicator.y = Math.round(_chartY + _chartHeight * 1 / 6 -
						_maximumExceededIndicator.height / 2);
				_minimumExceededIndicator.y = Math.round(_chartY + _chartHeight * 5 / 6 -
						_minimumExceededIndicator.height / 2);
				_averagePlotItemRenderer.visible = true;
				_averageLabel.y = Math.round(chartValueToPosition(modelBase.protocolMeasurementAverageRangeLimited)
						- _averageLabel.height / 2 + (modelBase.isVerticalAxisMaximumExceeded ? -1 : 0) +
						(modelBase.isVerticalAxisMinimumExceeded ? +1 : 0));
				_averageLabel.text = modelBase.protocolMeasurementAverageLabel;
				_averageLabel.visible = true;
				_maximumExceededIndicator.visible = modelBase.isVerticalAxisMaximumExceeded;
				_minimumExceededIndicator.visible = modelBase.isVerticalAxisMinimumExceeded;
			}
			else
			{
				_averagePlotItemRenderer.visible = false;
				_averageLabel.visible = false;
				_maximumExceededIndicator.visible = false;
				_minimumExceededIndicator.visible = false;
			}
		}

		protected function determineChartHeight():void
		{
			_chartHeight = Math.max(height, minHeight) - SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT - 1 - 3;
		}

		protected function updateInstructionsScroller():void
		{
			var chartsContainer:VGroup = this.owner.parent as VGroup;
			var chartsContainerPaddingTop:Number = (chartsContainer ? chartsContainer.paddingTop : 0);
			_instructionsScroller.height = parent.y - (chartsContainer ? chartsContainer.gap : 0) -
					chartsContainerPaddingTop;
			_instructionsScroller.y = -_instructionsScroller.height - chartsContainerPaddingTop;
			_instructionsScroller.x = chartsContainer ? chartsContainer.gap : 0;
			_instructionsScroller.width = this.width - _instructionsScroller.x;
		}

		protected function updateConnectors():void
		{
			if (!isNaN(modelBase.connectedChartVerticalAxisMinimum) &&
					!isNaN(modelBase.connectedChartVerticalAxisMaximum))
			{
				updateConnectorLine(_connectorMaxLine,
						modelBase.goalZoneMaximum);
				updateConnectorLine(_connectorMinLine,
						modelBase.goalZoneMinimum);
			}
		}

		private function updateConnectorLine(connectorLine:DottedLine, connectedChartValue:Number):void
		{
			connectorLine.y = Math.round(linearTransform(connectedChartValue,
					modelBase.connectedChartVerticalAxisMinimum,
					modelBase.connectedChartVerticalAxisMaximum,
					_chartY + _chartHeight, _chartY));
			var y2:Number = chartValueToPosition(connectedChartValue);
			var dy:Number = y2 - connectorLine.y;
			connectorLine.width = Math.sqrt(STEP_ARROW_BUTTON_WIDTH * STEP_ARROW_BUTTON_WIDTH + dy * dy);
			connectorLine.rotation = Math.atan(dy / STEP_ARROW_BUTTON_WIDTH) * 180 / Math.PI;
		}

		private static function linearTransform(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			return min2 + percentOfRange(value, min, max) * (max2 - min2);
		}

		private static function percentOfRange(value:Number, min:Number, max:Number):Number
		{
			return Math.max(0, Math.min(1, (value - min) / (max - min)));
		}

		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			var bloodGlucoseChange:Number = 0;
			if (event.keyCode == Keyboard.UP)
			{
				bloodGlucoseChange = 1;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				bloodGlucoseChange = -1;
			}
			modelBase.protocolMeasurementAverage += bloodGlucoseChange;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			updateInstructionsScroller();
			determineChartHeight();
			resizeChart(_step1Chart);
			updateAveragePlotItemRenderer();
			for (var step:int = 0; step < numSteps; step++)
			{
				updateArrowButtonY(_arrowCalloutButtons[step]);
			}
			updateArrowButtonY(_sendButton);
			updateConnectors();
		}

		protected function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "step1State" || event.property == "step1StateDescription")
			{
				updateForStateChange(0);
			}
			if (event.property == "step2State" || event.property == "step2StateDescription")
			{
				updateForStateChange(1);
			}
			if (event.property == "step3State" || event.property == "step3StateDescription")
			{
				updateForStateChange(2);
			}
			if (event.property == "step4State" || event.property == "step4StateDescription")
			{
				updateForStateChange(3);
			}
			if (event.property == "protocolMeasurementAverage")
			{
				invalidateDisplayList();
			}
			if (event.property == "instructionsSteps")
			{
				updateInstructionsText();
			}
		}

		private function updateForStateChange(step:int):void
		{
			if (step < numSteps)
			{
				updateArrow(_arrowCalloutButtons[step], modelBase.getStepState(step),
						modelBase.getStepStateDescription(step));
				updateBadge(_stepBadges[step], modelBase.getStepState(step));
			}
		}
	}
}
