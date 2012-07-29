package collaboRhythm.plugins.insulinTitrationSupport.view
{
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
	}
}
