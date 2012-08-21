package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public class InsulinTitrationDecisionHealthActionModel extends InsulinTitrationDecisionModelBase
	{
		private var _decisionScheduleItemOccurrence:ScheduleItemOccurrence;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		
		public function InsulinTitrationDecisionHealthActionModel(decisionScheduleItemOccurrence:ScheduleItemOccurrence,
																	healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_decisionScheduleItemOccurrence = decisionScheduleItemOccurrence;
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			super();
			updateForRecordChange();
		}

		override public function get record():Record
		{
			return _healthActionModelDetailsProvider ? _healthActionModelDetailsProvider.record : null;
		}

		override protected function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _decisionScheduleItemOccurrence;
		}

		override protected function get componentContainer():IComponentContainer
		{
			return _healthActionModelDetailsProvider ? _healthActionModelDetailsProvider.componentContainer : null;
		}

		override protected function get accountId():String
		{
			return _healthActionModelDetailsProvider ? _healthActionModelDetailsProvider.accountId : null;
		}

		override protected function get currentDateSource():ICurrentDateSource
		{
			return _healthActionModelDetailsProvider ? _healthActionModelDetailsProvider.currentDateSource : null;
		}
	}
}
