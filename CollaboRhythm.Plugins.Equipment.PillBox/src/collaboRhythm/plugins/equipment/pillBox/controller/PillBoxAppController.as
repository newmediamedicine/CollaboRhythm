package collaboRhythm.plugins.equipment.pillBox.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class PillBoxAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Pill Box";

		public function PillBoxAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

	}
}
