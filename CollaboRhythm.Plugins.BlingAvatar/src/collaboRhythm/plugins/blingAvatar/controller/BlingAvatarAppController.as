package collaboRhythm.plugins.blingAvatar.controller
{
	import collaboRhythm.plugins.blingAvatar.model.BlingAvatarModel;
	import collaboRhythm.plugins.blingAvatar.view.BlingAvatarButtonWidgetView;
	import collaboRhythm.plugins.blingAvatar.view.BlingAvatarFullView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import mx.core.UIComponent;

	public class BlingAvatarAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Bling Avatar";

		private var _widgetView:BlingAvatarButtonWidgetView;
		private var _fullView:BlingAvatarFullView;

		private var _blingAvatarModel:BlingAvatarModel;

		public function BlingAvatarAppController(constructorParams:AppControllerConstructorParams)
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
			_widgetView = new BlingAvatarButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new BlingAvatarFullView();
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
				_widgetView.init(this, blingAvatarModel, _collaborationLobbyNetConnectionService);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.init(this, blingAvatarModel, _collaborationLobbyNetConnectionService,
						_activeRecordAccount.accountId);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get blingAvatarModel():BlingAvatarModel
		{
			if (!_blingAvatarModel)
			{
				_blingAvatarModel = new BlingAvatarModel(_activeRecordAccount.primaryRecord);
			}
			return _blingAvatarModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as BlingAvatarButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as BlingAvatarFullView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return true;
		}
	}
}