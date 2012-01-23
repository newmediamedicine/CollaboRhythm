package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.Record;

	public interface IHealthActionModelDetailsProvider
	{
		function get record():Record;
		function get accountId():String;
		function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
	}
}
