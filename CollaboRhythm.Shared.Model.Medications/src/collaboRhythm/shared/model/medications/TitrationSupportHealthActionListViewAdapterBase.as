package collaboRhythm.shared.model.medications
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;

	import mx.core.IVisualElement;
	import mx.events.PropertyChangeEvent;

	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	public class TitrationSupportHealthActionListViewAdapterBase
	{
		protected var _controller:HealthActionListViewControllerBase;

		protected var _decisionModel:TitrationDecisionModelBase;

		public function TitrationSupportHealthActionListViewAdapterBase()
		{
		}

		public function createCustomView():IVisualElement
		{
			var group:Group = new Group();
			group.percentWidth = 100;
			group.percentHeight = 100;
			var insufficientMeasurementIcon:SpriteVisualElement = createInsufficientMeasurementIcon();
			initializeIcon(insufficientMeasurementIcon, group);
			var insufficientAdherenceIcon:SpriteVisualElement = createInsufficientAdherenceIcon();
			initializeIcon(insufficientAdherenceIcon, group);
			var conditionsMetIcon:SpriteVisualElement = createConditionsMetIcon();
			initializeIcon(conditionsMetIcon, group);

			updateIconsForPrerequisites(insufficientMeasurementIcon, insufficientAdherenceIcon, conditionsMetIcon);
			_decisionModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
					function (event:PropertyChangeEvent):void
					{
						if (event.property == "algorithmPrerequisitesSatisfied" || event.property == "step2State")
						{
							updateIconsForPrerequisites(insufficientMeasurementIcon, insufficientAdherenceIcon,
									conditionsMetIcon);
						}
					}, false, 0, true);

			return group;
		}

		protected function updateIconsForPrerequisites(insufficientMeasurementIcon:SpriteVisualElement,
													   insufficientAdherenceIcon:SpriteVisualElement,
													   conditionsMetIcon:SpriteVisualElement):void
		{
			insufficientMeasurementIcon.visible = false;
			insufficientAdherenceIcon.visible = false;
			conditionsMetIcon.visible = false;
			if (_decisionModel)
			{
				if (_decisionModel.algorithmPrerequisitesSatisfied)
				{
					conditionsMetIcon.visible = true;
				}
				else if (_decisionModel.step2State == TitrationDecisionModelBase.STEP_STOP)
				{
					insufficientAdherenceIcon.visible = true;
				}
				else
				{
					insufficientMeasurementIcon.visible = true;
				}
			}
		}

		protected function initializeIcon(icon:SpriteVisualElement, group:Group):void
		{
			icon.percentWidth = icon.percentHeight = 100;
			group.addElement(icon);
		}

		protected function createConditionsMetIcon():SpriteVisualElement
		{
			return null;
		}

		protected function createInsufficientAdherenceIcon():SpriteVisualElement
		{
			return null;
		}

		protected function createInsufficientMeasurementIcon():SpriteVisualElement
		{
			return null;
		}
	}
}
