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
package collaboRhythm.plugins.examples.microphoneExamples.controller
{
	import collaboRhythm.plugins.examples.microphoneExamples.model.MicrophoneExamplesModel;
	import collaboRhythm.plugins.examples.microphoneExamples.view.MicrophoneExamplesWidgetView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class MicrophoneExamplesAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:MicrophoneExamplesWidgetView;
//		private var _fullView:MicrophoneExamplesFullView;
		private var _model:MicrophoneExamplesModel = new MicrophoneExamplesModel();
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MicrophoneExamplesWidgetView;
		}
		
		public function MicrophoneExamplesAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:MicrophoneExamplesWidgetView = new MicrophoneExamplesWidgetView();
			newWidgetView.model = _model;
			return newWidgetView;
		}
	}
}