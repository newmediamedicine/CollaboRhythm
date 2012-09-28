package collaboRhythm.shared.model
{
	public interface ICollaborationModel
	{
		function get collaborationState():String;
		function get peerAccount():Account;
	}
}
