package collaboRhythm.plugins.equipment.insulinPen.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class InsulinPenAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Insulin Pen";

		public function InsulinPenAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

	}
}
