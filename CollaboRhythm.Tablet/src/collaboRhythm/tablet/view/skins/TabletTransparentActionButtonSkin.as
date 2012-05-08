package collaboRhythm.tablet.view.skins
{
	import collaboRhythm.tablet.view.skins.skins160.TransparentActionButton_down;
	import collaboRhythm.tablet.view.skins.skins160.TransparentActionButton_up;
	import collaboRhythm.tablet.view.skins.skins320.TransparentActionButton_down;
	import collaboRhythm.tablet.view.skins.skins320.TransparentActionButton_up;

	import mx.core.DPIClassification;

	import spark.skins.mobile.TransparentNavigationButtonSkin;

	public class TabletTransparentActionButtonSkin extends TransparentNavigationButtonSkin
	{
		public function TabletTransparentActionButtonSkin()
		{
			switch (applicationDPI)
						{
							case DPIClassification.DPI_320:
							{
								upBorderSkin = collaboRhythm.tablet.view.skins.skins320.TransparentActionButton_up;
								downBorderSkin = collaboRhythm.tablet.view.skins.skins320.TransparentActionButton_down;

								break;
							}
							default:
							{
								upBorderSkin = collaboRhythm.tablet.view.skins.skins160.TransparentActionButton_up;
								downBorderSkin = collaboRhythm.tablet.view.skins.skins160.TransparentActionButton_down;

								break;
							}
						}
		}
	}
}
