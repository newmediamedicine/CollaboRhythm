package collaboRhythm.shared.model
{
	public interface ICollaborationModel
	{
		function get sourceAccount():Account;

		function get collaborationLobbyNetConnectionService():ICollaborationLobbyNetConnectionService;
	}
}
