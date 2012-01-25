package collaboRhythm.plugins.postOpHome.controller
{
	import collaboRhythm.plugins.postOpHome.model.PostOpHomeModel;
	import collaboRhythm.plugins.postOpHome.view.PostOpHelpView;
	import collaboRhythm.plugins.postOpHome.view.PostOpHomeButtonWidgetView;
	import collaboRhythm.plugins.postOpHome.view.PostOpHomeFullView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;

	import mx.core.UIComponent;

	import spark.transitions.SlideViewTransition;

	public class PostOpHomeAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "PostOpHome";


		private var _widgetView:PostOpHomeButtonWidgetView;
		private var _fullView:PostOpHomeFullView;

		private var _postOpHomeModel:PostOpHomeModel;

		public function PostOpHomeAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		override public function initialize():void
		{
			super.initialize();
			if (!_fullView && _fullContainer)
			{
				createFullView();
				prepareFullView();
			}
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new PostOpHomeButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new PostOpHomeFullView();
			return _fullView;
		}

		override public function reloadUserData():void
		{
			removeUserData();

			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, postOpHomeModel, _collaborationLobbyNetConnectionService);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.init(this, postOpHomeModel, _collaborationLobbyNetConnectionService,
						_activeRecordAccount.accountId);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get postOpHomeModel():PostOpHomeModel
		{
			if (!_postOpHomeModel)
			{
				_postOpHomeModel = new PostOpHomeModel(_activeRecordAccount.primaryRecord, activeAccount.accountId);
			}
			return _postOpHomeModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as PostOpHomeButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as PostOpHomeFullView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		override public function dispatchShowFullView(viaMechanism:String):void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this, null, null, viaMechanism));
		}

		public function openPostOpHelpView():void
		{
			_viewNavigator.pushView(PostOpHelpView, null, null, new SlideViewTransition());
		}
	}
}