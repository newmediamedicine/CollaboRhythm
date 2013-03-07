package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationDecisionPanelController;
	import collaboRhythm.plugins.bloodPressure.model.ConfirmChangePopUpModel;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureDiastolicPlotItemRenderer;
	import collaboRhythm.plugins.bloodPressure.view.titration.ConfirmChangePopUp;
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationDecisionPanel;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.TitrationSupportChartModifierBase;
	import collaboRhythm.shared.model.medications.view.TitrationDecisionPanelBase;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;

	import com.theory9.data.types.OrderedMap;

	import flash.accessibility.AccessibilityProperties;

	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;

	import mx.core.ClassFactory;

	import mx.core.IVisualElement;
	import mx.graphics.SolidColorStroke;
	import mx.managers.PopUpManager;

	import spark.events.PopUpEvent;

	public class HypertensionMedicationTitrationSupportChartModifier extends TitrationSupportChartModifierBase implements IChartModifier
	{
		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var confirmChangePopUp:ConfirmChangePopUp = new ConfirmChangePopUp();
		private var _controller:HypertensionMedicationTitrationDecisionPanelController;
		private var _confirmChangePopUpModel:ConfirmChangePopUpModel;

		public function HypertensionMedicationTitrationSupportChartModifier(chartDescriptor:IChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, currentChartModifier);
			initializeHypertensionMedicationTitrationDecisionPanelModel();
			_controller = new HypertensionMedicationTitrationDecisionPanelController(chartModelDetails.collaborationLobbyNetConnectionServiceProxy,
					_model, chartModelDetails.viewNavigator);
			confirmChangePopUp.accessibilityProperties = new AccessibilityProperties();
		}

		override public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			chartDescriptors = decoratedModifier.updateChartDescriptors(chartDescriptors);
/*
			TODO: maybe we should group relevant medication charts together, just above the blood pressure chart

			var insulinDescriptorTemplate:MedicationChartDescriptor = new MedicationChartDescriptor();
			var matchingHypertensionMedicationChartDescriptors:Vector.<IChartDescriptor> = new Vector.<IChartDescriptor>();
			for each (var medicationCode:String in INSULIN_MEDICATION_CODES)
			{
				insulinDescriptorTemplate.medicationCode = medicationCode;
				if (chartDescriptors.getValueByKey(insulinDescriptorTemplate.descriptorKey) != null)
				{
					var matchingHypertensionMedicationChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey) as
							IChartDescriptor;
					if (matchingHypertensionMedicationChartDescriptor)
						matchingHypertensionMedicationChartDescriptors.push(matchingHypertensionMedicationChartDescriptor);
				}
			}
*/

			var bloodPressureDescriptorTemplate:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			bloodPressureDescriptorTemplate.vitalSignCategory = VitalSignsModel.SYSTOLIC_CATEGORY;
			var matchingBloodPressureChartDescriptor:IChartDescriptor;
			if (chartDescriptors.getValueByKey(bloodPressureDescriptorTemplate.descriptorKey) != null)
			{
				matchingBloodPressureChartDescriptor = chartDescriptors.removeByKey(bloodPressureDescriptorTemplate.descriptorKey) as
						IChartDescriptor;
			}

			var reorderedChartDescriptors:OrderedMap = new OrderedMap();
			for each (var otherChartDescriptor:IChartDescriptor in chartDescriptors.values())
			{
				reorderedChartDescriptors.addKeyValue(otherChartDescriptor.descriptorKey, otherChartDescriptor);
			}

