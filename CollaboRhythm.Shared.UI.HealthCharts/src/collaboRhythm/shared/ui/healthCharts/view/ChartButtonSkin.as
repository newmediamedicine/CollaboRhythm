package collaboRhythm.shared.ui.healthCharts.view
{
	import spark.skins.mobile.TransparentNavigationButtonSkin;

	import mx.core.mx_internal;

	use namespace mx_internal;

	public class ChartButtonSkin extends TransparentNavigationButtonSkin
	{
		public function ChartButtonSkin()
		{
			super();

			var uniformPadding:int = layoutPaddingLeft;
			layoutPaddingRight = layoutPaddingLeft = uniformPadding;
			layoutPaddingTop = layoutPaddingBottom = 0;
		}

		override mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// trailing vertical separator is outside the right bounds of the button
			setElementSize(border, unscaledWidth + layoutBorderSize + 1, unscaledHeight);
			setElementPosition(border, 0, 0);
		}
	}
}
