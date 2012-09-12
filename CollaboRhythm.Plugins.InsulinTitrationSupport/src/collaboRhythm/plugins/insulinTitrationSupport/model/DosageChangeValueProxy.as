package collaboRhythm.plugins.insulinTitrationSupport.model
{
	/**
	 * Proxy for use with the SpinnerList and DosageChangeSpinnerItemRenderer to allow evaluating whether a dosage
	 * change value matches the current persisted dosage change.
	 */
	public class DosageChangeValueProxy
	{
		private var _value:Number;
		private var _model:InsulinTitrationDecisionModelBase;

		public function DosageChangeValueProxy(value:Number, model:InsulinTitrationDecisionModelBase)
		{
			_value = value;
			_model = model;
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
		}

		public function get isCurrentPersistedDosageChange():Boolean
		{
			return !isNaN(value) && model.decisionAdherenceItemAlreadyPersisted() && value == model.persistedDosageChangeValue;
		}
	}
}
