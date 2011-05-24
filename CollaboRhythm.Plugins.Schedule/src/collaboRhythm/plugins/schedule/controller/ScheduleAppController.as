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
package collaboRhythm.plugins.schedule.controller
{
	import collaboRhythm.plugins.schedule.model.ScheduleHealthRecordService;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.view.ScheduleFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import com.coltware.airxlib.log.TCPSyslogTarget;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.net.URLVariables;
	
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;

	public class ScheduleAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Schedule";

		private var _scheduleHealthRecordService:ScheduleHealthRecordService;
		private var _scheduleWidgetViewController:ScheduleWidgetViewController;
		private var _scheduleFullViewController:ScheduleFullViewController;
		private var _widgetView:ScheduleWidgetView;
		private var _fullView:ScheduleFullView;
		
		private static var log:ILogger = Log.getLogger("ScheduleAppController");
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ScheduleWidgetView;
		}
		
		public override function get isFullViewSupported():Boolean
		{
			return true;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as ScheduleFullView;
		}
		
		public function ScheduleAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ScheduleWidgetView = new ScheduleWidgetView();
			if (_user != null)
			{
				_scheduleWidgetViewController = new ScheduleWidgetViewController(isWorkstationMode, scheduleModel, newWidgetView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				newWidgetView.init(_scheduleWidgetViewController, scheduleModel);
			}
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ScheduleFullView = new ScheduleFullView();
			if (_user != null)
			{
				_scheduleFullViewController = new ScheduleFullViewController(isWorkstationMode, scheduleModel, newFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				newFullView.init(_scheduleFullViewController, scheduleModel);
			}
			return newFullView;
		}
		
		private function get scheduleModel():ScheduleModel
		{
			if (_user != null)
			{
				if (_user.appData[ScheduleModel.SCHEDULE_KEY] == null)
				{
					_user.appData[ScheduleModel.SCHEDULE_KEY] = new ScheduleModel(_user);
				}
				return _user.getAppData(ScheduleModel.SCHEDULE_KEY, ScheduleModel) as ScheduleModel;
			}
			return null;
		}
		
		public override function initialize():void
		{
			super.initialize();
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);

			if (!scheduleModel.initialized)
			{
				_scheduleHealthRecordService = new ScheduleHealthRecordService(_healthRecordService.oauthConsumerKey, _healthRecordService.oauthConsumerSecret, _healthRecordService.indivoServerBaseURL);
				_scheduleHealthRecordService.copyLoginResults(_healthRecordService);
				_scheduleHealthRecordService.loadScheduleGroups(_user);
			}
			
			if (_widgetView)
			{
				_scheduleWidgetViewController = new ScheduleWidgetViewController(isWorkstationMode, scheduleModel, _widgetView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				(_widgetView as ScheduleWidgetView).init(_scheduleWidgetViewController, scheduleModel);
			}
			prepareFullView();
		}
		
		private function onInvoke(event:InvokeEvent):void {
			if (event.arguments.length != 0)
			{
				var urlString:String = event.arguments[0];
				var urlVariablesString:String = urlString.split("//")[1];
				var urlVariables:URLVariables = new URLVariables(urlVariablesString);
				log.debug(urlVariables.systolic);
			}
		}
		
//		protected override function prepareWidgetView():void
//		{
//			
//		}
//		
//		protected override function prepareFullView():void
//		{
//			super.prepareFullView();
////			if (_fullView)
////			{
////				_scheduleFullViewController = new ScheduleFullViewController(scheduleModel, _fullView as ScheduleFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
////				_fullView.init(_scheduleFullViewController, scheduleModel);
////			}
//		}
		
		public override function close():void
		{
			for each (var scheduleGroup:ScheduleGroup in scheduleModel.scheduleGroupsCollection)
			{
				if (scheduleGroup.changed)
				{
					_scheduleHealthRecordService.archiveScheduleGroup(_user, scheduleGroup.id);
					var scheduleGroupDocument:XML = scheduleGroup.convertToXML();
					var scheduleItemDocumentIDs:Vector.<String> = new Vector.<String>;
					for each (var scheduleItem:ScheduleItemBase in scheduleGroup.scheduleItemsCollection)
					{
						scheduleItemDocumentIDs.push(scheduleItem.id);
					}
					_scheduleHealthRecordService.createScheduleGroup(_user, scheduleGroupDocument, scheduleItemDocumentIDs);
				}
			}
			super.close();

//			for each (var adherenceGroupView:AdherenceGroupView in _fullView.adherenceGroupViews)
//			{
//				adherenceGroupView.unwatchAll();
//				adherenceGroupView.adherenceWindowView.unwatchAll();
//			}
//			for each (var medicationView:MedicationView in _fullView.medicationViews)
//			{
//				medicationView.unwatchAll();
//			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		override protected function removeUserData():void
		{
			user.appData[ScheduleModel.SCHEDULE_KEY] = null;
		}
	}
}