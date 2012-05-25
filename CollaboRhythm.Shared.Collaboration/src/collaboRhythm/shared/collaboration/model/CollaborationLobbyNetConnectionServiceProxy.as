package collaboRhythm.shared.collaboration.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	public class CollaborationLobbyNetConnectionServiceProxy extends EventDispatcher implements ICollaborationLobbyNetConnectionServiceProxy
	{
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _applicationDomain:ApplicationDomain;

		private var _collaborationModel:CollaborationModel;
		private var _netConnection:NetConnection;
		private var _registeredAliases:Vector.<String>;

		public function CollaborationLobbyNetConnectionServiceProxy(collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService,
																	applicationDomain:ApplicationDomain)
		{
			_collaborationLobbyNetConnectionService = collaborationLobbyNetConnectionService;
			_applicationDomain = applicationDomain;
			_collaborationModel = _collaborationLobbyNetConnectionService.collaborationModel;
			_netConnection = _collaborationLobbyNetConnectionService.netConnection;
			_netConnection.client.receiveCollaborationViewSynchronization = receiveCollaborationViewSynchronization;
			_registeredAliases = new Vector.<String>;
		}

		public function sendCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
															 synchronizeData:* = null):void
		{
			var synchronizeDataName:String = getQualifiedClassName(synchronizeData);
			var synchronizeDataByteArray:ByteArray = null;
			if (synchronizeData != null)
			{

				registerClassAliasForSynchronizeData(synchronizeDataName);
				synchronizeDataByteArray = new ByteArray();
				synchronizeDataByteArray.writeObject(synchronizeData);
				synchronizeDataByteArray.position = 0;
			}
			_netConnection.call("sendCollaborationViewSynchronization", null, synchronizeClassName, synchronizeFunction,
					synchronizeDataName,
					synchronizeDataByteArray, _collaborationModel.activeAccount.accountId,
					_collaborationModel.activeAccount.peerId, _collaborationModel.peerAccount.accountId,
					_collaborationModel.peerAccount.peerId, _collaborationModel.passWord);
		}

		public function receiveCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
																synchronizeDataName:String,
																synchronizeDataByteArray:ByteArray, sourcePeerId:String,
																passWord:String):void
		{
			var synchronizeData:*;
			if (synchronizeDataByteArray != null)
			{
				registerClassAliasForSynchronizeData(synchronizeDataName);
				synchronizeData = synchronizeDataByteArray.readObject();
			}

			var collaborationViewSynchronizationEvent:CollaborationViewSynchronizationEvent = new CollaborationViewSynchronizationEvent(synchronizeClassName,
					synchronizeFunction, synchronizeData);
			dispatchEvent(collaborationViewSynchronizationEvent);
		}

		private function registerClassAliasForSynchronizeData(synchronizeDataName:String):void
		{
			if (_registeredAliases.indexOf(synchronizeDataName) == -1)
			{
				registerClassAlias(synchronizeDataName, _applicationDomain.getDefinition(synchronizeDataName) as Class);
				_registeredAliases.push(synchronizeDataName);
			}
		}
	}
}
