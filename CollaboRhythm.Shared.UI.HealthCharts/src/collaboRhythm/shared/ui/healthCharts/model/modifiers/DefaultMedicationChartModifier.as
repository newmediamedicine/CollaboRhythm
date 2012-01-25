package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.apps.healthCharts.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.view.MedicationScheduleItemChartView;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;

	import mx.charts.series.AreaSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;

	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import skins.LineSeriesCustomRenderer;

	import spark.layouts.VerticalAlign;

	/**
	 * Default modifier for medication charts. Draws a goal region and renders the medication concentration as an area series.
	 */
	public class DefaultMedicationChartModifier extends ChartModifierBase implements IChartModifier
	{
		private var _medicationColorSource:IMedicationColorSource;

		public function DefaultMedicationChartModifier(chartDescriptor:MedicationChartDescriptor,
														   chartModelDetails:IChartModelDetails,
														   decoratedChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, decoratedChartModifier);
			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;
		}

		protected function get medicationChartDescriptor():MedicationChartDescriptor
		{
			return chartDescriptor as MedicationChartDescriptor;
		}

		public function modifyMainChart(chart:ScrubChart):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyMainChart(chart);
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var concentrationSeries:AreaSeries = new AreaSeries();
			concentrationSeries.name = "concentration";
			concentrationSeries.id = chart.id + "_concentrationSeries";
			concentrationSeries.xField = "date";
			concentrationSeries.yField = "concentration";
			var seriesDataCollection:ArrayCollection = chartModelDetails.record.medicationAdministrationsModel.medicationConcentrationCurvesByCode.getItem(medicationChartDescriptor.medicationCode);
			concentrationSeries.dataProvider = seriesDataCollection;
			concentrationSeries.setStyle("radius", 2.5);
			concentrationSeries.setStyle("form", "curve");
			concentrationSeries.setStyle("itemRenderer", new ClassFactory(LineSeriesCustomRenderer));
			concentrationSeries.filterDataValues = "none";
			var color:uint = getMedicationColor();
			concentrationSeries.setStyle("areaStroke", new SolidColorStroke(0x000000, 1));
			concentrationSeries.setStyle("areaFill", new SolidColor(color, 1));

			seriesDataSets.push(new SeriesDataSet(concentrationSeries, seriesDataCollection, "date"));
			return seriesDataSets;
		}

		private function getMedicationColor():uint
		{
			var color:uint;
			if (_medicationColorSource)
				color = _medicationColorSource.getMedicationColor(medicationChartDescriptor.ndcCode);

			if (color == 0)
				color = 0x4252A4;

			return color;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			var medicationCode:String = medicationChartDescriptor.medicationCode;
			var medicationModel:MedicationComponentAdherenceModel = chartModelDetails.record.healthChartsModel.focusSimulation.getMedication(medicationCode);
			if (medicationModel == null)
				throw new Error("Medication " + medicationCode +
						" is in model.medicationConcentrationCurvesByCode but not in model.simulation.medicationsByCode");

			var medicationScheduleItem:MedicationScheduleItem = medicationModel.medicationScheduleItem;

			var medicationView:MedicationScheduleItemChartView = new MedicationScheduleItemChartView();
			medicationView.medicationScheduleItem = medicationScheduleItem;
			medicationView.verticalAlign = VerticalAlign.MIDDLE;
			return medicationView;
		}
	}
}
