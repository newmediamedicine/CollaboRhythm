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
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceModel;
    import collaboRhythm.plugins.schedule.shared.model.DataInputModelAndController;
    import collaboRhythm.plugins.schedule.shared.model.IDataInputView;
    import collaboRhythm.plugins.schedule.shared.model.PendingAdherenceItem;
    import collaboRhythm.plugins.schedule.shared.model.ScheduleModelKey;
    import collaboRhythm.plugins.schedule.view.IScheduleFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleClockWidgetView;
	import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;
	import collaboRhythm.plugins.schedule.view.ScheduleTimelineFullView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.model.InteractionLogUtil;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	import flash.net.URLVariables;

	import mx.core.UIComponent;

    import spark.transitions.SlideViewTransition;

    public class ScheduleAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Schedule";

		private var _scheduleModel:ScheduleModel;
		private var _scheduleClockController:ScheduleClockController;
		private var _scheduleTimelineController:ScheduleTimelineController;
		private var _scheduleReportingController:ScheduleReportingController;

		private var _widgetView:ScheduleClockWidgetView;
		private var _fullView:IScheduleFullView;

		private var _isInvokeEventListenerAdded:Boolean;
		private var _handledInvokeEvents:Vector.<String> = new Vector.<String>();

		public function ScheduleAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		override public function initialize():void
		{
			super.initialize();
			initializeScheduleModel();

			updateWidgetViewModel();
			updateFullViewModel();

			if (!_fullView && _fullContainer)
			{
				createFullView();
				prepareFullView();
			}
		}

		private function initializeScheduleModel():void
		{
			if (!_scheduleModel)
			{
				_scheduleModel = new ScheduleModel(_componentContainer, _activeRecordAccount.primaryRecord,
						_activeRecordAccount.accountId);
				_activeRecordAccount.primaryRecord.appData.put(ScheduleModelKey.SCHEDULE_MODEL_KEY, _scheduleModel);
				_activeRecordAccount.primaryRecord.appData.put(AdherencePerformanceModel.ADHERENCE_PERFORMANCE_MODEL_KEY,
															   _scheduleModel.adherencePerformanceModel);
				_scheduleModel.addEventListener(ScheduleModelEvent.INITIALIZED, scheduleModel_initializedHandler, false,
												0, true);
			}
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new ScheduleClockWidgetView();
			return _widgetView;
		}

		override protected function createFullView():UIComponent
		{
			if (isWorkstationMode)
			{
				_fullView = new ScheduleTimelineFullView();
			}
			else
			{
				_fullView = new ScheduleReportingFullView();
			}

			return _fullView as UIComponent;
		}

		override public function reloadUserData():void
		{
			hideFullView();
			removeUserData();
			if (_fullView)
			{
				_fullView.destroyChildren();
			}
			if (_widgetView)
			{
				_widgetView.destroyChildren();
			}

			initializeScheduleModel();
			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && scheduleModel)
			{
				_widgetView.init(this, scheduleModel);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView && scheduleModel)
			{
				_fullView.init(this, scheduleModel);
			}
		}

		private function scheduleModel_initializedHandler(event:ScheduleModelEvent):void
		{
			if (!_isInvokeEventListenerAdded)
			{
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler, false, 0, true);
				_isInvokeEventListenerAdded = true;
			}
		}

		private function invokeHandler(event:InvokeEvent):void
		{
			if (event.arguments.length != 0)
			{
				var urlString:String = event.arguments[0];
				var urlVariablesString:String = urlString.split("//")[1];
				var urlVariables:URLVariables = new URLVariables(urlVariablesString);

                if (urlVariables.success == "true")
                {
                    var closestScheduleItemOccurrence:ScheduleItemOccurrence = scheduleModel.scheduleReportingModel.findClosestScheduleItemOccurrence(urlVariables.name, urlVariables.measurements);

					var dataInputController:DataInputControllerBase = scheduleModel.dataInputControllerFactory.createHealthActionInputController(urlVariables.name, urlVariables.measurements, closestScheduleItemOccurrence, urlVariables, scheduleModel, _viewNavigator);

                    if (ReflectionUtils.getClass(_viewNavigator.activeView) == dataInputController.dataInputViewClass)
                    {
                        var dataInputView:IDataInputView = IDataInputView(_viewNavigator.activeView);
                        dataInputView.dataInputController.updateVariables(urlVariables);
                    }    
                    else
                    {
                        dataInputController.handleVariables();
                    }
                }
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ScheduleClockWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as IScheduleFullView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return isWorkstationMode;
		}

		private function showFullViewHandler(event:AppEvent):void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, event.appController, event.startRect,
									   event.applicationName, event.viaMechanism));
		}

		private function hideFullViewHandler(event:AppEvent):void
		{
			if (hideFullView())
				InteractionLogUtil.logAppInstance(_logger, "Hide full view", event.viaMechanism, this);
		}

		private function get scheduleModel():ScheduleModel
		{
			return _scheduleModel;
		}

		public function get scheduleClockController():ScheduleClockController
		{
			if (!_scheduleClockController)
			{
				_scheduleClockController = new ScheduleClockController(scheduleModel,
																	   _widgetView as ScheduleClockWidgetView);
				_scheduleClockController.addEventListener(AppEvent.SHOW_FULL_VIEW, showFullViewHandler, false, 0, true);
			}
			return _scheduleClockController;
		}

		public function get scheduleTimelineController():ScheduleTimelineController
		{
			if (!_scheduleTimelineController)
			{
				_scheduleTimelineController = new ScheduleTimelineController(scheduleModel,
																			 _fullView as ScheduleTimelineFullView);
			}
			return _scheduleTimelineController;
		}

		public function get scheduleReportingController():ScheduleReportingController
		{
			if (!_scheduleReportingController)
			{
				_scheduleReportingController = new ScheduleReportingController(scheduleModel, _fullView as ScheduleReportingFullView, _viewNavigator);
				_scheduleReportingController.addEventListener(AppEvent.HIDE_FULL_VIEW, hideFullViewHandler, false, 0,
															  true);
				_scheduleReportingController.addEventListener(AppEvent.SHOW_FULL_VIEW, showFullViewHandler, false, 0,
															  true);
			}
			return _scheduleReportingController;
		}

		protected override function removeUserData():void
		{
			// TODO: destroy/cleanup any reference and listeners in scheduleModel
			if (_scheduleModel)
			{
				if (_scheduleModel.hasEventListener(ScheduleModelEvent.INITIALIZED))
				{
					_scheduleModel.removeEventListener(ScheduleModelEvent.INITIALIZED,
													   scheduleModel_initializedHandler);
				}
				if (_scheduleModel.hasEventListener(AppEvent.SHOW_FULL_VIEW))
				{
					_scheduleClockController.removeEventListener(AppEvent.SHOW_FULL_VIEW, showFullViewHandler);
				}
				if (_scheduleModel.hasEventListener(AppEvent.HIDE_FULL_VIEW))
				{
					_scheduleReportingController.removeEventListener(AppEvent.HIDE_FULL_VIEW, hideFullViewHandler);
				}
				_scheduleModel.destroy();
				_scheduleModel = null;
			}

			_activeRecordAccount.primaryRecord.appData.remove(ScheduleModelKey.SCHEDULE_MODEL_KEY);
			_activeRecordAccount.primaryRecord.appData.remove(AdherencePerformanceModel.ADHERENCE_PERFORMANCE_MODEL_KEY);
			_scheduleClockController = null;
			_scheduleTimelineController = null;
			_scheduleReportingController = null;
		}
	}
}