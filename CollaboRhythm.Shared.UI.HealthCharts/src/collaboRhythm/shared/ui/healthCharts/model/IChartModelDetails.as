package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public interface IChartModelDetails
	{
		function get record():Record;
		function get accountId():String;
		function get currentDateSource():ICurrentDateSource;
		function get healthChartsModel():HealthChartsModel;
	}
}
