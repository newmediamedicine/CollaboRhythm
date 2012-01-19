package collaboRhythm.plugins.intake.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class IntakeAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Intake";

		public function IntakeAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}
