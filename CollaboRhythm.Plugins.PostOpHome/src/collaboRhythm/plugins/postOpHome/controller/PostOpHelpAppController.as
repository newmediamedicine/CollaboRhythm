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
package collaboRhythm.plugins.postOpHome.controller
{
	import collaboRhythm.plugins.postOpHome.model.PostOpHomeModel;
	import collaboRhythm.plugins.postOpHome.view.PostOpHelpButtonWidgetView;
	import collaboRhythm.plugins.postOpHome.view.PostOpHelpView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;

	import mx.core.UIComponent;

	import spark.transitions.SlideViewTransition;

	public class PostOpHelpAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "PostOpHelp";

		private var _widgetView:PostOpHelpButtonWidgetView;
		private var _fullView:PostOpHelpView;

		private var _postOpHomeModel:PostOpHomeModel;

		public function PostOpHelpAppController(constructorParams:AppControllerConstructorParams)
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
			_widgetView = new PostOpHelpButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new PostOpHelpView();
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


		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as PostOpHelpButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as PostOpHelpView;
		}

		private function get postOpHomeModel():PostOpHomeModel
		{
			if (!_postOpHomeModel)
			{
				_postOpHomeModel = new PostOpHomeModel(_activeRecordAccount.primaryRecord, activeAccount.accountId);
			}
			return _postOpHomeModel;
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
