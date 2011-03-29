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
package collaboRhythm.plugins.medications.controller
{
	import collaboRhythm.plugins.medications.model.MedicationsHealthRecordService;
	import collaboRhythm.plugins.medications.model.MedicationsModel;
	import collaboRhythm.plugins.medications.view.MedicationsWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.UIComponent;

	public class MedicationsAppController extends WorkstationAppControllerBase
	{
		public static const DEFAULT_NAME:String = "Medications";

		private var _widgetView:MedicationsWidgetView;
//		private var _fullView:MedicationsTimelineFullView;
		
		public function MedicationsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MedicationsWidgetView;
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
//			_fullView = value as MedicationsTimelineFullView;
//		}

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:MedicationsWidgetView = new MedicationsWidgetView();
			if (_user != null)
				newWidgetView.model = medicationsModel;
			return newWidgetView;
		}
		
//		protected override function createFullView():UIComponent
//		{
//			var newFullView:MedicationsFullView = new MedicationsFullView();
//			if (_user != null)
//				newFullView.model = _user.getAppData(MedicationsModel.MEDICATIONS_KEY, MedicationsModel) as MedicationsModel;
//			return newFullView;
//		}
		
		private function get medicationsModel():MedicationsModel
		{
			if (_user != null)
			{
				if (_user.appData[MedicationsModel.MEDICATIONS_KEY] == null)
				{
					_user.appData[MedicationsModel.MEDICATIONS_KEY] = new MedicationsModel(user);
				}
				return _user.getAppData(MedicationsModel.MEDICATIONS_KEY, MedicationsModel) as MedicationsModel;
			}
			return null;
		}

		public override function initialize():void
		{
			super.initialize();
			if (medicationsModel.initialized == false)
			{
				var medicationsHealthRecordService:MedicationsHealthRecordService = new MedicationsHealthRecordService(_healthRecordService.consumerKey, _healthRecordService.consumerSecret, _healthRecordService.baseURL);
				medicationsHealthRecordService.copyLoginResults(_healthRecordService);
				medicationsHealthRecordService.loadMedications(_user);
			}
			
			if (_widgetView)
				(_widgetView as MedicationsWidgetView).model = medicationsModel;
//			prepareFullView();
		}
		
//		protected override function prepareWidgetView():void
//		{
//			super.prepareWidgetView()();
//			if (_widgetView)
//				(_widgetView as MedicationsWidgetView).model = medicationsModel;
//		}
		
//		protected override function prepareFullView():void
//		{
//			super.prepareFullView();
//			if (_fullView)
//				(_fullView as MedicationsFullView).model = medicationsModel;
//		}
		
		public override function close():void
		{
			super.close();
		}

		override protected function removeUserData():void
		{
			user.appData[MedicationsModel.MEDICATIONS_KEY] = null;
		}

		override public function get defaultName():String
		{
			return DEFAULT_NAME;
		}
	}
}