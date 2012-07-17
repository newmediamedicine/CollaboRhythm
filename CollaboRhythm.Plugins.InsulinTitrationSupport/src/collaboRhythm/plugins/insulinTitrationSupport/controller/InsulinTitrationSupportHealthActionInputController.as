package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionInputModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationSupportHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;
	import flash.utils.getQualifiedClassName;

	import spark.components.ViewNavigator;

	public class InsulinTitrationSupportHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinTitrationSupportHealthActionInputView;

		private var _dataInputModel:InsulinTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function InsulinTitrationSupportHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																		   viewNavigator:ViewNavigator,
																		   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_dataInputModel = new InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData)
			{
				this[event.synchronizeFunction](CollaborationLobbyNetConnectionServiceProxy.REMOTE, event.synchronizeData);
			}
			else
			{
				this[event.synchronizeFunction](CollaborationLobbyNetConnectionServiceProxy.REMOTE);
			}
		}

		public function handleHealthActionResult():void
		{
			prepareChartsForDecision(CollaborationLobbyNetConnectionServiceProxy.LOCAL);
			showCharts();
		}

		public function handleHealthActionSelected():void
		{
			prepareChartsForDecision(CollaborationLobbyNetConnectionServiceProxy.LOCAL);
			showCharts();
		}

		public function prepareChartsForDecision(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"prepareChartsForDecision");
			}

			_dataInputModel.prepareChartsForDecision();
		}

		public function showCharts():void
		{
			_dataInputModel.showCharts();
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
		}

		public function get healthActionInputViewClass():Class
		{
			return null;
		}
	}
}
