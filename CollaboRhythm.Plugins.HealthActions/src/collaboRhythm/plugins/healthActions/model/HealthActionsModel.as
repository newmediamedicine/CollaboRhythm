package collaboRhythm.plugins.healthActions.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.collections.ArrayCollection;

	public class HealthActionsModel implements IHealthActionModelDetailsProvider
	{
		private var _record:Record;
		private var _accountId:String;
		private var _healthActionListViewAdapters:ArrayCollection;
		private var _healthActionInputControllerFactory:MasterHealthActionInputControllerFactory;

		public function HealthActionsModel(componentContainer:IComponentContainer,
										   record:Record, accountId:String)
		{
			_record = record;
			_accountId = accountId;

			var healthActionListViewAdapterFactory:MasterHealthActionListViewAdapterFactory = new MasterHealthActionListViewAdapterFactory(componentContainer);
			_healthActionListViewAdapters = healthActionListViewAdapterFactory.createUnscheduledHealthActionViewAdapters(record);
			_healthActionInputControllerFactory = new MasterHealthActionInputControllerFactory(componentContainer);
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get healthActionListViewAdapters():ArrayCollection
		{
			return _healthActionListViewAdapters;
		}

		public function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		{
			return _healthActionInputControllerFactory;
		}
	}
}
