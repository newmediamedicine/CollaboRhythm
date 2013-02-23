package collaboRhythm.plugins.bloodPressure.model.states
{
	import collaboRhythm.shared.model.states.TitrationDecisionSupportStatesFileStoreBase;

	public class BloodPressureMedicationTitrationDecisionSupportStatesFileStore extends TitrationDecisionSupportStatesFileStoreBase
	{
		[Embed("/assets/strings/bloodPressureMedicationTitrationDecisionSupportStates.xml", mimeType="application/octet-stream")]
		private var bloodPressureMedicationTitrationDecisionSupportStatesEmbeddedFile:Class;

		public function BloodPressureMedicationTitrationDecisionSupportStatesFileStore()
		{
			super();
		}

		override public function get titrationDecisionSupportStatesEmbeddedFile():Class
		{
			return bloodPressureMedicationTitrationDecisionSupportStatesEmbeddedFile;
		}
	}
}
