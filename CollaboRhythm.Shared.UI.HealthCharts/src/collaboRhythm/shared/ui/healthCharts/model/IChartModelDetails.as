package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.model.Record;

	public interface IChartModelDetails
	{
		function get record():Record;
		function get accountId():String;
	}
}
