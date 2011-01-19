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
package collaboRhythm.workstation.apps.medications.controller
{
	import collaboRhythm.workstation.apps.medications.view.MedicationsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;

	import flash.display.DisplayObject;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class MedicationsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:MedicationsWidgetView;
//		private var _fullView:MedicationsTimelineFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MedicationsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as MedicationsTimelineFullView;
//		}
		
		public function MedicationsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:MedicationsWidgetView = new MedicationsWidgetView();
			if (_user != null)
				newWidgetView.model = _user.medicationsModel;
			return newWidgetView;
		}
		
//		protected override function createFullView():UIComponent
//		{
//			var newFullView:MedicationsTimelineFullView = new MedicationsTimelineFullView();
//			if (_user != null)
//				newFullView.initializeControllerModel(null, _user.medicationsModel);
//			return newFullView;
//		}

		public override function initialize():void
		{
			super.initialize();
			if (!_user.medicationsModel.initialized && !_user.medicationsModel.isLoading)
			{
				_healthRecordService.loadMedications(_user);
			}
			(_widgetView as MedicationsWidgetView).model = _user.medicationsModel;
		}
		
		public override function close():void
		{
			super.close();
		}
	}
}