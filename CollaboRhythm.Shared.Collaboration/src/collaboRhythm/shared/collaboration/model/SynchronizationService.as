package collaboRhythm.shared.collaboration.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import flash.utils.getQualifiedClassName;

	public class SynchronizationService
	{
		private var _collaborationSynchronizationController:*;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _documentId:String;

		private var _primaryCall:Boolean = true;
		private var _initiatedLocally:Boolean;

		public function SynchronizationService(collaborationSynchronizationController:*,
											   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
											   documentId:String = null)
		{
			_collaborationSynchronizationController = collaborationSynchronizationController;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_documentId = documentId;

			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(_collaborationSynchronizationController),
					collaborationViewSynchronization_eventHandler);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			_primaryCall = false;
			_initiatedLocally = event.initiatedLocally;

			if (event.synchronizeData == null)
			{
				_collaborationSynchronizationController[event.synchronizeFunction]();
			}
			else
			{
				if (_documentId)
				{
					if (_documentId == event.synchronizeData as String)
					{
						_collaborationSynchronizationController[event.synchronizeFunction]();
					}
				}
				else
				{
					_collaborationSynchronizationController[event.synchronizeFunction](event.synchronizeData);
				}
			}

			_primaryCall = true;
		}

		public function synchronize(synchronizeFunction:String, synchronizeData:* = null,
									executeLocally:Boolean = true):Boolean
		{
			if (_primaryCall)
			{
				var serverCheckRequired:Boolean = _collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(_collaborationSynchronizationController),
						synchronizeFunction, synchronizeData, executeLocally);

				return serverCheckRequired;
			}
			else
			{
				return false;
			}
		}

		public function removeEventListener(collaborationSynchronizationController:*):void
		{
			_collaborationLobbyNetConnectionServiceProxy.removeEventListener(getQualifiedClassName(collaborationSynchronizationController),
					collaborationViewSynchronization_eventHandler);
		}

		public function get initiatedLocally():Boolean
		{
			return _initiatedLocally;
		}

		public function get primaryCall():Boolean
		{
			return _primaryCall;
		}
	}
}
