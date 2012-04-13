package collaboRhythm.shared.model
{
	import flash.net.NetConnection;

	public interface ICollaborationLobbyNetConnectionService
	{
		function get isConnected():Boolean;

		function get netConnection():NetConnection;

		function sendMessage(messageType:String, method:String = null):void;

		function enterCollaborationLobby():void;

		function createCommunicationConnection():void;

		function closeCollaborationConnection():void;
	}
}
