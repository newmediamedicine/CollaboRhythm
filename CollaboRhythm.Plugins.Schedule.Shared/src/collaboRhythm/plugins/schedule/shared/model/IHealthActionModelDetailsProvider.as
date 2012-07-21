package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.Record;

	public interface IHealthActionModelDetailsProvider
	{
		function get activeAccount():Account;
		function get record():Record;
		function get accountId():String;
		function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		function get navigationProxy():IApplicationNavigationProxy;
		function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy;
	}
}
