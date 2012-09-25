package collaboRhythm.shared.model
{
	import flash.net.NetConnection;
	import flash.utils.ByteArray;

	public interface ICollaborationLobbyNetConnectionServiceProxy
	{
		function sendCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
													  synchronizeData:* = null, executeLocally:Boolean = true):Boolean;

		function receiveCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
														 synchronizeDataName:String,
														 synchronizeDataByteArray:ByteArray,
														 sourcePeerId:String, passWord:String):void;

		function receiveMessage(messageDataName:String, messageDataByteArray:ByteArray):void;

		function sendMessage(accountId:String, messageData:*):void;
		function get netConnection():NetConnection
		function get collaborationModel():ICollaborationModel;
	}
}
