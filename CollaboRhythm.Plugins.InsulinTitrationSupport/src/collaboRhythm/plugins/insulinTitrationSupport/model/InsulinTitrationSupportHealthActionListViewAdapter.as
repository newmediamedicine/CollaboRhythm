package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationHealthActionConditionsMet;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationHealthActionInsufficientAdherence;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationHealthActionInsufficientBloodGlucose;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetails;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.core.IVisualElement;
	import mx.events.PropertyChangeEvent;

	import spark.components.Group;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;
	import spark.filters.ColorMatrixFilter;
	import spark.skins.spark.ImageSkin;

	public class InsulinTitrationSupportHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		[Embed("/assets/images/titrateLevemir.png")]
		private var _titrateLevemirImageClass:Class;

		[Embed("/assets/images/titrateLantus.png")]
		private var _titrateLantusImageClass:Class;

		private var _healthAction:InsulinTitrationSupportHealthAction;
		private var _model:InsulinTitrationSupportHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;
		private var _dosageChangeValueLabel:String;

		private var _medicationScheduleDetails:ScheduleDetails;
		private var _decisionModel:InsulinTitrationDecisionModelBase;
		private var _greyScaleFilter:ColorMatrixFilter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);

		public function InsulinTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthAction = new InsulinTitrationSupportHealthAction();
			_model = new InsulinTitrationSupportHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider);

			var medicationTitrationHelper:MedicationTitrationHelper = new MedicationTitrationHelper(_model.healthActionInputModelDetailsProvider.record,
					WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource);
			_medicationScheduleDetails = medicationTitrationHelper.getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES,
					true);
			_dosageChangeValueLabel = medicationTitrationHelper.dosageChangeValueLabel;

			_decisionModel = new InsulinTitrationDecisionHealthActionModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_decisionModel.updateAreBloodGlucoseRequirementsMet();
			_decisionModel.updateIsAdherencePerfect();
		}

		public function get healthAction():HealthActionBase
		{
			return _healthAction;
		}

		public function createImage():Image
		{
			var image:Image = new Image();
			image.setStyle("skinClass", ImageSkin);

			if (_medicationScheduleDetails.currentSchedule && _medicationScheduleDetails.currentSchedule.name && _medicationScheduleDetails.currentSchedule.name.value == InsulinTitrationSupportChartModifier.INSULIN_LANTUS_CODE)
			{
				image.source = _titrateLantusImageClass;
			}
			else
			{
				image.source = _titrateLevemirImageClass;
			}
			image.smooth = true;
			updateImageForPrerequisites(image);
			_decisionModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function (event:PropertyChangeEvent):void
					{
						if (event.property == "algorithmPrerequisitesSatisfied")
						{
							updateImageForPrerequisites(image);
						}
					}, false, 0, true);
			return image;
		}

		private function updateImageForPrerequisites(image:Image):void
		{
			if (_decisionModel && !_decisionModel.algorithmPrerequisitesSatisfied)
			{
				image.alpha = 0.3;
				image.filters = [_greyScaleFilter];
			}
			else
			{
				image.alpha = 1;
				image.filters = [];
			}
		}

		public function createCustomView():IVisualElement
		{
			var group:Group = new Group();
			group.percentWidth = 100;
			group.percentHeight = 100;

			var insufficientBloodGlucoseIcon:InsulinTitrationHealthActionInsufficientBloodGlucose = new InsulinTitrationHealthActionInsufficientBloodGlucose();
			initializeIcon(insufficientBloodGlucoseIcon, group);
			var insufficientAdherenceIcon:InsulinTitrationHealthActionInsufficientAdherence = new InsulinTitrationHealthActionInsufficientAdherence();
			initializeIcon(insufficientAdherenceIcon, group);
			var conditionsMetIcon:InsulinTitrationHealthActionConditionsMet = new InsulinTitrationHealthActionConditionsMet();
			initializeIcon(conditionsMetIcon, group);

			updateIconsForPrerequisites(insufficientBloodGlucoseIcon, insufficientAdherenceIcon, conditionsMetIcon);
			_decisionModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function (event:PropertyChangeEvent):void
					{
						if (event.property == "algorithmPrerequisitesSatisfied" || event.property == "step2State")
						{
							updateIconsForPrerequisites(insufficientBloodGlucoseIcon, insufficientAdherenceIcon, conditionsMetIcon);
						}
					}, false, 0, true);

			return group;
		}

		private function updateIconsForPrerequisites(insufficientBloodGlucoseIcon:InsulinTitrationHealthActionInsufficientBloodGlucose,
													 insufficientAdherenceIcon:InsulinTitrationHealthActionInsufficientAdherence,
													 conditionsMetIcon:InsulinTitrationHealthActionConditionsMet):void
		{
			insufficientBloodGlucoseIcon.visible = false;
			insufficientAdherenceIcon.visible = false;
			conditionsMetIcon.visible = false;
			if (_decisionModel)
			{
				if (_decisionModel.algorithmPrerequisitesSatisfied)
				{
					conditionsMetIcon.visible = true;
				}
				else if (_decisionModel.step2State == InsulinTitrationDecisionModelBase.STEP_STOP)
				{
					insufficientAdherenceIcon.visible = true;
				}
				else
				{
					insufficientBloodGlucoseIcon.visible = true;
				}
			}
		}

		private function initializeIcon(icon:SpriteVisualElement, group:Group):void
		{
			icon.percentWidth = icon.percentHeight = 100;
			group.addElement(icon);
		}

		public function get name():String
		{
			return InsulinTitrationSupportHealthAction.HEALTH_ACTION_TYPE;
		}

		public function get description():String
		{
			return "Decision Making Health Action";
		}

		public function get indication():String
		{
			return "Diabetes";
		}

		public function get primaryInstructions():String
		{
			return "";
		}

		public function get secondaryInstructions():String
		{
			return "";
		}

		public function get instructionalVideoPath():String
		{
			return "";
		}

		public function set instructionalVideoPath(value:String):void
		{

		}

		public function get additionalAdherenceInformation():String
		{
			var additionalAdherenceInformation:String = "...";

			if (_model.scheduleItemOccurrence.adherenceItem)
			{
				var adherenceResults:Vector.<DocumentBase> = _model.scheduleItemOccurrence.adherenceItem.adherenceResults;
				if (adherenceResults.length != 0)
				{
					additionalAdherenceInformation = _dosageChangeValueLabel;
				}
			}

			return additionalAdherenceInformation;
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			if (!_controller)
			{
				_controller = new HealthActionListViewControllerBase(_model)
			}
			return _controller;
		}
	}
}
