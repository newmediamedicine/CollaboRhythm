package collaboRhythm.shared.apps.healthCharts.model
{
	import flash.events.Event;

	public class HealthChartsEvent extends Event
	{
		public static const SAVE:String = "save";
		public static const CHART_DATA_TIPS_UPDATE:String = "chartDataTipsUpdate";

		public function HealthChartsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
