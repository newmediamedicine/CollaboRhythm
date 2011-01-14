package collaboRhythm.mobile.controller
{
	import collaboRhythm.mobile.view.FullContainerView;
	import collaboRhythm.workstation.controller.ApplicationControllerBase;
	import collaboRhythm.workstation.controller.CollaborationMediator;
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.view.CollaborationRoomView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	
	import flash.events.Event;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.View;
	import spark.components.ViewNavigator;
	import spark.effects.ViewTransition;

	public class MobileApplicationController extends ApplicationControllerBase
	{
		private var _homeView:View;
		private var _mobileApplication:CollaboRhythmMobileApplication;
		
		public override function get collaborationRoomView():CollaborationRoomView
		{
			return null;
		}
		
		public override function get remoteUsersView():RemoteUsersListView
		{
			return null;
		}
		
		public override function get widgetsContainer():IVisualElementContainer
		{
			return _mobileApplication.navigator.activeView;
		}
		
		public override function get scheduleWidgetContainer():IVisualElementContainer
		{
			return _mobileApplication.navigator.activeView;
		}
		
		public override function get fullContainer():IVisualElementContainer
		{
			return _mobileApplication.navigator.activeView;
		}
		
		public function MobileApplicationController(mobileApplication:CollaboRhythmMobileApplication)
		{
//			_homeView = homeView;
			_mobileApplication = mobileApplication;
			
			_mobileApplication.navigator.addEventListener(Event.COMPLETE, viewNavigator_TransitionCompleteHandler);
		}
		
		private function viewNavigator_TransitionCompleteHandler(event:Event):void
		{
//			if (_mobileApplication.navigator.activeView is FullContainerView)
//				mobilecollaborationMediator.showFullView(_mobileApplication.navigator.activeView);
//			else if (_mobileApplication.navigator.activeView is WidgetContainerView)
//				mobilecollaborationMediator.showWidgetView(_mobileApplication.navigator.activeView);
		}
		
		protected function get mobilecollaborationMediator():MobileCollaborationMediator
		{
			return _collaborationMediator as MobileCollaborationMediator;
		}

		public function main():void  
		{
			initLogging();
			logger.info("Logging initialized");
			
			_settings = new Settings();
			_settings.isWorkstationMode = false;
			logger.info("Settings initialized");
			
			initializeComponents();
			logger.info("Components initialized");
			
			// TODO: show the appropriate view
			_collaborationMediator = new MobileCollaborationMediator(this);
			
//			initializeWindows();
//			logger.info("Windows initialized");
			//_homeView.addElement();
		}
		
	}
}