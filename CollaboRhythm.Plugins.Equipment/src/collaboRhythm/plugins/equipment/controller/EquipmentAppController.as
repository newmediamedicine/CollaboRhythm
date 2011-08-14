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

	import collaboRhythm.plugins.equipment.view.EquipmentWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentModel;

	import mx.core.UIComponent;

	public class EquipmentAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Equipment";

		private var _widgetView:EquipmentWidgetView;

		public function EquipmentAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		override protected function createWidgetView():UIComponent
		{
			_widgetView = new EquipmentWidgetView();
			return _widgetView
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
				_widgetView.init(_activeRecordAccount.primaryRecord.equipmentModel);
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
			_widgetView = value as EquipmentWidgetView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return false;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}
	}
}