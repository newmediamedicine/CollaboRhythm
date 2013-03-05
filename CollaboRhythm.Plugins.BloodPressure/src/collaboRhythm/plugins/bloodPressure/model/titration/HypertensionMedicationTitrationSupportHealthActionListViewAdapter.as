package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationHealthActionConditionsMet;
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationHealthActionInsufficientAdherence;
	import collaboRhythm.plugins.bloodPressure.view.titration.HypertensionMedicationTitrationHealthActionInsufficientMeasurement;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.medications.TitrationSupportHealthActionListViewAdapterBase;

	import spark.components.Button;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;

	public class HypertensionMedicationTitrationSupportHealthActionListViewAdapter extends TitrationSupportHealthActionListViewAdapterBase implements IHealthActionListViewAdapter
	{
		private var _healthAction:HypertensionMedicationTitrationSupportHealthAction;
		private var _model:HypertensionMedicationTitrationSupportHealthActionListViewModel;

		public function HypertensionMedicationTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthAction = new HypertensionMedicationTitrationSupportHealthAction();
			_model = new HypertensionMedicationTitrationSupportHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider);

			var activeRecordAccount:Account = new Account();
			activeRecordAccount.accountId = healthActionModelDetailsProvider.accountId;
			activeRecordAccount.primaryRecord = healthActionModelDetailsProvider.record;
			_decisionModel = new HypertensionMedicationTitrationModel(healthActionModelDetailsProvider.activeAccount, activeRecordAccount);
			_decisionModel.evaluateForSteps();
		}

		override protected function createConditionsMetIcon():SpriteVisualElement
		{
			return new HypertensionMedicationTitrationHealthActionConditionsMet();
		}

		override protected function createInsufficientAdherenceIcon():SpriteVisualElement
		{
			return new HypertensionMedicationTitrationHealthActionInsufficientAdherence();
		}

		override protected function createInsufficientMeasurementIcon():SpriteVisualElement
		{
			return new HypertensionMedicationTitrationHealthActionInsufficientMeasurement();
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
			return "MAP";
		}

		public function get description():String
		{
			return "Medication Adjustment Plan";
		}

		public function get indication():String
		{
			return "Hypertension";
		}

		public function get primaryInstructions():String
		{
			return "Every 14 days, consider an adjustment";
		}

		public function get secondaryInstructions():String
		{
			return "0 days until your next adjustment";
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
					// TODO: come up with an appropriate additional information when a change has been made
					additionalAdherenceInformation = "Changed";
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
				_controller = new HealthActionListViewControllerBase(_model);
			}
			return _controller;
		}

		public function createCommandButtons():Vector.<Button>
		{
			return null;
		}
	}
}
