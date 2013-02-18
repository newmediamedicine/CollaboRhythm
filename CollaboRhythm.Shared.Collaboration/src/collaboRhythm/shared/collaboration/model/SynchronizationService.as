package collaboRhythm.shared.collaboration.model
{
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import flash.utils.getQualifiedClassName;

	/**
	 * Service for synchronizing controller methods during collaboration.
	 */
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

			var qualifiedClassName:String = getQualifiedClassName(_collaborationSynchronizationController);
			if (_documentId == null && _collaborationLobbyNetConnectionServiceProxy.hasEventListener(qualifiedClassName))
			{
				throw new Error("Attempted to created SynchronizationService for controller " + qualifiedClassName + " but there is already another instance of SynchronizationService for this same controller type. Only one instance of SynchronizationService may exist at a time for a given controller type.");
			}
			else
			{
				_collaborationLobbyNetConnectionServiceProxy.addEventListener(qualifiedClassName,
						collaborationViewSynchronization_eventHandler);
			}
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

		/**
		 * Synchronize a controller method between multiple collaboration clients.
		 * @param synchronizeFunction The name of the function to synchronize. The method will be invoked via reflection on the other client(s).
		 * @param synchronizeData must be the documentId, if a documentId was specified in the constructor; other wise, the synchronizeData may be any data used by the method
		 * @param executeLocally
		 * @return
		 */
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