/*
			if (matchingHypertensionMedicationChartDescriptors.length > 0)
			{
				for each (matchingHypertensionMedicationChartDescriptor in matchingHypertensionMedicationChartDescriptors)
				{
					reorderedChartDescriptors.addKeyValue(matchingHypertensionMedicationChartDescriptor.descriptorKey,
							matchingHypertensionMedicationChartDescriptor);
				}
			}
*/
			if (matchingBloodPressureChartDescriptor)
				reorderedChartDescriptors.addKeyValue(matchingBloodPressureChartDescriptor.descriptorKey,
						matchingBloodPressureChartDescriptor);

			return reorderedChartDescriptors;
		}

		override protected function createTitrationDecisionPanel():TitrationDecisionPanelBase
		{
			var panel:HypertensionMedicationTitrationDecisionPanel = new HypertensionMedicationTitrationDecisionPanel();
			panel.model = _model;
			panel.controller = _controller;
			return panel;
		}

		override protected function titrationDecisionPanelWidth():Number
		{
			return HypertensionMedicationTitrationDecisionPanel.TITRATION_DECISION_PANEL_WIDTH;
		}

		override protected function isProtocolMeasurementChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return HypertensionMedicationTitrationSupportChartModifierFactory.isSystolicChartDescriptor(chartDescriptor);
		}

		private function initializeHypertensionMedicationTitrationDecisionPanelModel():void
		{
			var activeAccount:Account = new Account();
			activeAccount.accountId = chartModelDetails.accountId;

			var activeRecordAccount:Account = new Account();
			activeRecordAccount.accountId = chartModelDetails.record.ownerAccountId;
			activeRecordAccount.primaryRecord = chartModelDetails.record;

			var settings:Settings = WorkstationKernel.instance.resolve(Settings) as Settings;
			// TODO: the decisionScheduleItemOccurrence needs to get updated in the PersistableHypertensionMedicationTitrationModel when the chart is prepared for a decision (generally it is null here)
			_model = new PersistableHypertensionMedicationTitrationModel(activeAccount, activeRecordAccount, settings, chartModelDetails.componentContainer,
					chartModelDetails && chartModelDetails.healthChartsModel ? chartModelDetails.healthChartsModel.decisionData as ScheduleItemOccurrence : null);
			_model.updateAreVitalSignRequirementsMet();
			_model.updateIsAdherencePerfect();
		}

		override public function set chartModelDetails(chartModelDetails:IChartModelDetails):void
		{
			decoratedModifier.chartModelDetails = chartModelDetails;
			super.chartModelDetails = chartModelDetails;
			if (_model)
			{
				// TODO: update the model as needed
//				_model.chartModelDetails = chartModelDetails;
				_model.updateForRecordChange();
			}
		}

		override public function save():Boolean
		{
			if (!super.save())
				return false;

			_model.evaluateForSave();

			if (_changeConfirmed)
			{
				// already showing popup, so assume this is the result of user clicking OK
				_changeConfirmed = false;
				return true;
			}
			else
			{
				_confirmChangePopUpModel = new ConfirmChangePopUpModel(_model.confirmationMessage, _model.headerMessage,
						_model.selectionsAgreeWithSystem, _model.selectionsMessage);
				confirmChangePopUp.model = _confirmChangePopUpModel;
				confirmChangePopUp.addEventListener(PopUpEvent.CLOSE, confirmChangePopUp_closeHandler);
				confirmChangePopUp.open(chartModelDetails.owner, true);
				PopUpManager.centerPopUp(confirmChangePopUp);

				return false;
			}
		}

		private function confirmChangePopUp_closeHandler(event:PopUpEvent):void
		{
			if (event.commit)
			{
				if (_model.save(_confirmChangePopUpModel.shouldFinalize))
				{
					_changeConfirmed = true;
					chartModelDetails.healthChartsModel.save();
				}
			}
		}

		override public function destroy():void
		{
			decoratedModifier.destroy();
			super.destroy();
			if (_controller)
			{
				_controller.destroy();
				_controller = null;
			}
		}

		override protected function get titrationDecisionModel():TitrationDecisionModelBase
		{
			return _model;
		}

		override protected function updateMainChartSeriesDataSets(chart:ScrubChart,
																  seriesDataSets:Vector.<SeriesDataSet>):void
		{
			super.updateMainChartSeriesDataSets(chart, seriesDataSets);

			var systolicSeriesDataSet:SeriesDataSet = seriesDataSets[0];
			systolicSeriesDataSet.series.setStyle("shape", TitrationSupportChartModifierBase.WEDGE_SHAPE);
			var color:uint = 0;
			systolicSeriesDataSet.series.setStyle("stroke", new SolidColorStroke(color, 2));

			var vitalSignSeries:PlotSeries;
			var seriesDataCollection:ArrayCollection;
			vitalSignSeries = new PlotSeries();
			vitalSignSeries.name = "diastolic";
			vitalSignSeries.id = chart.id + "_diastolicSeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			seriesDataCollection = chartModelDetails.record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.DIASTOLIC_CATEGORY);
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = "Blood Pressure Diastolic";
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(BloodPressureDiastolicPlotItemRenderer));
			vitalSignSeries.filterDataValues = "none";
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(0x808080, 2));
			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));

		}
	}
}
