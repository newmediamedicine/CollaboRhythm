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

	import collaboRhythm.plugins.videoMessages.view.VideoMessagesButtonWidgetView;
	import collaboRhythm.plugins.videoMessages.view.VideoMessagesFullView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.shared.model.VideoMessage;
	import collaboRhythm.shared.model.VideoMessagesModel;

	import mx.core.UIComponent;

	public class VideoMessagesAppController extends WorkstationAppControllerBase
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
			if (!_fullView)
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
			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, videoMessagesModel);
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
			return true;
		}

		public function dispatchShowFullView():void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this));
		}

		public function deleteVideoMessage(videoMessage:VideoMessage):void
		{
			videoMessagesModel.deleteVideoMessage(videoMessage);
		}

		protected override function removeUserData():void
		{
			_videoMessagesModel = null;
		}
	}
}
