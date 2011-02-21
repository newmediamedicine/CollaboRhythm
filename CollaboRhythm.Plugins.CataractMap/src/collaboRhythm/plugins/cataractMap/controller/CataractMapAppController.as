/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.cataractMap.controller
{
	import collaboRhythm.plugins.cataractMap.model.CataractMapHealthRecordService;
	import collaboRhythm.plugins.cataractMap.model.CataractMapModel;
	import collaboRhythm.plugins.cataractMap.view.CataractMapFullView;
	import collaboRhythm.plugins.cataractMap.view.CataractMapWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class CataractMapAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:CataractMapWidgetView;
		private var _fullView:CataractMapFullView;

		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}

		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as CataractMapWidgetView;
		}
		
		public override function get isFullViewSupported():Boolean
		{
			return true;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as CataractMapFullView;
		}
		
		public function CataractMapAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}

//		override public function showWidget(left:Number=-1, top:Number=-1):void
//		{
//			// do nothing	
//		}
//
//		override protected function prepareWidgetView():void
//		{
//			// do nothing
//		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:CataractMapWidgetView = new CataractMapWidgetView();
			if (_user != null)
				newWidgetView.model = _user.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:CataractMapFullView = new CataractMapFullView();
			if (_user != null)
				newFullView.model = _user.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (_user.appData[CataractMapModel.CATARACT_MAP_KEY] == null)
			{
				loadCataractMapData();
			}
			if (_widgetView)
				_widgetView.model = _user.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
			
			prepareFullView();
		}
		
		protected function loadCataractMapData():void
		{
			var cataractMapHealthRecordService:CataractMapHealthRecordService = new CataractMapHealthRecordService(_healthRecordService.consumerKey, _healthRecordService.consumerSecret, _healthRecordService.baseURL);
			cataractMapHealthRecordService.copyLoginResults(_healthRecordService);
			cataractMapHealthRecordService.loadCataractMap(_user);
		}
		
		override protected function prepareFullView():void
		{
			super.prepareFullView();
			if (_fullView)
			{
				_fullView.model = _user.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
				_fullView.simulationView.initializeModel(_fullView.model.simulation, _fullView.model);
			}
		}

		override public function showWidgetAsDraggable(value:Boolean):void
		{
		}
		
		override public function showWidgetAsSelected(value:Boolean):void
		{
		}
		
		override public function reloadUserData():void
		{
			loadCataractMapData();
			if (_fullView)
			{
				_fullView.refresh();
				_fullView.simulationView.refresh();
			}
			if (_widgetView)
				_widgetView.refresh();
		}
		
		override protected function showFullViewComplete():void
		{
//			_fullView.simulationView.isRunning = true;
		}
		
		override protected function hideFullViewComplete():void
		{
//			_fullView.simulationView.isRunning = false;
		}
		
		override public function destroyViews():void
		{
//			if (_fullView)
//				_fullView.simulationView.isRunning = false;

			super.destroyViews();
		}

		public override function get defaultName():String
		{
			return "Cataract Map";
		}
		
		override protected function removeUserData():void
		{
			user.appData[CataractMapModel.CATARACT_MAP_KEY] = null;
		}
	}
}