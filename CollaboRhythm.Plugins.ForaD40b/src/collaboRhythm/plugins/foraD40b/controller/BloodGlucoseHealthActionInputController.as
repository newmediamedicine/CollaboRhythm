package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.HypoglycemiaActionPlanSummaryView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

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
																viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BloodGlucoseHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			BindingUtils.bindSetter(currentView_changeHandler, _dataInputModel, "currentView");
		}

		public function handleHealthActionResult():void
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
			_dataInputModel.handleUrlVariables(urlVariables);
		}

		public function nextStep(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("nextStep", calledLocally))
			{
				return;
			}

			_dataInputModel.nextStep(calledLocally);
		}

		public function submitBloodGlucose(calledLocally:Boolean, bloodGlucoseAndDateArray:Array):void
		{
			if (_synchronizationService.synchronize("submitBloodGlucose", calledLocally, bloodGlucoseAndDateArray))
			{
				return;
			}

			_dataInputModel.submitBloodGlucose(calledLocally, bloodGlucoseAndDateArray);
		}

		private function currentView_changeHandler(currentView:Class):void
		{
			if (currentView == null)
			{
				if (_dataInputModel.pushedViewCount != 0)
				{
					for (var pushedViewIndex:int = 0; pushedViewIndex < _dataInputModel.pushedViewCount;
						 pushedViewIndex++)
					{
						_viewNavigator.popView();
					}
					_dataInputModel.pushedViewCount = 0;
					removeCollaborationViewSynchronizationEventListener(true);
				}
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

		public function startWaitTimer(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("startWaitTimer", calledLocally))
			{
				return;
			}

			_dataInputModel.startWaitTimer();
		}

		public function updateManualBloodGlucose(calledLocally:Boolean, text:String):void
		{
			if (_synchronizationService.synchronize("updateManualBloodGlucose", calledLocally, text))
			{
				return;
			}

			_dataInputModel.updateManualBloodGlucose(text);
		}

		public function quitHypoglycemiaActionPlan(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("quitHypoglycemiaActionPlan", calledLocally))
			{
				return;
			}

			_dataInputModel.quitHypoglycemiaActionPlan(calledLocally);
		}

		public function addEatCarbsHealthAction(description:String, calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("addEatCarbsHealthAction", calledLocally, description))
			{
				return;
			}

			_dataInputModel.addEatCarbsHealthAction(description);
		}

		public function showHypoglycemiaActionPlanSummaryView(calledLocally:Boolean,
															  bloodGlucoseVitalSignDate:Date):void
		{
			if (_synchronizationService.synchronize("showHypoglycemiaActionPlanSummaryView", calledLocally,
					bloodGlucoseVitalSignDate))
			{
				return;
			}

			_viewNavigator.pushView(HypoglycemiaActionPlanSummaryView,
					[bloodGlucoseVitalSignDate, this, _dataInputModel]);
		}

		public function addWaitHealthAction(calledLocally:Boolean, seconds:int):void
		{
			if (_synchronizationService.synchronize("addWaitHealthAction", calledLocally, seconds))
			{
				return;
			}

			_dataInputModel.addWaitHealthAction(seconds);
		}

		public function setBloodGlucoseHistoryListScrollPosition(calledLocally:Boolean, scrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("setBloodGlucoseHistoryListScrollPosition", calledLocally,
					scrollPosition, false))
			{
				return;
			}

			_dataInputModel.setBloodGlucoseHistoryListScrollerPosition(scrollPosition);
		}

		public function simpleCarbsItemList_changeHandler(calledLocally:Boolean, selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("simpleCarbsItemList_changeHandler", calledLocally, selectedIndex,
					false))
			{
				return;
			}

			_dataInputModel.simpleCarbsItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs15gItemList_changeHandler(calledLocally:Boolean, selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs15gItemList_changeHandler", calledLocally,
					selectedIndex, false))
			{
				return;
			}

			_dataInputModel.complexCarbs15gItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs30gItemList_changeHandler(calledLocally:Boolean, selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs30gItemList_changeHandler", calledLocally,
					selectedIndex, false))
			{
				return;
			}

			_dataInputModel.complexCarbs30gItemList_changeHandler(selectedIndex);
		}

		public function synchronizeActionsListScrollPosition(calledLocally:Boolean, verticalScrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("synchronizeActionsListScrollPosition", calledLocally,
					verticalScrollPosition, false))
			{
				return;
			}

			_dataInputModel.synchronizeActionsListScrollerPosition(verticalScrollPosition);
		}

		public function addCollaborationViewSynchronizationEventListener():void
		{
			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		public function removeCollaborationViewSynchronizationEventListener(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("removeCollaborationViewSynchronizationEventListener",
					calledLocally))
			{
				return;
			}

			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}