package collaboRhythm.workstation.apps.bloodPressure.view
{
	import mx.charts.series.LineSeries;
	import mx.charts.renderers.LineRenderer;
	import mx.core.ClassFactory;

	[Style(name="dashingPattern", type="Array")]
	public class DashedLineSeries extends LineSeries
	{
		public function DashedLineSeries() {
			setStyle("lineSegmentRenderer", new ClassFactory(DashedLineRenderer));
		}
	}
}