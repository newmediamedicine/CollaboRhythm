package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.InsulinTitrationDecisionPanelController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.ConfirmChangePopUp;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationDecisionPanel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.TitrationSupportChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.theory9.data.types.OrderedMap;

	import flash.accessibility.AccessibilityProperties;

	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.managers.PopUpManager;

	import spark.events.PopUpEvent;

	public class InsulinTitrationSupportChartModifier extends TitrationSupportChartModifierBase implements IChartModifier
	{
		public static const INSULIN_LEVEMIR_CODE:String = "847241";
		public static const INSULIN_LANTUS_CODE:String = "847232";
		public static const INSULIN_MEDICATION_CODES:Vector.<String> = new <String>[INSULIN_LEVEMIR_CODE, INSULIN_LANTUS_CODE];

		private var _insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel;
		private var confirmChangePopUp:ConfirmChangePopUp = new ConfirmChangePopUp();
		private var _panelController:InsulinTitrationDecisionPanelController;

		public function InsulinTitrationSupportChartModifier(chartDescriptor:IChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, currentChartModifier);
			initializeInsulinTitrationDecisionPanelModel();
			_panelController = new InsulinTitrationDecisionPanelController(chartModelDetails.collaborationLobbyNetConnectionServiceProxy,
					_insulinTitrationDecisionPanelModel, chartModelDetails.viewNavigator);
			confirmChangePopUp.accessibilityProperties = new AccessibilityProperties();
		}

		override public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			var insulinDescriptorTemplate:MedicationChartDescriptor = new MedicationChartDescriptor();
			var matchingInsulinChartDescriptors:Vector.<IChartDescriptor> = new Vector.<IChartDescriptor>();
			for each (var medicationCode:String in INSULIN_MEDICATION_CODES)
			{
				insulinDescriptorTemplate.medicationCode = medicationCode;
				if (chartDescriptors.getValueByKey(insulinDescriptorTemplate.descriptorKey) != null)
				{
					var matchingInsulinChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey) as
							IChartDescriptor;
					if (matchingInsulinChartDescriptor)
						matchingInsulinChartDescriptors.push(matchingInsulinChartDescriptor);
				}
			}

			var bloodGlucoseDescriptorTemplate:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			bloodGlucoseDescriptorTemplate.vitalSignCategory = VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
			var matchingBloodGlucoseChartDescriptor:IChartDescriptor;
			if (chartDescriptors.getValueByKey(bloodGlucoseDescriptorTemplate.descriptorKey) != null)
			{
				matchingBloodGlucoseChartDescriptor = chartDescriptors.removeByKey(bloodGlucoseDescriptorTemplate.descriptorKey) as
						IChartDescriptor;
			}

			var reorderedChartDescriptors:OrderedMap = new OrderedMap();
			for each (var otherChartDescriptor:IChartDescriptor in chartDescriptors.values())
			{
				reorderedChartDescriptors.addKeyValue(otherChartDescriptor.descriptorKey, otherChartDescriptor);
			}

			if (matchingInsulinChartDescriptors.length > 0)
			{
				for each (matchingInsulinChartDescriptor in matchingInsulinChartDescriptors)
				{
					reorderedChartDescriptors.addKeyValue(matchingInsulinChartDescriptor.descriptorKey,
							matchingInsulinChartDescriptor);
				}
			}
			if (matchingBloodGlucoseChartDescriptor)
				reorderedChartDescriptors.addKeyValue(matchingBloodGlucoseChartDescriptor.descriptorKey,
						matchingBloodGlucoseChartDescriptor);

			return reorderedChartDescriptors;
		}

		override protected function createTitrationDecisionPanel():IVisualElement
		{
			var panel:InsulinTitrationDecisionPanel = new InsulinTitrationDecisionPanel();
			panel.model = _insulinTitrationDecisionPanelModel;
			panel.controller = _panelController;
			return panel;
		}

		override protected function titrationDecisionPanelWidth():Number
		{
			return InsulinTitrationDecisionPanel.INSULIN_TITRATION_DECISION_PANEL_WIDTH;
		}

		override protected function isProtocolMeasurementChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return InsulinTitrationSupportChartModifierFactory.isBloodGlucoseChartDescriptor(chartDescriptor);
		}

		private function initializeInsulinTitrationDecisionPanelModel():void
		{
			_insulinTitrationDecisionPanelModel = new InsulinTitrationDecisionPanelModel(chartModelDetails);
			_insulinTitrationDecisionPanelModel.updateAreVitalSignRequirementsMet();
			_insulinTitrationDecisionPanelModel.updateIsAdherencePerfect();
		}

		override public function set chartModelDetails(chartModelDetails:IChartModelDetails):void
		{
			super.chartModelDetails = chartModelDetails;
			if (_insulinTitrationDecisionPanelModel)
			{
				_insulinTitrationDecisionPanelModel.chartModelDetails = chartModelDetails;
				_insulinTitrationDecisionPanelModel.updateForRecordChange();

			}
		}

		override public function save():Boolean
		{
			if (!super.save())
				return false;

			_insulinTitrationDecisionPanelModel.evaluateForSave();

			if (!_insulinTitrationDecisionPanelModel.isChangeSpecified)
			{
				// TODO: Use a better UI to tell the user that a change must be specified to save
				Alert.show("Please choose a change to the dose before saving.");
				return false;
			}
			else if (_changeConfirmed)
			{
				// already showing popup, so assume this is the result of user clicking OK
				_changeConfirmed = false;
				return true;
			}
			else
			{
				confirmChangePopUp.model = new ConfirmChangePopUpModel(_insulinTitrationDecisionPanelModel.previousDoseValue, _insulinTitrationDecisionPanelModel.dosageChangeValueLabel, _insulinTitrationDecisionPanelModel.newDose, _insulinTitrationDecisionPanelModel.confirmationMessage);
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
				if (_insulinTitrationDecisionPanelModel.save())
				{
					_changeConfirmed = true;
					chartModelDetails.healthChartsModel.save();
				}
			}
		}

		override public function destroy():void
		{
			super.destroy();
			if (_panelController)
			{
				_panelController.destroy();
				_panelController = null;
			}
		}

		override protected function get titrationDecisionModel():TitrationDecisionModelBase
		{
			return _insulinTitrationDecisionPanelModel;
		}
	}
}
