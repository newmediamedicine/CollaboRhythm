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

	import castle.flexbridge.reflection.ReflectionUtils;


	import collaboRhythm.plugins.schedule.model.ScheduleModel;
	import collaboRhythm.plugins.schedule.model.ScheduleModelEvent;
	import collaboRhythm.plugins.schedule.model.ScheduleReportingModel;
	import collaboRhythm.plugins.schedule.model.ScheduleTimelineModel;
	import collaboRhythm.plugins.schedule.shared.model.PendingAdherenceItem;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.view.ScheduleClockWidgetView;
	import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleTimelineFullView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.shared.model.ScheduleItemBase;
	import collaboRhythm.shared.model.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.MedicationScheduleItemsHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	import flash.net.URLVariables;

	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class ScheduleAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Schedule";

		private var _phaHealthRecordService:PhaHealthRecordServiceBase;
		private var _scheduleModel:ScheduleModel;
		private var _scheduleWidgetViewController:ScheduleClockController;
		private var _scheduleFullViewController:ScheduleTimelineController;
		private var _widgetView:ScheduleClockWidgetView;
		private var _fullView:UIComponent;

		private static var log:ILogger = Log.getLogger("ScheduleAppController");

		public function ScheduleAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
			scheduleModel.addEventListener(ScheduleModelEvent.INITIALIZED, scheduleModel_initializedHandler);
			_phaHealthRecordService = new PhaHealthRecordServiceBase(_activeRecordAccount.primaryRecord.settings.oauthChromeConsumerKey,
																	 _activeRecordAccount.primaryRecord.settings.oauthChromeConsumerSecret,
																	 _activeRecordAccount.primaryRecord.settings.indivoServerBaseURL,
																	 _activeAccount);
		}

		private function scheduleModel_initializedHandler(event:ScheduleModelEvent):void
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
		}

		private function invokeHandler(event:InvokeEvent):void
		{
			if (event.arguments.length != 0)
			{
				var urlString:String = event.arguments[0];
				var urlVariablesString:String = urlString.split("//")[1];
				var urlVariables:URLVariables = new URLVariables(urlVariablesString);
				var pendingAdherenceItem:PendingAdherenceItem = scheduleModel.scheduleReportingModel.createPendingAdherenceItem(urlVariables);
				scheduleModel.scheduleReportingModel.currentScheduleGroup = pendingAdherenceItem.scheduleGroup;
				dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this));
			}
		}

		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}

		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ScheduleClockWidgetView;
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
			_fullView = value;
		}

		protected override function createWidgetView():UIComponent
		{
			_widgetView = new ScheduleClockWidgetView();
			return _widgetView;
		}

		override protected function prepareWidgetView():void
		{
			super.prepareWidgetView();
			if (_activeRecordAccount != null)
			{
				_scheduleWidgetViewController = new ScheduleClockController(isWorkstationMode, scheduleModel,
																			_widgetView, _fullParentContainer);//, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
				_widgetView.init(_scheduleWidgetViewController, scheduleModel, _fullParentContainer);
				_scheduleWidgetViewController.addEventListener(AppEvent.SHOW_FULL_VIEW, showFullViewHandler);
			}
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();
			// TODO: update scheduleWidgetViewController with the new scheduleModel (?)
			_widgetView.init(_scheduleWidgetViewController, scheduleModel, _fullParentContainer);
		}

		protected override function createFullView():UIComponent
		{
			if (isWorkstationMode)
			{
				var scheduleTimelineFullView:ScheduleTimelineFullView = new ScheduleTimelineFullView();
				var scheduleTimelineController:ScheduleTimelineController = new ScheduleTimelineController(scheduleModel,
																										   scheduleTimelineFullView);
				scheduleTimelineFullView.init(scheduleTimelineController, scheduleModel);
				return scheduleTimelineFullView;
			}
			else
			{
				var scheduleReportingFullView:ScheduleReportingFullView = new ScheduleReportingFullView();
				var scheduleReportingController:ScheduleReportingController = new ScheduleReportingController(scheduleModel,
																											  scheduleReportingFullView);
				scheduleReportingController.addEventListener(AppEvent.HIDE_FULL_VIEW, hideFullViewHandler);
				scheduleReportingFullView.init(scheduleReportingController, scheduleModel);
				scheduleReportingFullView.scheduleGroupReportingView.init(scheduleModel);
				return scheduleReportingFullView;
			}
		}

		private function showFullViewHandler(event:AppEvent):void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this));
		}

		private function hideFullViewHandler(event:AppEvent):void
		{
			hideFullView();
		}

		protected override function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return isWorkstationMode;
		}

		private function get scheduleModel():ScheduleModel
		{
			if (_scheduleModel == null)
			{
				_scheduleModel = new ScheduleModel(_componentContainer, _activeRecordAccount.primaryRecord);
			}
			return _scheduleModel;
//			if (_activeRecordAccount != null)
//			{
//				if (_activeRecordAccount.primaryRecord.appData[ScheduleModel.SCHEDULE_KEY] == null)
//				{
//					_activeRecordAccount.primaryRecord.appData[ScheduleModel.SCHEDULE_KEY] = new ScheduleModel(_componentContainer);
//				}
//				return _activeRecordAccount.primaryRecord.getAppData(ScheduleModel.SCHEDULE_KEY, ScheduleModel) as ScheduleModel;
//			}
//			return null;
		}

		public override function initialize():void
		{
			super.initialize();

//			if (_widgetView)
//			{
//				_scheduleWidgetViewController = new ScheduleWidgetViewController(isWorkstationMode, scheduleModel, _widgetView, _fullParentContainer);//, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
//				(_widgetView as ScheduleWidgetView).init(_scheduleWidgetViewController, scheduleModel, _fullParentContainer);
//			}
			prepareFullView();
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
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleGroup.scheduleItemsOccurrencesCollection)
					{
						var scheduleItem:ScheduleItemBase = scheduleItemOccurrence.scheduleItem;
						_phaHealthRecordService.archiveDocument(_activeRecordAccount.primaryRecord, scheduleItem.id,
																"rescheduled");
						var newScheduleItemDocument:XML = scheduleItem.rescheduledItem(scheduleGroup.dateStart,
																					   scheduleGroup.dateEnd);
						_phaHealthRecordService.relateNewDocument(_activeRecordAccount.primaryRecord,
																  scheduleItem.getScheduleActionId(),
																  newScheduleItemDocument, "scheduleItem");
//                        var scheduleItem:ScheduleItemBase = scheduleItemOccurrence.scheduleItem;

					}
//					_scheduleHealthRecordService.archiveScheduleGroup(_user, scheduleGroup.id);
//					var scheduleGroupDocument:XML = scheduleGroup.convertToXML();
//					var scheduleItemDocumentIDs:Vector.<String> = new Vector.<String>;
//					for each (var scheduleItem:ScheduleItemBase in scheduleGroup.scheduleItemsCollection)
//					{
//						scheduleItemDocumentIDs.push(scheduleItem.id);
//					}
//					_scheduleHealthRecordService.createScheduleGroup(_user, scheduleGroupDocument, scheduleItemDocumentIDs);
				}
			}
			_scheduleModel = null;
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
//			_activeRecordAccount.primaryRecord.appData[ScheduleModel.SCHEDULE_KEY] = null;
		}
	}
}