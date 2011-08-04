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
package collaboRhythm.plugins.diary.controller
{

import collaboRhythm.plugins.diary.model.DiaryModel;
	import collaboRhythm.plugins.diary.view.DiaryButtonWidgetView;
	import collaboRhythm.plugins.diary.view.DiaryFullView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

import mx.core.UIComponent;

	public class DiaryAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Diary";

		private var _diaryModel:DiaryModel;
		private var _widgetView:DiaryButtonWidgetView;
		private var _fullView:DiaryFullView;

		public function DiaryAppController(constructorParams:AppControllerConstructorParams)
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
			_widgetView = new DiaryButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new DiaryFullView();
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
				_widgetView.init(this, diaryModel);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.init(this, diaryModel);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get diaryModel():DiaryModel
		{
			if (!_diaryModel)
			{
				_diaryModel = new DiaryModel();
			}
			return _diaryModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as DiaryButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as DiaryFullView;
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

		protected override function removeUserData():void
		{
			_diaryModel = null;
		}
        public function closeDiaryEntry():void{
            hideFullView();
        }

/*
        public function diaryPusherFunction():void {
            var numberOfEntries:Number = _diaryModel.diaryEntries.length;
            var diaryEntriesInfo:SharedObject = SharedObject.getLocal('diaryInfo');
            diaryEntriesInfo.data.numberOfEntries = numberOfEntries;
            for (var i:Number = 0; i < _diaryModel.diaryEntries.length; i++) {
                var hostName:String = "diaryEntry" + i;
                var date:Date = _diaryModel.diaryEntries[i].date;
                var text:String = _diaryModel.diaryEntries[i].text;
                var sharedInfo:SharedObject = SharedObject.getLocal(hostName);
                sharedInfo.data.date = date;
                sharedInfo.data.text = text;
                trace(sharedInfo.data.date = date);
                trace(sharedInfo.data.text = text);
                trace(diaryEntriesInfo.data.numberOfEntries)
            }
        }
*/
	}
}
