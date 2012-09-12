package collaboRhythm.shared.collaboration.model
{
	import flash.utils.getQualifiedClassName;

	public class SynchronizationService
	{
		private var _collaborationSynchronizationController:*;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _documentId:String;

		public function SynchronizationService(collaborationSynchronizationController:*,
											   collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy,
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
			if (event.synchronizeData)
			{
				if (_documentId)
				{
					if (_documentId == event.synchronizeData as String)
					{
						_collaborationSynchronizationController[event.synchronizeFunction](false);
					}
				}
				else
				{
					_collaborationSynchronizationController[event.synchronizeFunction](false, event.synchronizeData);
				}
			}
			else
			{
				_collaborationSynchronizationController[event.synchronizeFunction](false);
			}
		}

		public function synchronize(synchronizeFunction:String, calledLocally:Boolean, synchronizeData:* = null,
									executeLocally:Boolean = true):Boolean
		{
			if (calledLocally)
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
			_collaborationLobbyNetConnectionServiceProxy.removeEventListener(getQualifiedClassName(collaborationSynchronizationController), collaborationViewSynchronization_eventHandler);
		}
	}
}
