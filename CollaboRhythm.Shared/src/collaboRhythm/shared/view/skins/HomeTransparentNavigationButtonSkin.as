package collaboRhythm.shared.view.skins
{
	import collaboRhythm.shared.view.skins.skins160.TransparentNavigationButton_up;
	import collaboRhythm.shared.view.skins.skins320.TransparentNavigationButton_down;
	import collaboRhythm.shared.view.skins.skins320.TransparentNavigationButton_up;

	import mx.core.DPIClassification;

	import spark.skins.mobile.TransparentNavigationButtonSkin;

	public class HomeTransparentNavigationButtonSkin extends TransparentNavigationButtonSkin
	{
		public function HomeTransparentNavigationButtonSkin()
		{
			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					upBorderSkin = collaboRhythm.shared.view.skins.skins320.TransparentNavigationButton_up;
					downBorderSkin = TransparentNavigationButton_down;

					break;
				}
				default:
				{
					upBorderSkin = collaboRhythm.shared.view.skins.skins160.TransparentNavigationButton_up;
					downBorderSkin = collaboRhythm.shared.view.skins.skins160.TransparentNavigationButton_down;

					break;
				}
			}
		}
	}
}
