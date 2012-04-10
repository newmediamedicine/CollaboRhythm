package collaboRhythm.tablet.view.skins
{
	import collaboRhythm.tablet.view.skins.skins160.TransparentNavigationButton_down;
	import collaboRhythm.tablet.view.skins.skins160.TransparentNavigationButton_up;
	import collaboRhythm.tablet.view.skins.skins320.TransparentNavigationButton_down;
	import collaboRhythm.tablet.view.skins.skins320.TransparentNavigationButton_up;

	import mx.core.DPIClassification;

	import spark.skins.mobile.TransparentNavigationButtonSkin;

	public class TabletTransparentNavigationButtonSkin extends TransparentNavigationButtonSkin
	{
		public function TabletTransparentNavigationButtonSkin()
		{
			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					upBorderSkin = collaboRhythm.tablet.view.skins.skins320.TransparentNavigationButton_up;
					downBorderSkin = collaboRhythm.tablet.view.skins.skins320.TransparentNavigationButton_down;

					break;
				}
				default:
				{
					upBorderSkin = collaboRhythm.tablet.view.skins.skins160.TransparentNavigationButton_up;
					downBorderSkin = collaboRhythm.tablet.view.skins.skins160.TransparentNavigationButton_down;

					break;
				}
			}
		}
	}
}
