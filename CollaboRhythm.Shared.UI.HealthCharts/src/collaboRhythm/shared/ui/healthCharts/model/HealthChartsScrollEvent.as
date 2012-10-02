package collaboRhythm.shared.ui.healthCharts.model
{
	import com.dougmccune.controls.SynchronizedScrollData;

	import flash.events.Event;

	public class HealthChartsScrollEvent extends Event
	{
		public static const SCROLL_CHARTS:String = "scrollCharts";

		private var _synchronizedScrollData:SynchronizedScrollData;

		public function HealthChartsScrollEvent(type:String, synchronizedScrollData:SynchronizedScrollData, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_synchronizedScrollData = synchronizedScrollData;
		}

		public function get synchronizedScrollData():SynchronizedScrollData
		{
			return _synchronizedScrollData;
		}
	}
}
