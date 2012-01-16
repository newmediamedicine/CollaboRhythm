package collaboRhythm.plugins.healthActions.model
{
	import collaboRhythm.plugins.schedule.shared.model.MasterReportingViewAdapterFactory;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.collections.ArrayCollection;

	public class HealthActionsModel
	{
		private var _reportingViewAdaptersCollection:ArrayCollection;

		public function HealthActionsModel(componentContainer:IComponentContainer)
		{
			var reportingViewAdapterFactory:MasterReportingViewAdapterFactory = new MasterReportingViewAdapterFactory(componentContainer);
			_reportingViewAdaptersCollection = reportingViewAdapterFactory.allReportingViewAdaptersCollection;
		}

		public function get reportingViewAdaptersCollection():ArrayCollection
		{
			return _reportingViewAdaptersCollection;
		}
	}
}
