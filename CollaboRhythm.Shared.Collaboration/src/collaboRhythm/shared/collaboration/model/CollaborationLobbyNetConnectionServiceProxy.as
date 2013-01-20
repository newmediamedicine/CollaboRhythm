package collaboRhythm.shared.collaboration.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.ICollaborationModel;

	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	public class CollaborationLobbyNetConnectionServiceProxy extends EventDispatcher implements ICollaborationLobbyNetConnectionServiceProxy
	{
		protected var _logger:ILogger;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _applicationDomain:ApplicationDomain;

		private var _collaborationModel:CollaborationModel;
		private var _netConnection:NetConnection;
		private var _registeredAliases:Vector.<String>;
		private var _logSynchronizationMethods:Boolean = false;

		public function CollaborationLobbyNetConnectionServiceProxy(collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService,
																	applicationDomain:ApplicationDomain)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_collaborationLobbyNetConnectionService = collaborationLobbyNetConnectionService;
			_applicationDomain = applicationDomain;
			_collaborationModel = _collaborationLobbyNetConnectionService.collaborationModel;
			_netConnection = _collaborationLobbyNetConnectionService.netConnection;
			_netConnection.client.receiveCollaborationViewSynchronization = receiveCollaborationViewSynchronization;
			_netConnection.client.receiveCollaborationViewSynchronizationFailed = receiveCollaborationViewSynchronizationFailed;
			_netConnection.client.receiveMessage = receiveMessage;
			_registeredAliases = new Vector.<String>;
		}

		public function sendMessage(accountId:String, messageData:*):void
		{
			var messageDataName:String = getQualifiedClassName(messageData);
			var messageDataByteArray:ByteArray = new ByteArray();
			registerClassAliasForSynchronizeData(messageDataName);
			messageDataByteArray.writeObject(messageData);
			messageDataByteArray.position = 0;
			_netConnection.call("sendMessage", null, accountId, messageDataName, messageDataByteArray);
		}

		public function receiveMessage(messageDataName:String, messageDataByteArray:ByteArray):void
		{
			registerClassAliasForSynchronizeData(messageDataName);
			var messageData:* = messageDataByteArray.readObject();

			var collaborationMessageEvent:MessageEvent = new MessageEvent(MessageEvent.MESSAGE,
					messageData);
			dispatchEvent(collaborationMessageEvent);
		}

		public function sendCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
															 synchronizeData:* = null, executeLocally:Boolean = true):Boolean
		{
			if (_collaborationModel.collaborationState == CollaborationModel.COLLABORATION_ACTIVE)
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
				if (_logSynchronizationMethods)
				{
					_logger.debug("sendCollaborationViewSynchronization " + synchronizeClassName + "." +
							synchronizeFunction);
				}
				_netConnection.call("sendCollaborationViewSynchronization", null, synchronizeClassName,
						synchronizeFunction,
						synchronizeDataName,
						synchronizeDataByteArray, executeLocally, _collaborationModel.activeAccount.accountId,
						_collaborationModel.activeAccount.peerId, _collaborationModel.peerAccount.accountId,
						_collaborationModel.peerAccount.peerId, _collaborationModel.passWord);
			}
			else if (executeLocally)
			{
				dispatchCollaborationViewSynchronizationEvent(synchronizeClassName, synchronizeFunction,
						synchronizeData, true);
			}

			var serverCheckRequired:Boolean = true;

			return serverCheckRequired;
		}

		public function receiveCollaborationViewSynchronization(synchronizeClassName:String, synchronizeFunction:String,
																synchronizeDataName:String,
																synchronizeDataByteArray:ByteArray, sourcePeerId:String,
																passWord:String):void
		{
			var initiatedLocally:Boolean = (sourcePeerId == _collaborationModel.activeAccount.peerId);
			if (_logSynchronizationMethods)
			{
				_logger.debug("receiveCollaborationViewSynchronization " + (initiatedLocally ? "local" : "non-local") +
						" " + synchronizeClassName + "." + synchronizeFunction);
			}

			if (!initiatedLocally)
			{
				_netConnection.call("acknowledgeCollaborationViewSynchronization", null, synchronizeClassName,
						synchronizeFunction,
						synchronizeDataName,
						synchronizeDataByteArray, _collaborationModel.activeAccount.accountId,
						_collaborationModel.activeAccount.peerId, _collaborationModel.peerAccount.accountId,
						_collaborationModel.peerAccount.peerId, _collaborationModel.passWord);
			}

			var synchronizeData:*;
			if (synchronizeDataByteArray != null)
			{
				registerClassAliasForSynchronizeData(synchronizeDataName);
				synchronizeData = synchronizeDataByteArray.readObject();
			}

			dispatchCollaborationViewSynchronizationEvent(synchronizeClassName, synchronizeFunction, synchronizeData,
					initiatedLocally);
		}

		private function dispatchCollaborationViewSynchronizationEvent(synchronizeClassName:String,
																	   synchronizeFunction:String, synchronizeData:*,
																	   initiatedLocally:Boolean):void
		{
			var collaborationViewSynchronizationEvent:CollaborationViewSynchronizationEvent = new CollaborationViewSynchronizationEvent(synchronizeClassName,
					synchronizeFunction, synchronizeData, initiatedLocally);
						dispatchEvent(collaborationViewSynchronizationEvent);
		}

		private function receiveCollaborationViewSynchronizationFailed():void
		{
			// TODO: function should get the same parameters as receiveCollaborationViewSynchronization; play a sound so the user knows that the action they just attempted failed
			_logger.warn("receiveCollaborationViewSynchronizationFailed attempted action FAILED and will not be performed locally or remotely");
		}

		private function registerClassAliasForSynchronizeData(synchronizeDataName:String):void
		{
			if (_registeredAliases.indexOf(synchronizeDataName) == -1)
			{
				registerClassAlias(synchronizeDataName, _applicationDomain.getDefinition(synchronizeDataName) as Class);
				_registeredAliases.push(synchronizeDataName);
			}
		}

		public function get collaborationState():String
		{
			return _collaborationModel.collaborationState;
		}

		public function get netConnection():NetConnection
		{
			return _netConnection;
		}

		public function get collaborationModel():ICollaborationModel
		{
			return _collaborationModel;
		}

		public function simulateDisconnect():void
		{
			_collaborationLobbyNetConnectionService.simulateDisconnect();
		}
	}
}
