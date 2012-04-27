package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;

	public interface IHealthActionModelDetailsProvider
	{
		function get record():Record;
		function get accountId():String;
		function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		function get navigationProxy():IApplicationNavigationProxy;
	}
}
