package collaboRhythm.plugins.medications.model
{
	import flash.events.Event;

	public class SaveMedicationCompleteEvent extends Event
	{
		public static const SAVE_MEDICATION:String = "Save Medication";

		private var _viewsToPop:int;

		public function SaveMedicationCompleteEvent(type:String, viewsToPop:int)
		{
			super(type);

			_viewsToPop = viewsToPop;
		}

		public function get viewsToPop():int
		{
			return _viewsToPop;
		}
	}
}
