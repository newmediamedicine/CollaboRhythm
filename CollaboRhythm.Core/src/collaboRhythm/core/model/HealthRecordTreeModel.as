package collaboRhythm.core.model
{
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.shared.model.Record;

	public class HealthRecordTreeModel
	{
		private var _record:Record;
		private var _healthRecordServiceFacade:HealthRecordServiceFacade;

		public function HealthRecordTreeModel(record:Record,
											  healthRecordServiceFacade:HealthRecordServiceFacade)
		{
			_record = record;
			_healthRecordServiceFacade = healthRecordServiceFacade;
		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			_record = value;
		}

		public function get healthRecordServiceFacade():HealthRecordServiceFacade
		{
			return _healthRecordServiceFacade;
		}

		public function set healthRecordServiceFacade(value:HealthRecordServiceFacade):void
		{
			_healthRecordServiceFacade = value;
		}
	}
}
