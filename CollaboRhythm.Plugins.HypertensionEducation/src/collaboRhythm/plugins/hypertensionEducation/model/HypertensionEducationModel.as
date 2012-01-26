package collaboRhythm.plugins.hypertensionEducation.model
{

	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.settings.Settings;

	import mx.collections.ArrayCollection;

	public class HypertensionEducationModel
	{
		private var _settings:Settings;
		private var _activeRecord:Record;
		private var _utterances:ArrayCollection = new ArrayCollection();

		public function HypertensionEducationModel(settings:Settings, activeRecord:Record)
		{
			_settings = settings;
			_activeRecord = activeRecord;
		}

		public function generateFeedback():void
		{
			getCurrentConcentrations();
		}

		private function getCurrentConcentrations():void
		{
			for each (var medication:MedicationComponentAdherenceModel in _activeRecord.bloodPressureModel.focusSimulation.medications)
			{
				createUtterance(medication);
			}
		}

		private function createUtterance(medication:MedicationComponentAdherenceModel):void
		{
			var goalUtterance:String;
			switch (medication.concentrationSeverityLevel)
			{
				case 0:
					goalUtterance = "well below your goal";
					break;
				case 1:
					goalUtterance = "below your goal";
					break;
				case 2:
					goalUtterance = "at your goal";
					break;
				case 3:
					goalUtterance = "above your goal";
					break;
				case 4:
					goalUtterance = "well above your goal";
					break;
			}
			var utterance:String = "Your " + medication.name.text + " is currently " + goalUtterance + ".";
			_utterances.addItem(utterance);
		}

		public function get utterances():ArrayCollection
		{
			return _utterances;
		}

		public function set utterances(value:ArrayCollection):void
		{
			_utterances = value;
		}
	}
}
