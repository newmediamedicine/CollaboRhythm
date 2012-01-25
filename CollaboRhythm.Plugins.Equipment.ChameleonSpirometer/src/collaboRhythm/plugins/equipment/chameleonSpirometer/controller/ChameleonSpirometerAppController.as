package collaboRhythm.plugins.equipment.chameleonSpirometer.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class ChameleonSpirometerAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Chameleon Spirometer";

		public function ChameleonSpirometerAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}
