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
package collaboRhythm.plugins.videoMessages.controller
{

    import collaboRhythm.plugins.videoMessages.view.PlayVideoMessageView;
    import collaboRhythm.plugins.videoMessages.view.VideoMessagesButtonWidgetView;
    import collaboRhythm.plugins.videoMessages.view.VideoMessagesFullView;
    import collaboRhythm.shared.controller.apps.AppControllerBase;
    import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
    import collaboRhythm.shared.controller.apps.AppEvent;
    import collaboRhythm.shared.model.InteractionLogUtil;
    import collaboRhythm.shared.model.healthRecord.DocumentBase;
    import collaboRhythm.shared.model.healthRecord.document.VideoMessage;
    import collaboRhythm.shared.model.healthRecord.document.VideoMessagesModel;

    import mx.core.UIComponent;

    import spark.transitions.SlideViewTransition;

    public class VideoMessagesAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "VideoMessages";

		private var _widgetView:VideoMessagesButtonWidgetView;
		private var _fullView:VideoMessagesFullView;

		private var _videoMessagesModel:VideoMessagesModel;

		public function VideoMessagesAppController(constructorParams:AppControllerConstructorParams)
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
			_widgetView = new VideoMessagesButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new VideoMessagesFullView();
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
				_widgetView.init(this, videoMessagesModel, _collaborationLobbyNetConnectionService);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.init(this, videoMessagesModel, _collaborationLobbyNetConnectionService, _activeRecordAccount.accountId);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get videoMessagesModel():VideoMessagesModel
		{
			if (!_videoMessagesModel)
			{
				_videoMessagesModel = _activeRecordAccount.primaryRecord.videoMessagesModel;
			}
			return _videoMessagesModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as VideoMessagesButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as VideoMessagesFullView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		public function deleteVideoMessage(videoMessage:VideoMessage):void
		{
			videoMessagesModel.removeDocumentFromRecord(videoMessage, DocumentBase.ACTION_VOID, "deleted by user");
			_fullView.setFocus();
			if (_videoMessagesModel.videoMessagesCollection.length == 0)
			{
				//TODO: Potentially hideFullViews() in the AppControllersMediate is more appropriate
				if (hideFullView())
					InteractionLogUtil.logAppInstance(_logger, "Hide full view", "delete last video message", this);

				goBack();
			}
		}

		public function markVideoMessageRead(videoMessage:VideoMessage):void
		{
			var readCount:int = int(videoMessage.subject) + 1;
			videoMessage.subject = readCount.toString();
			videoMessage.pendingAction = DocumentBase.ACTION_UPDATE;
		}

		protected override function removeUserData():void
		{
			_videoMessagesModel = null;
		}

		public function goBack():void
		{
			videoMessagesModel.saveAllChanges();
		}

        public function playVideoMessageFullScreen(videoMessage:VideoMessage):void
        {
            if (_viewNavigator)
                _viewNavigator.pushView(PlayVideoMessageView, videoMessage, new SlideViewTransition());
        }
    }
}
