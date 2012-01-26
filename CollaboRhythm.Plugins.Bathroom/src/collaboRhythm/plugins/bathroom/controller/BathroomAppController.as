package collaboRhythm.plugins.bathroom.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class BathroomAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Bathroom";

		public function BathroomAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		public override function get defaultName():String
			{
				return DEFAULT_NAME;
			}
	}
}