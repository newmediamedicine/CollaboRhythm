package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	public class HIVMedicationChoice
	{
		private var _ndc:String;
		private var _rxCUI:String;
		private var _name:MedicationName;
		private var _dose:int;
		private var _frequency:int;
		private var _instructions:String;

		public function HIVMedicationChoice(ndc:String, rxNorm:String, name:String, dose:int, frequency:int, instructions:String)
		{
			_ndc = ndc;
			_rxCUI = rxNorm;
			_name = MedicationNameUtil.parseName(name);
			_dose = dose;
			_frequency = frequency;
			_instructions = instructions;
		}

		public function get ndc():String
		{
			return _ndc;
		}

		public function set ndc(value:String):void
		{
			_ndc = value;
		}

		public function get rxCUI():String
		{
			return _rxCUI;
		}

		public function set rxCUI(value:String):void
		{
			_rxCUI = value;
		}

		public function get name():MedicationName
		{
			return _name;
		}

		public function set name(value:MedicationName):void
		{
			_name = value;
		}

		public function get dose():int
		{
			return _dose;
		}

		public function set dose(value:int):void
		{
			_dose = value;
		}

		public function get frequency():int
		{
			return _frequency;
		}

		public function set frequency(value:int):void
		{
			_frequency = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}
	}
}
