package collaboRhythm.plugins.asthmaManagement.controller
{
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	public class AsthmaManagementAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Asthma Management";

		public function AsthmaManagementAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}
