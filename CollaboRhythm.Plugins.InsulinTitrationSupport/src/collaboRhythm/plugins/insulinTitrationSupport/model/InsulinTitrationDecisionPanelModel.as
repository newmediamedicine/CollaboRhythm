package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;

	[Bindable]
	public class InsulinTitrationDecisionPanelModel extends InsulinTitrationDecisionModelBase
	{
		private var _chartModelDetails:IChartModelDetails;

		public function InsulinTitrationDecisionPanelModel(chartModelDetails:IChartModelDetails)
		{
			this.chartModelDetails = chartModelDetails;
			super();
		}

		public function get chartModelDetails():IChartModelDetails
		{
			return _chartModelDetails;
		}

		public function set chartModelDetails(value:IChartModelDetails):void
		{
			_chartModelDetails = value;
			updateForRecordChange();
		}

		override public function get record():Record
		{
			return chartModelDetails ? chartModelDetails.record : null;
		}

		override protected function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return chartModelDetails && chartModelDetails.healthChartsModel ? chartModelDetails.healthChartsModel.decisionData as ScheduleItemOccurrence : null;
		}

		override protected function get componentContainer():IComponentContainer
		{
			return chartModelDetails ? chartModelDetails.componentContainer : null;
		}

		override protected function get accountId():String
		{
			return chartModelDetails ? chartModelDetails.accountId : null;
		}

		override protected function get currentDateSource():ICurrentDateSource
		{
			return chartModelDetails ? chartModelDetails.currentDateSource : null;
		}
	}
}
