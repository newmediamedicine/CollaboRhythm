package collaboRhythm.shared.model
{
	import flash.media.Microphone;
	import flash.net.NetConnection;

	public interface ICollaborationLobbyNetConnectionService
	{
		function get isConnected():Boolean;

		function get netConnection():NetConnection;

		function sendCollaborationMessage(messageType:String):void;

		function enterCollaborationLobby():void;

		function createNetStreamConnections(microphone:Microphone, peerId:String,
											   peerAccountId:String):void;

		function closeNetStreamConnections():void;
	}
}
