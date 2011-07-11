package collaboRhythm.tablet.controller
{

	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.tablet.view.ActiveRecordView;

	import mx.core.IVisualElementContainer;

	import spark.components.Application;

	public class TabletApplicationController extends ApplicationControllerBase
	{
		private var _application:Application;
		private var _tabletAppControllersMediator:TabletAppControllersMediator;
		private var _fullContainer:IVisualElementContainer;
		private var _activeRecordView:ActiveRecordView;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;

		public function TabletApplicationController(application:Application)
		{
			_application = application;
		}

		public override function main():void
		{
			super.main();

			_settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController(null);

			createSession();
		}

		public override function openRecordAccount(recordAccount:Account):void
		{
			super.openRecordAccount(recordAccount);
			_activeRecordView = new ActiveRecordView();
			_activeRecordView.init(this, recordAccount);
			_application.addElement(_activeRecordView);
		}

		// the apps are not actually loaded immediately when a record is opened
		// only after the active record view has been created are they loaded, this makes the UI more responsive
		public function activeRecordView_creationCompleteHandler(recordAccount:Account):void
		{
			_fullContainer = _activeRecordView.fullViewsGroup;
			_tabletAppControllersMediator = new TabletAppControllersMediator(_activeRecordView.widgetContainers,
																			 _fullContainer, _settings,
																			 _componentContainer, _collaborationController.collaborationModel.collaborationLobbyNetConnectionService);
			_tabletAppControllersMediator.createAndStartApps(_activeAccount, recordAccount);
			loadDocuments(recordAccount);
		}

		public override function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public override function get applicationSettingsEmbeddedFile():Class
		{
			return _applicationSettingsEmbeddedFile;
		}

		public function get activeRecordView():ActiveRecordView
		{
			return _activeRecordView;
		}
	}
}
