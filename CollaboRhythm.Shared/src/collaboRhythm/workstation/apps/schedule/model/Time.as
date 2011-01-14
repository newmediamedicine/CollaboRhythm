package collaboRhythm.workstation.apps.schedule.model
{
	import collaboRhythm.workstation.apps.medications.model.Medication;

	public class Time
	{
		private var _scheduleItems:Vector.<ScheduleItemBase>;
		private var _adherenceGroup:AdherenceGroup;
		
		public function Time()
		{
			_scheduleItems = new Vector.<ScheduleItemBase>;
		}
		
		public function get scheduleItems():Vector.<ScheduleItemBase>
		{
			return _scheduleItems;
		}
		
		public function set scheduleItems(value:Vector.<ScheduleItemBase>):void
		{
			_scheduleItems = value;
		}
		
		public function get adherenceGroup():AdherenceGroup
		{
			return _adherenceGroup;
		}
		
		public function set adherenceGroup(value:AdherenceGroup):void
		{
			_adherenceGroup = value;
		}
		
		public function removeMedication(medication:Medication):void
		{
			var medicationIndex:Number = _scheduleItems.indexOf(medication);
			_scheduleItems.splice(medicationIndex, 1);
		}
		
		public function addMedication(medication:Medication):void
		{
			_scheduleItems.push(medication);
		}
		
	}
}