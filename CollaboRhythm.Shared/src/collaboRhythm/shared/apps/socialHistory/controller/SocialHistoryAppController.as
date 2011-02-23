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
package collaboRhythm.shared.apps.socialHistory.controller
{
//	import collaboRhythm.workstation.apps.socialHistory.view.SocialHistoryFullView;
	import collaboRhythm.shared.apps.socialHistory.view.SocialHistoryWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class SocialHistoryAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:SocialHistoryWidgetView;
//		private var _fullView:SocialHistoryFullView;
				
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as SocialHistoryWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as SocialHistoryFullView;
//		}
		
		public function SocialHistoryAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new SocialHistoryWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new SocialHistoryFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.socialHistory == null)
//			{
//				_healthRecordService.loadSocialHistory(_sharedUser);
//			}
//			(_widgetView as SocialHistoryWidgetView).model = _sharedUser.socialHistory;
//			_fullView.model = _sharedUser.socialHistory;
		}
	}
}