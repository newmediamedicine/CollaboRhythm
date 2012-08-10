package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;

	import com.dougmccune.controls.LimitedLinearAxis;
	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.HitData;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.renderers.CircleItemRenderer;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import qs.charts.dataShapes.DataDrawingCanvas;
	import qs.charts.dataShapes.Edge;

	import spark.components.Image;
	import spark.components.Label;
	import spark.primitives.Rect;
	import spark.skins.spark.ImageSkin;

	/**
	 * Default modifier for vitalSign charts. Draws a goal region and renders the vitalSign concentration as an area series.
	 */
	public class DefaultVitalSignChartModifier extends ChartModifierBase implements IChartModifier
	{
		[Embed("/assets/images/vitalSigns/Heart_Rate.png")]
		private var _heartRateImageClass:Class;

		[Embed("/assets/images/vitalSigns/Metabolic_Equivalent_Task.png")]
		private var _metabolicEquivalentTaskImageClass:Class;

		[Embed("/assets/images/vitalSigns/Oxygen_Saturation.png")]
		private var _oxygenSaturationImageClass:Class;

		[Embed("/assets/images/vitalSigns/asthma_symptom.png")]
		private var _asthmaSymptomImageClass:Class;

		[Embed("/assets/images/vitalSigns/asthma_trigger.png")]
		private var _asthmaTriggerImageClass:Class;

		[Embed("/assets/images/vitalSigns/Blood_Glucose.png")]
		private var _bloodGlucoseImageClass:Class;

		[Embed("/assets/images/vitalSigns/Caloric_Intake.png")]
		private var _caloricIntakeImageClass:Class;

		[Embed("/assets/images/vitalSigns/Peak_Expiratory_Flow_Rate.png")]
		private var _peakExpiratoryFlowRateImageClass:Class;

		[Embed("/assets/images/vitalSigns/Step_Count.png")]
		private var _stepCountImageClass:Class;

		public static const BLOOD_GLUCOSE_VERTICAL_AXIS_MINIMUM:Number = 50;
		public static const BLOOD_GLUCOSE_VERTICAL_AXIS_MAXIMUM:Number = 140;
		public static const GOAL_ZONE_COLOR:uint = 0x5D85BF;
		public static const GOAL_ZONE_ALPHA:Number = 0.5;
		public static const BLOOD_GLUCOSE_GOAL_ZONE_MINIMUM:Number = 80;
		public static const BLOOD_GLUCOSE_GOAL_ZONE_MAXIMUM:Number = 110;
		private static const PLOT_ITEM_RADIUS:int = 10;

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

		public function modifyCartesianChart(chart:ScrubChart,
											 cartesianChart:CartesianChart,
											 isMainChart:Boolean):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyCartesianChart(chart, cartesianChart, isMainChart);
			cartesianChart.dataTipFunction = mainChart_dataTipFunction;

			if (vitalSignChartDescriptor.vitalSignCategory == VitalSignsModel.BLOOD_GLUCOSE_CATEGORY)
			{
				modifyMainChartBloodGlucose(chart, cartesianChart);
			}
		}

		private function modifyMainChartBloodGlucose(chart:ScrubChart, cartesianChart:CartesianChart):void
		{
			var verticalAxis:LimitedLinearAxis = cartesianChart.verticalAxis as LimitedLinearAxis;
			if (verticalAxis)
			{
				verticalAxis.minimumLimit = BLOOD_GLUCOSE_VERTICAL_AXIS_MINIMUM;
				verticalAxis.maximumLimit = BLOOD_GLUCOSE_VERTICAL_AXIS_MAXIMUM;
				verticalAxis.interval = 10;
			}
		}

		private function mainChart_dataTipFunction(hitData:HitData):String
		{
			var vitalSign:VitalSign = hitData.item as VitalSign;
			if (vitalSign)
			{
				var result:String;
				if (vitalSign.result && vitalSign.result.textValue && isNaN(vitalSign.resultAsNumber))
					result = vitalSign.result.textValue;
				else
					result = vitalSign.resultAsNumber.toFixed(2);

				return vitalSign.name.text + " " + result + "<br/>" +
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
			var seriesDataCollection:ArrayCollection = chartModelDetails.record.vitalSignsModel.getVitalSignsByCategory(vitalSignChartDescriptor.vitalSignCategory);
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = vitalSignChartDescriptor.vitalSignCategory;
			vitalSignSeries.setStyle("radius", PLOT_ITEM_RADIUS);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignChartDescriptor.vitalSignCategory);
			var color:uint = 0;
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(CircleItemRenderer));
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(color, 2));
			vitalSignSeries.setStyle("fill", new SolidColor(color));

			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));
			return seriesDataSets;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return createVitalSignImage(vitalSignChartDescriptor.vitalSignCategory);
		}

		private function createVitalSignImage(vitalSignKey:String):IVisualElement
		{
			var imageClass:Class;
			switch (vitalSignKey)
			{
				case VitalSignsModel.HEART_RATE_CATEGORY:
					imageClass = _heartRateImageClass;
					break;
				case VitalSignsModel.METABOLIC_EQUIVALENT_TASK_CATEGORY:
					imageClass = _metabolicEquivalentTaskImageClass;
					break;
				case VitalSignsModel.OXYGEN_SATURATION_CATEGORY:
					imageClass = _oxygenSaturationImageClass;
					break;
				case VitalSignsModel.ASTHMA_SYMPTOM_CATEGORY:
					imageClass = _asthmaSymptomImageClass;
					break;
				case VitalSignsModel.ASTHMA_TRIGGER_CATEGORY:
					imageClass = _asthmaTriggerImageClass;
					break;
				case VitalSignsModel.BLOOD_GLUCOSE_CATEGORY:
					imageClass = _bloodGlucoseImageClass;
					break;
				case VitalSignsModel.CALORIC_INTAKE_CATEGORY:
					imageClass = _caloricIntakeImageClass;
					break;
				case VitalSignsModel.PEAK_EXPIRATORY_FLOW_RATE_CATEGORY:
					imageClass = _peakExpiratoryFlowRateImageClass;
					break;
				case VitalSignsModel.STEP_COUNT_CATEGORY:
					imageClass = _stepCountImageClass;
					break;
			}
			
			if (imageClass)
			{
				var image:Image = new Image();
				image.setStyle("skinClass", ImageSkin);
				image.source = imageClass;
				image.smooth = true;
				image.width = 100;
				image.height = 100;

				return image;
			}
			else
			{
				var vitalSignView:Rect = new Rect();
				vitalSignView.fill = new SolidColor(getVitalSignColor(vitalSignKey));
				vitalSignView.width = 100;
				vitalSignView.height = 100;
				vitalSignView.verticalCenter = 0;
				return vitalSignView;
			}
		}

		private function getVitalSignColor(vitalSignKey:String):uint
		{
			switch (vitalSignKey)
			{
				case VitalSignsModel.HEART_RATE_CATEGORY:
					return 0x00A200;
				case VitalSignsModel.OXYGEN_SATURATION_CATEGORY:
					return 0x0042A6;
				case VitalSignsModel.METABOLIC_EQUIVALENT_TASK_CATEGORY:
					return 0xAC00AD;
			}
			return ColorFromNameUtil.getColorFromName(vitalSignKey);
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
			if (vitalSignChartDescriptor.vitalSignCategory == VitalSignsModel.BLOOD_GLUCOSE_CATEGORY)
			{
				canvas.clear();

				var color:uint = GOAL_ZONE_COLOR;
				canvas.beginFill(color, GOAL_ZONE_ALPHA);
				canvas.drawRect([Edge.LEFT, -1], BLOOD_GLUCOSE_GOAL_ZONE_MINIMUM, [Edge.RIGHT, 1], BLOOD_GLUCOSE_GOAL_ZONE_MAXIMUM);
				canvas.endFill();

				if (zoneLabel)
				{
					zoneLabel.setStyle("color", color);
					canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:200});
				}
			}
		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			return chartDescriptors;
		}
	}
}
