package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;

	public class InsulinTitrationSupportHealthAction extends HealthActionBase
	{
		public static const HEALTH_ACTION_TYPE:String = "Insulin Titration";

		public function InsulinTitrationSupportHealthAction()
		{
			super(HEALTH_ACTION_TYPE);
		}
	}
}
