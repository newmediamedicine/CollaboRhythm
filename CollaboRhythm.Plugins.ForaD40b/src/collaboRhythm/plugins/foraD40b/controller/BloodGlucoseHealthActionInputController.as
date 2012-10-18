package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHistoryView;
	import collaboRhythm.plugins.foraD40b.view.HypoglycemiaActionPlanSummaryView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import com.adobe.nativeExtensions.Vibration;

	import flash.net.URLVariables;

	import mx.binding.utils.BindingUtils;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodGlucoseHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BloodGlucoseHealthActionInputView;

		private var _dataInputModel:BloodGlucoseHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function BloodGlucoseHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BloodGlucoseHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider, scheduleCollectionsProvider);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			BindingUtils.bindSetter(currentView_changeHandler, _dataInputModel, "currentView");
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModel.handleHealthActionResult();
		}

		public function handleHealthActionSelected():void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModel.handleHealthActionSelected();
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModel.handleUrlVariables(urlVariables);
		}

		public function nextStep():void
		{
			if (_synchronizationService.synchronize("nextStep"))
			{
				return;
			}

			_dataInputModel.nextStep(_synchronizationService.initiatedLocally);
		}

		public function createAndSubmitBloodGlucoseVitalSign():void
		{
			_dataInputModel.createBloodGlucoseVitalSign();
			submitBloodGlucose(_dataInputModel.bloodGlucoseVitalSign);
		}

		public function submitBloodGlucose(bloodGlucoseVitalSign:VitalSign):void
		{
			if (_synchronizationService.synchronize("submitBloodGlucose", bloodGlucoseVitalSign))
			{
				return;
			}

			_dataInputModel.submitBloodGlucose(bloodGlucoseVitalSign, _synchronizationService.initiatedLocally);
		}

		private function currentView_changeHandler(currentView:Class):void
		{
			if (currentView == null)
			{
				if (_synchronizationService && _synchronizationService.initiatedLocally &&
						_dataInputModel.pushedViewCount != 0)
				{
					for (var pushedViewIndex:int = 0; pushedViewIndex < _dataInputModel.pushedViewCount;
						 pushedViewIndex++)
					{
						_viewNavigator.popView();
					}
					_dataInputModel.pushedViewCount = 0;
				}

				removeCollaborationViewSynchronizationEventListener();
			}
			else
			{
				pushView(currentView);
			}
		}

		private function pushView(currentView:Class):void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);
			_viewNavigator.pushView(currentView, healthActionInputModelAndController, null, new SlideViewTransition());
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}

		public function startWaitTimer():void
		{
			if (_synchronizationService.synchronize("startWaitTimer"))
			{
				return;
			}

			_dataInputModel.startWaitTimer();
		}

		public function updateManualBloodGlucose(text:String = ""):void
		{
			if (_synchronizationService.synchronize("updateManualBloodGlucose", text))
			{
				return;
			}

			_dataInputModel.manualBloodGlucose = text;
		}

		public function updateDateMeasuredStart(selectedDate:Date):void
		{
			if (_synchronizationService.synchronize("updateDateMeasuredStart", selectedDate))
			{
				return;
			}

			_dataInputModel.dateMeasuredStart = selectedDate;
		}

		public function quitHypoglycemiaActionPlan():void
		{
			if (_synchronizationService.synchronize("quitHypoglycemiaActionPlan"))
			{
				return;
			}

			_dataInputModel.quitHypoglycemiaActionPlan(_synchronizationService.initiatedLocally);
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			if (_synchronizationService.synchronize("addEatCarbsHealthAction", description))
			{
				return;
			}

			_dataInputModel.addEatCarbsHealthAction(description);
		}

		public function showHypoglycemiaActionPlanSummaryView(bloodGlucoseVitalSignDate:Date):void
		{
			if (_synchronizationService.synchronize("showHypoglycemiaActionPlanSummaryView", bloodGlucoseVitalSignDate))
			{
				return;
			}

			_viewNavigator.pushView(HypoglycemiaActionPlanSummaryView,
					[bloodGlucoseVitalSignDate, this, _dataInputModel]);
		}

		public function addWaitHealthAction(seconds:int):void
		{
			if (_synchronizationService.synchronize("addWaitHealthAction", seconds))
			{
				return;
			}

			_dataInputModel.addWaitHealthAction(seconds);
		}

		public function setBloodGlucoseHistoryListScrollPosition(scrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("setBloodGlucoseHistoryListScrollPosition", scrollPosition, false))
			{
				return;
			}

			_dataInputModel.setBloodGlucoseHistoryListScrollerPosition(scrollPosition);
		}

		public function simpleCarbsItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("simpleCarbsItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModel.simpleCarbsItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs15gItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs15gItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModel.complexCarbs15gItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs30gItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs30gItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModel.complexCarbs30gItemList_changeHandler(selectedIndex);
		}

		public function synchronizeActionsListScrollPosition(verticalScrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("synchronizeActionsListScrollPosition", verticalScrollPosition,
					false))
			{
				return;
			}

			_dataInputModel.synchronizeActionsListScrollerPosition(verticalScrollPosition);
		}

		public function addCollaborationViewSynchronizationEventListener():void
		{
			if (!_synchronizationService)
			{
				_synchronizationService = new SynchronizationService(this,
						_collaborationLobbyNetConnectionServiceProxy);
			}
		}

		public function removeCollaborationViewSynchronizationEventListener():void
		{
			if (_synchronizationService)
			{
				if (_synchronizationService.synchronize("removeCollaborationViewSynchronizationEventListener"))
				{
					return;
				}

				_synchronizationService.removeEventListener(this);
			}
		}

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}

		public function showBloodGlucoseHistoryView():void
		{
			if (_synchronizationService.synchronize("showBloodGlucoseHistoryView"))
			{
				return;
			}

			pushView(BloodGlucoseHistoryView);
		}

		public function playVideo(instructionalVideoPath:String):void
		{
			// TODO: Currently using the vibration native extension with modifications to play a video
			var vibration:Vibration = new (Vibration);
			vibration.vibrate(instructionalVideoPath, "video/*");
		}
	}
}