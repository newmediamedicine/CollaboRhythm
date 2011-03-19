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
package collaboRhythm.plugins.equipment.controller
{
	import collaboRhythm.plugins.equipment.model.EquipmentHealthRecordService;
	import collaboRhythm.plugins.equipment.model.EquipmentModel;
	import collaboRhythm.plugins.equipment.view.EquipmentWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.UIComponent;
	
	public class EquipmentAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:EquipmentWidgetView;
		//		private var _fullView:EquipmentTimelineFullView;
		
		public function EquipmentAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as EquipmentWidgetView;
		}
		
		public override function get isFullViewSupported():Boolean
		{
			return false;
		}
		
		//		public override function get fullView():UIComponent
		//		{
		//			return _fullView;
		//		}
		//		
		//		public override function set fullView(value:UIComponent):void
		//		{
		//			_fullView = value as EquipmentTimelineFullView;
		//		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:EquipmentWidgetView = new EquipmentWidgetView();
			if (_user != null)
				newWidgetView.model = equipmentModel;
			return newWidgetView;
		}
		
		//		protected override function createFullView():UIComponent
		//		{
		//			var newFullView:EquipmentFullView = new EquipmentFullView();
		//			if (_user != null)
		//				newFullView.model = _user.getAppData(EquipmentModel.MEDICATIONS_KEY, EquipmentModel) as EquipmentModel;
		//			return newFullView;
		//		}
		
		private function get equipmentModel():EquipmentModel
		{
			if (_user != null)
			{
				if (_user.appData[EquipmentModel.EQUIPMENT_KEY] == null)
				{
					_user.appData[EquipmentModel.EQUIPMENT_KEY] = new EquipmentModel(user);
				}
				return _user.getAppData(EquipmentModel.EQUIPMENT_KEY, EquipmentModel) as EquipmentModel;
			}
			return null;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (equipmentModel.initialized == false)
			{
				var equipmentHealthRecordService:EquipmentHealthRecordService = new EquipmentHealthRecordService(_healthRecordService.consumerKey, _healthRecordService.consumerSecret, _healthRecordService.baseURL);
				equipmentHealthRecordService.copyLoginResults(_healthRecordService);
				equipmentHealthRecordService.loadEquipment(_user);
			}
			
			if (_widgetView)
				(_widgetView as EquipmentWidgetView).model = equipmentModel;
			//			prepareFullView();
		}
		
		//		protected override function prepareWidgetView():void
		//		{
		//			super.prepareWidgetView()();
		//			if (_widgetView)
		//				(_widgetView as EquipmentWidgetView).model = equipmentModel;
		//		}
		
		//		protected override function prepareFullView():void
		//		{
		//			super.prepareFullView();
		//			if (_fullView)
		//				(_fullView as EquipmentFullView).model = equipmentModel;
		//		}
		
		public override function close():void
		{
			super.close();
		}
		
		override protected function removeUserData():void
		{
			user.appData[EquipmentModel.EQUIPMENT_KEY] = null;
		}
	}
}