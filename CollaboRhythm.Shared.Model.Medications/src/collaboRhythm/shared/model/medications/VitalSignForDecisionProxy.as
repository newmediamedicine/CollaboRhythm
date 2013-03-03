package collaboRhythm.shared.model.medications
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	/**
	 * Proxy to a VitalSign for use with a decision support system so that the VitalSign instances that are eligible for
	 * use in the decision algorithm can be rendered differently.
	 */
	public class VitalSignForDecisionProxy
	{
		private var _vitalSign:VitalSign;
		private var _decisionModel:TitrationDecisionModelBase;

		public function VitalSignForDecisionProxy(vitalSign:VitalSign, decisionModel:TitrationDecisionModelBase)
		{
			_vitalSign = vitalSign;
			_decisionModel = decisionModel;
		}

		public function get vitalSign():VitalSign
		{
			return _vitalSign;
		}

		public function set vitalSign(value:VitalSign):void
		{
			_vitalSign = value;
		}

		public function get decisionModel():TitrationDecisionModelBase
		{
			return _decisionModel;
		}

		public function set decisionModel(value:TitrationDecisionModelBase):void
		{
			_decisionModel = value;
		}

		public function get dateMeasuredStart():Date
		{
			return vitalSign.dateMeasuredStart;
		}

		public function get resultAsNumber():Number
		{
			return _vitalSign.resultAsNumber;
		}

		/**
		 * Returns true if the measurement is eligible for use with the algorithm
		 */
		public function get isEligible():Boolean
		{
			return decisionModel.isMeasurementEligible(vitalSign);
		}
	}
}
