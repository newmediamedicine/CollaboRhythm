package collaboRhythm.plugins.medications.insulin.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class InsulinAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Insulin";

		public function InsulinAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}
