package collaboRhythm.tablet.view.skins
{

	import mx.core.DPIClassification;

	import spark.skins.mobile.ActionBarSkin;

	public class TabletActionBarSkin extends ActionBarSkin
	{
		public function TabletActionBarSkin()
		{
			borderClass = TabletActionBarBorder;
			layoutShadowHeight = 0;

			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					layoutContentGroupHeight = 86;
					layoutTitleGroupHorizontalPadding = 26;

					break;
				}
				case DPIClassification.DPI_240:
				{
					layoutContentGroupHeight = 65;
					layoutTitleGroupHorizontalPadding = 20;

					break;
				}
				default:
				{
					// default DPI_160
					layoutContentGroupHeight = 30;
					layoutTitleGroupHorizontalPadding = 13;

					break;
				}
			}
		}
	}
}
