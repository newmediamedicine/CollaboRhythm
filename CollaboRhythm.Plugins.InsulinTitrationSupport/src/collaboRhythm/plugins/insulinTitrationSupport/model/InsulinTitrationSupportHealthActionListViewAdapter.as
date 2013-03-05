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
	import collaboRhythm.shared.model.medications.MedicationTitrationHelper;
	import collaboRhythm.shared.model.medications.TitrationSupportHealthActionListViewAdapterBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import spark.components.Button;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;

	public class InsulinTitrationSupportHealthActionListViewAdapter extends TitrationSupportHealthActionListViewAdapterBase implements IHealthActionListViewAdapter
	{
		private var _healthAction:InsulinTitrationSupportHealthAction;
		private var _model:InsulinTitrationSupportHealthActionListViewModel;
		private var _dosageChangeValueLabel:String;

		private var _medicationScheduleDetails:ScheduleDetails;

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
			_decisionModel.evaluateForSteps();
		}

		override protected function createConditionsMetIcon():SpriteVisualElement
		{
			return new InsulinTitrationHealthActionConditionsMet();
		}

		override protected function createInsufficientAdherenceIcon():SpriteVisualElement
		{
			return new InsulinTitrationHealthActionInsufficientAdherence();
		}

		override protected function createInsufficientMeasurementIcon():SpriteVisualElement
		{
			return new InsulinTitrationHealthActionInsufficientBloodGlucose();
		}

		public function get healthAction():HealthActionBase
		{
			return _healthAction;
		}

		public function createImage():Image
		{
			return null;
		}

		public function get name():String
		{
			return InsulinTitrationSupportHealthAction.HEALTH_ACTION_TYPE;
		}

		public function get description():String
		{
			return "Dose Change Decision";
		}

		public function get indication():String
		{
			return "Diabetes";
		}

		public function get primaryInstructions():String
		{
			return "View this daily to learn about titration";
		}

		public function get secondaryInstructions():String
		{
			return "Only make a change when appropriate";
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

			if (_model.scheduleItemOccurrence && _model.scheduleItemOccurrence.adherenceItem)
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

		public function createCommandButtons():Vector.<Button>
		{
			return null;
		}
	}
}
