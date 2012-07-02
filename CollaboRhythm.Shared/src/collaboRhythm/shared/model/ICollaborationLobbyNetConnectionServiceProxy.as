package collaboRhythm.shared.model
{
	import flash.net.NetConnection;
	import flash.utils.ByteArray;

	public interface ICollaborationLobbyNetConnectionServiceProxy
	{
		function sendCollaborationViewSynchronization(syncrhonizeClassName:String, synchronizeFunction:String,
													  synchronizeData:* = null):void;

		function receiveCollaborationViewSynchronization(syncrhonizeClassName:String, synchronizeFunction:String,
														 synchronizeDataName:String,
														 synchronizeDataByteArray:ByteArray,
														 sourcePeerId:String, passWord:String):void;

		function receiveMessage(messageDataName:String, messageDataByteArray:ByteArray):void;

		function sendMessage(accountId:String, messageData:*):void;
		function get netConnection():NetConnection
	}
}
