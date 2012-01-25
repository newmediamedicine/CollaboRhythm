/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;

	import collaboRhythm.shared.model.healthRecord.IDocumentMetadata;

	import flash.media.Video;
	import flash.net.NetStream;

	import j2as3.collection.HashMap;

	/**
	 * Models all of the data for a user, whether that user is a local user or a remote user.
	 *
	 * @author jom
	 */
	[Bindable]
	public class User
	{
		public static const COLLABORATION_LOBBY_NOT_CONNECTED:String = "CollaborationLobbyNotConnected";
		public static const COLLABORATION_LOBBY_AVAILABLE:String = "CollaborationLobbyAvailable";
		public static const COLLABORATION_LOBBY_AWAY:String = "CollaborationLobbyAway";
		
		public static const COLLABORATION_REQUEST_SENT:String = "CollaborationRequestSent";
		public static const COLLABORATION_REQUEST_RECEIVED:String = "CollaborationRequestReceived";
		public static const COLLABORATION_ROOM_EXITED:String = "CollaborationRoomExited";
		public static const COLLABORATION_ROOM_ENTERED:String = "CollaborationRoomEntered";
		public static const COLLABORATION_ROOM_JOINED:String = "CollaborationRoomJoined";
		
		private var _firstName:String;
		private var _lastName:String;
		private var _userName:String;
		private var _imageURI:String;
//		private var _demographics:UserDemographics;
		private var _contact:Contact;
		
		private var _accountId:String;
		private var _recordId:String;
		private var _isOwnedByLocalAccount:Boolean;
		
		private var _collaborationLobbyConnectionStatus:String = COLLABORATION_LOBBY_NOT_CONNECTED;
		private var _collaborationRoomConnectionStatus:String = COLLABORATION_ROOM_EXITED;
		private var _video:Video = new Video();
		private var _netStream:NetStream;
		private var _collaborationColor:String = "0xFFFFFF";
		
		private var _bloodPressureModel:HealthChartsModel = new HealthChartsModel();
		
		private var _appData:HashMap = new HashMap();
		private var _documentsById:HashMap = new HashMap();
		
		public function User(recordId:String)
		{
			_recordId = recordId;
		}

		public function get isOwnedByLocalAccount():Boolean
		{
			return _isOwnedByLocalAccount;
		}

		public function set isOwnedByLocalAccount(value:Boolean):void
		{
			_isOwnedByLocalAccount = value;
		}

//		public function get demographics():UserDemographics
//		{
//			return _demographics;
//		}
//
//		public function set demographics(value:UserDemographics):void
//		{
//			_demographics = value;
//		}
		
		public function get contact():Contact
		{
			return _contact;
		}
		
		public function set contact(value:Contact):void
		{
			_contact = value;

			// TODO: store the images with the record (as a binary document) or use some other identifier for the file name
		}
		
		public function get accountId():String
		{
			return _accountId;
		}

		public function set accountId(accountId:String):void
		{
			_accountId = accountId;
		}

		public function get recordId():String
		{
			return _recordId;
		}

		public function get collaborationLobbyConnectionStatus():String
		{
			return _collaborationLobbyConnectionStatus;
		}

		public function set collaborationLobbyConnectionStatus(collaborationLobbyConnectionStatus:String):void
		{
			_collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
		}

		public function get collaborationRoomConnectionStatus():String
		{
			return _collaborationRoomConnectionStatus;
		}
		
		public function set collaborationRoomConnectionStatus(value:String):void
		{
			_collaborationRoomConnectionStatus = value;
		}
		
		public function get video():Video
		{
			return _video;
		}
		
		public function set video(value:Video):void
		{
			_video = value;
		}
		
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function set netStream(value:NetStream):void
		{
			_netStream = value;
		}
		
		public function get collaborationColor():String
		{
			return _collaborationColor;
		}
		
		public function set collaborationColor(value:String):void
		{
			_collaborationColor = value;
		}

		public function get bloodPressureModel():HealthChartsModel
		{
			return _bloodPressureModel;
		}

		public function set bloodPressureModel(bloodPressureModel:HealthChartsModel):void
		{
			_bloodPressureModel = bloodPressureModel;
		}

		public function get appData():HashMap
		{
			return _appData;
		}
		
		public function getAppData(key:String, type:Class):Object
		{
			var data:Object = appData[key] as type;
			if (data)
				return data;
			else
				throw new Error("appData on User does not contain a " + (type as Class).toString() + " for key " + key); 
		}

		/**
		 * Registers the document with the specified metadata. The metadata (such as the id) can later be used to
		 * resolve (retrieve) the document object.
		 * @param metadata The metadata describing the document.
		 * @param document The data object representing the document itself. Note that the metadata and the document
		 * can be one in the same if the document implements IDocumentMetadata.
		 */
		public function registerDocument(metadata:IDocumentMetadata, document:Object):void
		{
			_documentsById.put(metadata.id, document);
		}

		/**
		 * Resolves (retrieves) an object representation of a document which has been registered on the User with the
		 * specified id. Optionally performs type checking if documentClass is specified.
		 * @param id The unique id of the document. This should uniquely identify the document in the context of the
		 * backend health record service and in CollaboRhythm.
		 * @param documentClass The expected Class of the document object (optional). If the documentClass is specified
		 * but there is no object that can be cast to the Class, then an error will be thrown.
		 * @return The document object registered for the specified id, if any. Otherwise null.
		 */
		public function resolveDocumentById(id:String, documentClass:Class=null):Object
		{
			var data:Object = _documentsById[id];

			if (documentClass)
			{
				data = data as documentClass;

				if (data)
					return data;
				else
					throw new Error("User does not contain a document object that is a " + (documentClass as Class).toString() + " Class for id " + id);
			}
			else
				return data;
		}

		public function toString():String
		{
			return "User{_userName=" + String(_userName) + ",_accountId=" + String(_accountId) + ",_recordId=" + String(_recordId) + "}";
		}

		public function containsDocumentById(id:String):Boolean
		{
			var data:Object = _documentsById[id];
			return data != null;
		}

		public function clearDocuments():void
		{
			_documentsById = new HashMap();
		}
	}
}