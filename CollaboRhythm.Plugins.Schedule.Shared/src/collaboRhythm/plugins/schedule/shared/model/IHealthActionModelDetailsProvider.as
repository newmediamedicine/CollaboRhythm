package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public interface IHealthActionModelDetailsProvider
	{
		function get activeAccount():Account;
		function get record():Record;
		function get accountId():String;
		function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		function get navigationProxy():IApplicationNavigationProxy;
		function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy;

		function get componentContainer():IComponentContainer;

		function get currentDateSource():ICurrentDateSource;
	}
}
