package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.TitratingInsulinHealthActionInputController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.DecisionClinicianAgree;
	import collaboRhythm.plugins.insulinTitrationSupport.view.DecisionClinicianNew;
	import collaboRhythm.plugins.insulinTitrationSupport.view.DecisionPatientAgree;
	import collaboRhythm.plugins.insulinTitrationSupport.view.DecisionPatientNew;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.IImageCacheService;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.core.IVisualElement;

	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;
	import spark.filters.GlowFilter;

	public class TitratingInsulinHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		private var _currentHealthActionListViewAdapter:IHealthActionListViewAdapter;

		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		private var _imageCacheService:IImageCacheService;
		private var _medicationName:MedicationName;
		private var _decisionModel:InsulinTitrationDecisionModelBase;

		public static const INSULIN_TITRATION_DECISION_HEALTH_ACTION_SCHEDULE_NAME:String = "Insulin Titration Decision";

		public function TitratingInsulinHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
														   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   currentHealthActionListViewAdapter:IHealthActionListViewAdapter,
														   medicationOrder:MedicationOrder = null)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			_currentHealthActionListViewAdapter = currentHealthActionListViewAdapter;

			if (scheduleItemOccurrence)
			{
				_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;
			}
			else if (medicationOrder)
			{
				_medicationOrder = medicationOrder;
			}

			if (_medicationOrder)
				_medicationName = MedicationNameUtil.parseName(_medicationOrder.name.text);

			_imageCacheService = WorkstationKernel.instance.resolve(IImageCacheService) as IImageCacheService;
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence = getDecisionScheduleItemOccurrence();
			if (decisionScheduleItemOccurrence)
			{
				_decisionModel = new InsulinTitrationDecisionHealthActionModel(decisionScheduleItemOccurrence,
						healthActionModelDetailsProvider);
				_decisionModel.updateAreBloodGlucoseRequirementsMet();
				_decisionModel.updateIsAdherencePerfect();
			}
		}

		public function getDecisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var finder:DecisionScheduleItemOccurrenceFinder = new DecisionScheduleItemOccurrenceFinder(_healthActionModelDetailsProvider);
			return finder.getDecisionScheduleItemOccurrence();
		}

		public function initializeIcon(icon:SpriteVisualElement, group:Group):void
		{
			icon.percentHeight = icon.percentWidth = 60;
			icon.right = icon.bottom = 0;
			icon.visible = false;
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xFFFFFF;
			glowFilter.alpha = 0.7;
			glowFilter.blurX = icon.width / 8;
			glowFilter.blurY = icon.width / 8;
			glowFilter.strength = icon.width / 8;

			icon.filters = [glowFilter];
			group.addElement(icon);
		}

		public function get healthAction():HealthActionBase
		{
			return _currentHealthActionListViewAdapter.healthAction;
		}

		public function createImage():Image
		{
			return _currentHealthActionListViewAdapter.createImage();
		}

		public function createCustomView():IVisualElement
		{
			var group:Group = _currentHealthActionListViewAdapter.createCustomView() as Group;
			if (group)
			{
			}
			else
			{
				group = new Group();
				group.percentWidth = 100;
				group.percentHeight = 100;
			}

			var decisionClinicianNew:DecisionClinicianNew;
			var decisionClinicianAgree:DecisionClinicianAgree;
			var decisionPatientNew:DecisionPatientNew;
			var decisionPatientAgree:DecisionPatientAgree;

			decisionClinicianNew = new DecisionClinicianNew();
			initializeIcon(decisionClinicianNew, group);
			decisionClinicianAgree = new DecisionClinicianAgree();
			initializeIcon(decisionClinicianAgree, group);
			decisionPatientNew = new DecisionPatientNew();
			initializeIcon(decisionPatientNew, group);
			decisionPatientAgree = new DecisionPatientAgree();
			initializeIcon(decisionPatientAgree, group);

			if (_decisionModel)
			{
				var isDecisionResultByPatient:Boolean = _decisionModel.isDecisionResultByPatient(_decisionModel.latestDecisionResult);
				var isDecisionResultAgreement:Boolean = _decisionModel.isDecisionResultAgreement(_decisionModel.latestDecisionResult);
				decisionClinicianAgree.visible = _decisionModel.latestDecisionResult && !isDecisionResultByPatient && isDecisionResultAgreement;
				decisionClinicianNew.visible = _decisionModel.latestDecisionResult && !isDecisionResultByPatient && !isDecisionResultAgreement;
				decisionPatientAgree.visible = _decisionModel.latestDecisionResult && isDecisionResultByPatient && isDecisionResultAgreement;
				decisionPatientNew.visible = _decisionModel.latestDecisionResult && isDecisionResultByPatient && !isDecisionResultAgreement;
			}

//			group.addEventListener(Event.RESIZE, group_resizeHandler);
			return group;
		}

		public function get name():String
		{
			return _currentHealthActionListViewAdapter.name;
		}

		public function get description():String
		{
			return _currentHealthActionListViewAdapter.description;
		}

		public function get indication():String
		{
			return _currentHealthActionListViewAdapter.indication;
		}

		public function get primaryInstructions():String
		{
			return _currentHealthActionListViewAdapter.primaryInstructions;
		}

		public function get secondaryInstructions():String
		{
			return _currentHealthActionListViewAdapter.secondaryInstructions;
		}

		public function get instructionalVideoPath():String
		{
			return _currentHealthActionListViewAdapter.instructionalVideoPath;
		}

		public function set instructionalVideoPath(value:String):void
		{
			_currentHealthActionListViewAdapter.instructionalVideoPath = value;
		}

		public function get additionalAdherenceInformation():String
		{
			return _currentHealthActionListViewAdapter.additionalAdherenceInformation;
		}

		public function get model():IHealthActionListViewModel
		{
			return _currentHealthActionListViewAdapter.model;
		}

		public function get controller():IHealthActionListViewController
		{
			return _currentHealthActionListViewAdapter.controller;
		}

		public function createCommandButtons():Vector.<Button>
		{
			var insulinTitrationButton:Button = new Button();
			insulinTitrationButton.id = TitratingInsulinHealthActionInputController.INSULIN_TITRATION_BUTTON_ID;
			insulinTitrationButton.label = "Insulin Titration";
			return new <Button>[insulinTitrationButton];
		}
	}
}
