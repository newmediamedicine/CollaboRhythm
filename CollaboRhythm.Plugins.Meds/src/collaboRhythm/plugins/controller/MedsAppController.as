package collaboRhythm.plugins.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class MedsAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Meds";

		public function MedsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		public override function get defaultName():String
			{
				return DEFAULT_NAME;
			}
	}
}