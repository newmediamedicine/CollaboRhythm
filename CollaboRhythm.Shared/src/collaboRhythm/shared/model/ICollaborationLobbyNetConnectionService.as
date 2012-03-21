package collaboRhythm.shared.model
{
	import flash.net.NetConnection;

	public interface ICollaborationLobbyNetConnectionService
	{
		function get isConnected():Boolean;

		function get netConnection():NetConnection;

		function sendMessage(messageType:String, subjectAccountId:String, sourceAccountId:String, sourcePeerId:String,
							 targetAccountId:String, targetPeerId:String, passWord:String):void;

		function enterCollaborationLobby():void;

		function createCommunicationConnection():void;
	}
}
