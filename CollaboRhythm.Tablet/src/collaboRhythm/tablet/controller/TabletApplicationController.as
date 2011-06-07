package collaboRhythm.tablet.controller
{

    import collaboRhythm.core.controller.ApplicationControllerBase;
    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.view.CollaborationView;
    import collaboRhythm.tablet.view.ActiveRecordView;
    import collaboRhythm.tablet.view.VideosView;

    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.core.IVisualElementContainer;

    import spark.components.Application;

    public class TabletApplicationController extends ApplicationControllerBase
    {
        private const VIDEOS_VIEW:String = "Videos View";

        private var _application:Application;
        private var _tabletAppControllersMediator:TabletAppControllersMediator;
        private var _fullContainer:IVisualElementContainer;
		private var _widgetsContainer:IVisualElementContainer;
		private var _scheduleWidgetContainer:IVisualElementContainer;
        private var _activeRecordView:ActiveRecordView;
        private var _videosView:VideosView;
        private var _currentView:String;

        [Embed("/resources/settings.xml", mimeType="application/octet-stream")]
        private var _applicationSettingsEmbeddedFile:Class;

        public function TabletApplicationController(application:Application)
        {
            _application = application;
        }

        public override function main():void
        {
            super.main();

            _settings.isWorkstationMode = false;

            initCollaborationController(null);

            createSession();

            _application.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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
            _tabletAppControllersMediator = new TabletAppControllersMediator(_activeRecordView.scheduleWidgetGroup,
                                                                             _activeRecordView.bloodPressureWidgetGroup,
                                                                             _activeRecordView.fullViewsGroup,
                                                                             _settings,
                                                                             _componentContainer);
			_tabletAppControllersMediator.createTabletApps(_activeAccount, recordAccount);
            recordAccount.primaryRecord.getDocuments();
        }

        public function openVideosView(recordAccount:Account):void
        {
            _videosView = new VideosView();
            _videosView.init(this, recordAccount);
            _activeRecordView.fullViewsGroup.addElement(_videosView);
            _currentView = VIDEOS_VIEW;
        }

        public override function get collaborationView():CollaborationView
        {
            return null
        }

        public override function get widgetsContainer():IVisualElementContainer
		{
			return _widgetsContainer;
		}

		public override function get scheduleWidgetContainer():IVisualElementContainer
		{
			return _scheduleWidgetContainer;
		}

		public override function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

        private function onKeyUp(event:KeyboardEvent):void
		{
			// If the user presses escape, close the entire application
			if (event.keyCode == Keyboard.BACK)
			{
				if (_activeRecordView.fullViewsGroup.numElements > 0)
                {
                    _activeRecordView.fullViewsGroup.removeAllElements();
                }
			}
		}

        public override function get applicationSettingsEmbeddedFile():Class
        {
            return _applicationSettingsEmbeddedFile;
        }
    }
}
