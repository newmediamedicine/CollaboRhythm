package collaboRhythm.plugins.equipment.chameleonSpirometer.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public class RescueInhalerHealthActionInputModel extends HealthActionInputModelBase
	{
		public function RescueInhalerHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
													  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}


		override public function set urlVariables(value:URLVariables):void
		{
			// abstract, subclasses should override
			_urlVariables = value;
		}
	}
}
