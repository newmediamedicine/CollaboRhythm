package collaboRhythm.shared.model.medications
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.medications.view.TitrationDecisionPanelBase;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.ChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;

	import flash.events.Event;

	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;
	import spark.primitives.Rect;

	public class TitrationSupportChartModifierBase extends ChartModifierBase
	{
		protected static const PROTOCOL_MEASUREMENT_CHART_MIN_HEIGHT:int = 200;

		private static const PLOT_ITEM_RADIUS:int = 11;

		private static const PLOT_ITEM_STROKE_WEIGHT:int = 6;

		private var _vitalSignsDataCollection:ArrayCollection;

		private var _seriesDataCollection:ArrayCollection;

		protected var _changeConfirmed:Boolean = false;

		public static const WEDGE_SHAPE:String = "wedge";

		public function TitrationSupportChartModifierBase(chartDescriptor:IChartDescriptor,
																	 chartModelDetails:IChartModelDetails,
																	 currentChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, currentChartModifier);
		}

		protected function get vitalSignChartDescriptor():VitalSignChartDescriptor
		{
			return chartDescriptor as VitalSignChartDescriptor;
		}

		public function modifyCartesianChart(chart:ScrubChart, cartesianChart:CartesianChart, isMainChart:Boolean):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyCartesianChart(chart, cartesianChart, isMainChart);

			cartesianChart.dataTipFunction = mainChart_dataTipFunction;
			if (isMainChart)
				titrationDecisionModel.chartVerticalAxis = cartesianChart.verticalAxis as LinearAxis;
		}

		private function mainChart_dataTipFunction(hitData:HitData):String
		{
			var proxy:VitalSignForDecisionProxy = hitData.item as VitalSignForDecisionProxy;
			var vitalSign:VitalSign;
			if (proxy)
			{
				vitalSign = proxy.vitalSign;
			}
			else
			{
				vitalSign = hitData.item as VitalSign;
			}

			if (vitalSign)
			{
				var result:String;
				if (vitalSign.result && vitalSign.result.textValue && isNaN(vitalSign.resultAsNumber))
					result = vitalSign.result.textValue;
				else
					result = vitalSign.resultAsNumber.toFixed(2);

				var eligiblePhrase:String = proxy ? (proxy.isEligible ? "Measurement is <b>eligible</b> for algorithm<br/>" : "Measurement is <b>not</b> eligible for algorithm<br/>") : "";
				return vitalSign.name.text + " " + result + "<br/>" +
						eligiblePhrase +
						"Date: " + vitalSign.dateMeasuredStart.toLocaleString();
			}

			return hitData.item.toString();
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return decoratedModifier.createImage(currentChartImage);
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var vitalSignSeries:PlotSeries = new PlotSeries();
			vitalSignSeries.name = "vitalSignPrimary";
			vitalSignSeries.id = chart.id + "_primarySeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			var seriesDataCollection:ArrayCollection = getSeriesDataCollection();
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = vitalSignChartDescriptor.vitalSignCategory;
			vitalSignSeries.setStyle("radius", PLOT_ITEM_RADIUS);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignChartDescriptor.vitalSignCategory);
			var color:uint = 0;
			vitalSignSeries.setStyle("itemRenderer",
					new ClassFactory(VitalSignForDecisionItemRenderer));
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(color, PLOT_ITEM_STROKE_WEIGHT));
			vitalSignSeries.setStyle("fill", new SolidColor(color));

			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));

			updateMainChartSeriesDataSets(chart, seriesDataSets);
			return seriesDataSets;
		}

		protected function updateMainChartSeriesDataSets(chart:ScrubChart, seriesDataSets:Vector.<SeriesDataSet>):void
		{
		}

		public override function getSeriesDataCollection():ArrayCollection
		{
			if (_vitalSignsDataCollection)
			{
				_vitalSignsDataCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
						vitalSignsDataCollection_collectionChangeHandler);
			}

			_vitalSignsDataCollection = chartModelDetails.record.vitalSignsModel.getVitalSignsByCategory(vitalSignChartDescriptor.vitalSignCategory);
			if (_vitalSignsDataCollection)
			{
				_vitalSignsDataCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						vitalSignsDataCollection_collectionChangeHandler, false, 0, true);
			}

			_seriesDataCollection = createProxiesForDecision(_vitalSignsDataCollection);
			return _seriesDataCollection;
		}

		private function createProxiesForDecision(vitalSignsDataCollection:ArrayCollection):ArrayCollection
		{
			var seriesDataCollection:ArrayCollection = new ArrayCollection();
			for each (var vitalSign:VitalSign in vitalSignsDataCollection)
			{
				seriesDataCollection.addItem(new VitalSignForDecisionProxy(vitalSign, titrationDecisionModel));
			}
			return seriesDataCollection;
		}

		protected function get titrationDecisionModel():TitrationDecisionModelBase
		{
			return null;
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
			return decoratedModifier.drawBackgroundElements(canvas, zoneLabel);
		}

		private function vitalSignsDataCollection_collectionChangeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD)
			{
				for each (var vitalSign:VitalSign in event.items)
				{
					_seriesDataCollection.addItem(new VitalSignForDecisionProxy(vitalSign, titrationDecisionModel));
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				_seriesDataCollection.removeAll();
				var collection:ArrayCollection = createProxiesForDecision(_vitalSignsDataCollection);
				_seriesDataCollection.addAll(collection);
			}
		}

		protected function createTitrationDecisionPanel():TitrationDecisionPanelBase
		{
			return null;
		}

		protected function titrationDecisionPanelWidth():Number
		{
			return NaN;
		}

		protected function isProtocolMeasurementChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return false;
		}

		private var _titrationDecisionPanel:TitrationDecisionPanelBase;
		private var _spacerRects:Vector.<Rect> = new <Rect>[];

		public override function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void
		{
			if (chartModelDetails.record.healthChartsModel.decisionPending)
			{
				// TODO: re-evaluate only when data or conditions change that could affect the panel instead of any time the view is shown
				if (isProtocolMeasurementChartDescriptor(chartDescriptor))
				{
					titrationDecisionModel.evaluateForInitialize();
				}

				if (adherenceGroup.numElements == 2)
				{
					var extraPanel:IVisualElement;

					if (isProtocolMeasurementChartDescriptor(chartDescriptor))
					{
						_titrationDecisionPanel = createTitrationDecisionPanel();
						_titrationDecisionPanel.percentHeight = 100;
						_titrationDecisionPanel.addEventListener(Event.RESIZE, titrationDecisionPanel_resizeHandler);
						extraPanel = _titrationDecisionPanel;

						adherenceGroup.minHeight = PROTOCOL_MEASUREMENT_CHART_MIN_HEIGHT;
					}
					else
					{
						var spacerRect:Rect = new Rect();
						spacerRect.width = _titrationDecisionPanel ? _titrationDecisionPanel.width : titrationDecisionPanelWidth();
						spacerRect.visible = false;
						_spacerRects.push(spacerRect);
						extraPanel = spacerRect;
					}
					adherenceGroup.addElement(extraPanel);
				}
			}
			else
			{
				if (_titrationDecisionPanel)
				{
					_titrationDecisionPanel.destroy();
					_titrationDecisionPanel = null;
				}

				while (adherenceGroup.numElements > 2)
					adherenceGroup.removeElementAt(adherenceGroup.numElements - 1);
			}
		}

		private function titrationDecisionPanel_resizeHandler(event:Event):void
		{
			if (_titrationDecisionPanel)
			{
				for each (var rect:Rect in _spacerRects)
				{
					rect.width = _titrationDecisionPanel.width;
				}
			}
		}
	}
}
