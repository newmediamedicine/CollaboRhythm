package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;

	import flash.events.Event;

	import mx.events.FlexEvent;

	import mx.events.PropertyChangeEvent;

	/**
	 * Proxy for use with the SpinnerList and DosageChangeSpinnerItemRenderer to allow evaluating whether a dosage
	 * change value matches the current persisted dosage change.
	 */
	[Bindable]
	public class DosageChangeValueProxy
	{
		private var _value:Number;
		private var _model:InsulinTitrationDecisionModelBase;

		public function DosageChangeValueProxy(value:Number, model:InsulinTitrationDecisionModelBase)
		{
			_value = value;
			this.model = model;
		}

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
		}

		public function get model():InsulinTitrationDecisionModelBase
		{
			return _model;
		}

		public function set model(value:InsulinTitrationDecisionModelBase):void
		{
			_model = value;
			_model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler)
		}

		public function get isCurrentPersistedDosageChange():Boolean
		{
			return !isNaN(value) && model.decisionAdherenceItemAlreadyPersisted() && value == model.persistedDosageChangeValue;
		}

		/**
		 * Returns true if the latest decision (by either party) was to agree with the decision of the other party
		 */
		public function get isLatestAgreementDosageChange():Boolean
		{
			// TODO: Is it necessarily correct to subtract the previousDoseValue to determine the decision dosage change?
			return !isNaN(value) && !isNaN(model.latestDecisionDose) && value == model.latestDecisionDose - model.previousDoseValue && model.isDecisionResultAgreement(model.latestDecisionResult);
		}

		public function get isLatestDecisionByPatient():Boolean
		{
			return model.isDecisionResultByPatient(model.latestDecisionResult);
		}

		public function get isPatientLatestDosageChange():Boolean
		{
			return !isNaN(value) && !isNaN(model.patientLatestDecisionDose) && value == model.patientLatestDecisionDose - model.previousDoseValue;
		}

		public function get isClinicianLatestDosageChange():Boolean
		{
			return !isNaN(value) && !isNaN(model.clinicianLatestDecisionDose) && value == model.clinicianLatestDecisionDose - model.previousDoseValue;
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
		}
	}
}
