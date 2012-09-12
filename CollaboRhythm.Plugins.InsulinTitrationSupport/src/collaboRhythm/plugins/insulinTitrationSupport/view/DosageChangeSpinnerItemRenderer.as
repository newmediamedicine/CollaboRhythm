package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.DosageChangeValueProxy;

	import spark.components.SpinnerListItemRenderer;

	public class DosageChangeSpinnerItemRenderer extends SpinnerListItemRenderer
	{
		public function DosageChangeSpinnerItemRenderer()
		{
		}

		[Bindable(style="true")]
		override public function getStyle(styleProp:String):*
		{
			if (styleProp == "fontSize" && label == InsulinTitrationDecisionPanel.NO_CHANGE_LABEL)
				return super.getStyle(styleProp) - 3;
			return super.getStyle(styleProp);
		}

		override public function set label(value:String):void
		{
			super.label = value;
			if (labelDisplay)
				labelDisplay.setStyle("fontSize", getStyle("fontSize"));

			if (label == InsulinTitrationDecisionPanel.NO_CHANGE_LABEL)
			{
				setStyle("paddingLeft", 2);
				setStyle("paddingRight", 2);
				setStyle("textAlign", "center");
			}
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (valueProxy.isCurrentPersistedDosageChange)
			{
				// draw a highlighted background
				graphics.beginFill(0x33B5E5);
				graphics.lineStyle();
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			else
			{
				super.drawBackground(unscaledWidth, unscaledHeight);
			}
		}

		private function get valueProxy():DosageChangeValueProxy
		{
			return data as DosageChangeValueProxy;
		}
	}
}
