package collaboRhythm.plugins.intake.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class PainReportAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Pain Report";

		public function PainReportAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}
