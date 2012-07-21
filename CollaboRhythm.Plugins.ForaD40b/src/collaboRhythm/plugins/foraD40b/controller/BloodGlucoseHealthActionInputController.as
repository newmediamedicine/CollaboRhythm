package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.HypoglycemiaActionPlanSummaryView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;
	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodGlucoseHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BloodGlucoseHealthActionInputView;

		private var _dataInputModel:BloodGlucoseHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function BloodGlucoseHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BloodGlucoseHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			BindingUtils.bindSetter(currentView_changeHandler, _dataInputModel, "currentView", false, true);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData != null)
			{
				this[event.synchronizeFunction]("remote", event.synchronizeData);
			}
			else
			{
				this[event.synchronizeFunction]("remote");
			}
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

		public function nextStep(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"nextStep");
			}

			_dataInputModel.nextStep(source);
		}

		public function submitBloodGlucose(source:String, bloodGlucoseAndDateArray:Array):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"submitBloodGlucose", bloodGlucoseAndDateArray);
			}

			_dataInputModel.submitBloodGlucose(source, bloodGlucoseAndDateArray);
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
					removeCollaborationViewSynchronizationEventListener();
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

		public function startWaitTimer(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"startWaitTimer");
			}

			_dataInputModel.startWaitTimer();
		}

		public function updateManualBloodGlucose(source:String, text:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"updateManualBloodGlucose",
						text);
			}

			_dataInputModel.updateManualBloodGlucose(text);
		}

		public function quitHypoglycemiaActionPlan(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"quitHypoglycemiaActionPlan");
			}

			_dataInputModel.quitHypoglycemiaActionPlan(source);
		}

		public function addEatCarbsHealthAction(source:String, description:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"addEatCarbsHealthAction",
						description);
			}

			_dataInputModel.addEatCarbsHealthAction(description);
		}

		public function showHypoglycemiaActionPlanSummaryView(source:String, bloodGlucoseVitalSignDate:Date):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"showHypoglycemiaActionPlanSummaryView",
						bloodGlucoseVitalSignDate);
			}

			_viewNavigator.pushView(HypoglycemiaActionPlanSummaryView,
					[bloodGlucoseVitalSignDate, this, _dataInputModel]);
		}

		public function addWaitHealthAction(source:String, seconds:int):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"addWaitHealthAction",
						seconds);
			}

			_dataInputModel.addWaitHealthAction(seconds);
		}

		public function synchronizeBloodGlucoseHistoryListScrollPosition(source:String, scrollPosition:Number):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"synchronizeBloodGlucoseHistoryListScrollPosition",
						scrollPosition);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_dataInputModel.synchronizeBloodGlucoseHistoryListScrollerPosition(scrollPosition);
			}
		}

		public function simpleCarbsItemList_changeHandler(source:String, selectedIndex:int):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"simpleCarbsItemList_changeHandler",
						selectedIndex);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_dataInputModel.simpleCarbsItemList_changeHandler(selectedIndex);
			}
		}

		public function complexCarbs15gItemList_changeHandler(source:String, selectedIndex:int):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"complexCarbs15gItemList_changeHandler",
						selectedIndex);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_dataInputModel.complexCarbs15gItemList_changeHandler(selectedIndex);
			}
		}

		public function complexCarbs30gItemList_changeHandler(source:String, selectedIndex:int):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"complexCarbs30gItemList_changeHandler",
						selectedIndex);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_dataInputModel.complexCarbs30gItemList_changeHandler(selectedIndex);
			}
		}

		public function synchronizeActionsListScrollPosition(source:String, verticalScrollPosition:Number):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"synchronizeActionsListScrollPosition",
						verticalScrollPosition);
			}

			if (source == CollaborationLobbyNetConnectionServiceProxy.REMOTE)
			{
				_dataInputModel.synchronizeActionsListScrollerPosition(verticalScrollPosition);
			}
		}

		public function addCollaborationViewSynchronizationEventListener():void
		{
			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}

		public function removeCollaborationViewSynchronizationEventListener(source:String = ""):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"removeCollaborationViewSynchronizationEventListener");
			}

			_collaborationLobbyNetConnectionServiceProxy.removeEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}
	}
}