package collaboRhythm.workstation.controller.apps
{
	import collaboRhythm.workstation.model.CollaborationRoomNetConnectionServiceProxy;
	import collaboRhythm.workstation.model.CommonHealthRecordService;
	import collaboRhythm.workstation.model.User;
	
	import flash.net.getClassByAlias;
	
	import mx.core.IVisualElementContainer;
	
	import org.indivo.client.Pha;

	/**
	 * Creates workstation apps and prepares them for use in a parent container.
	 * 
	 */
	public class WorkstationAppControllerFactory
	{
		private var _widgetParentContainer:IVisualElementContainer;
		private var _fullParentContainer:IVisualElementContainer;
		private var _healthRecordService:CommonHealthRecordService;
		private var _user:User;
		private var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
		public function WorkstationAppControllerFactory()
		{
		}

		public function get widgetParentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		public function set widgetParentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
		}

		public function get fullParentContainer():IVisualElementContainer
		{
			return _fullParentContainer;
		}

		public function set fullParentContainer(value:IVisualElementContainer):void
		{
			_fullParentContainer = value;
		}

		public function get healthRecordService():CommonHealthRecordService
		{
			return _healthRecordService;
		}

		public function set healthRecordService(value:CommonHealthRecordService):void
		{
			_healthRecordService = value;
		}

		public function get user():User
		{
			return _user;
		}

		public function set user(value:User):void
		{
			_user = value;
		}
		
		public function get collaborationRoomNetConnectionServiceProxy():CollaborationRoomNetConnectionServiceProxy
		{
			return _collaborationRoomNetConnectionServiceProxy;
		}
		
		public function set collaborationRoomNetConnectionServiceProxy(value:CollaborationRoomNetConnectionServiceProxy):void
		{
			_collaborationRoomNetConnectionServiceProxy = value;
		}

		public function createApp(appClass:Class):WorkstationAppControllerBase
		{
			// TODO:
//			var appClass:Class = getClassByAlias(appType);
//			if (appClass == null)
//				throw new Error("Unable to get class for app: " + appType);
			
			// TODO: eliminate constructor parameters and just use properties instead to make it easier to implement/maintain sub-classes of WorkstationAppController
			var appObject:Object = new appClass(_widgetParentContainer, _fullParentContainer);
			if (appObject == null)
				throw new Error("Unable to create instance of app: " + appClass);
			
			var app:WorkstationAppControllerBase = appObject as WorkstationAppControllerBase; 
			
			app.healthRecordService = _healthRecordService;
			app.user = _user;
			app.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionServiceProxy;
			app.initialize();
			
			return app;
		}
	}
}