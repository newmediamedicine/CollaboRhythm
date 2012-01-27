package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import mx.utils.HSBColor;

	public class ColorFromNameUtil
	{
		public function ColorFromNameUtil()
		{
		}

		public static function getColorFromName(vitalSignKey:String):uint
		{
			var hue:Number = 180;
			for (var i:int = 0; i < vitalSignKey.length; i++)
			{
				hue = hue + vitalSignKey.charCodeAt(i);
			}

			hue = hue % 360;
			return HSBColor.convertHSBtoRGB(hue, 0.5, 0.5);
		}
	}
}
