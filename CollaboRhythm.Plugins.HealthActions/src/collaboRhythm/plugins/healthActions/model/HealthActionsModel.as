package collaboRhythm.plugins.healthActions.model
{
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.collections.ArrayCollection;

	public class HealthActionsModel
	{
		private var _healthActionListViewAdapters:ArrayCollection;

		public function HealthActionsModel(componentContainer:IComponentContainer,
										   record:Record)
		{
			var healthActionListViewAdapterFactory:MasterHealthActionListViewAdapterFactory = new MasterHealthActionListViewAdapterFactory(componentContainer);
			_healthActionListViewAdapters = healthActionListViewAdapterFactory.createUnscheduledHealthActionViewAdapters(record);
		}

		public function get healthActionListViewAdapters():ArrayCollection
		{
			return _healthActionListViewAdapters;
		}
	}
}
