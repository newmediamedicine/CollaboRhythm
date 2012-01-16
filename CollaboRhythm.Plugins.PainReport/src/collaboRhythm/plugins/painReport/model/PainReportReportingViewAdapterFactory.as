package collaboRhythm.plugins.painReport.model
{

	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;

	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class PainReportReportingViewAdapterFactory implements IReportingViewAdapterFactory
	{
		public function PainReportReportingViewAdapterFactory()
		{
		}

		public function isMatchingReportingViewAdapterFactory(name:String = null,
															  scheduleItem:ScheduleItemBase = null):Boolean
		{
			return false;
		}

		public function createAdherencePerformanceEvaluator(scheduleItemOccurrence:ScheduleItemOccurrence):AdherencePerformanceEvaluatorBase
		{
			return null;
		}

		public function createReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence):IReportingViewAdapter
		{
			return new PainReportViewAdapter();
		}

		public function createReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
											 scheduleModel:IScheduleModel):ScheduleItemOccurrenceReportingModelBase
		{
			return null;
		}

		public function get reportingViewAdaptersCollection():ArrayCollection
		{
			var reportingViewAdaptersCollection:ArrayCollection = new ArrayCollection();
			var reportingViewAdapter:IReportingViewAdapter = new PainReportViewAdapter();
			reportingViewAdaptersCollection.addItem(reportingViewAdapter);

			return reportingViewAdaptersCollection;
		}
	}
}
