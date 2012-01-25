package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;

	import mx.charts.HitData;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import spark.primitives.Rect;

	/**
	 * Default modifier for vitalSign charts. Draws a goal region and renders the vitalSign concentration as an area series.
	 */
	public class DefaultVitalSignChartModifier extends ChartModifierBase implements IChartModifier
	{
		public function DefaultVitalSignChartModifier(chartDescriptor:VitalSignChartDescriptor,
														   chartModelDetails:IChartModelDetails,
														   decoratedChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, decoratedChartModifier);
		}

		protected function get vitalSignChartDescriptor():VitalSignChartDescriptor
		{
			return chartDescriptor as VitalSignChartDescriptor;
		}

		public function modifyMainChart(chart:ScrubChart):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyMainChart(chart);
			chart.mainChart.dataTipFunction = mainChart_dataTipFunction;
		}

		private function mainChart_dataTipFunction(hitData:HitData):String
		{
			var vitalSign:VitalSign = hitData.item as VitalSign;
			if (vitalSign)
			{
				return vitalSign.name.text + " " + vitalSign.resultAsNumber.toFixed(2) + "<br/>" +
						"Date: " + vitalSign.dateMeasuredStart.toLocaleString();
			}

			return hitData.item.toString();
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var vitalSignSeries:PlotSeries = new PlotSeries();
			vitalSignSeries.name = "vitalSignPrimary";
			vitalSignSeries.id = chart.id + "_primarySeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			var seriesDataCollection:ArrayCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignChartDescriptor.vitalSignCategory);
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = vitalSignChartDescriptor.vitalSignCategory;
			vitalSignSeries.setStyle("radius", 5);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignKey);
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(0x000000, 2));

			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));
			return seriesDataSets;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return createVitalSignImage(vitalSignChartDescriptor.vitalSignCategory);
		}

		private function createVitalSignImage(vitalSignKey:String):Rect
		{
			var vitalSignView:Rect = new Rect();
			vitalSignView.fill = new SolidColor(getVitalSignColor(vitalSignKey));
			vitalSignView.width = 100;
			vitalSignView.height = 100;
			vitalSignView.verticalCenter = 0;
			return vitalSignView;
		}

		private function getVitalSignColor(vitalSignKey:String):uint
		{
			// TODO: implement a better system for coloring the vital sign charts
			return 0x4444FF;
		}

	}
}
