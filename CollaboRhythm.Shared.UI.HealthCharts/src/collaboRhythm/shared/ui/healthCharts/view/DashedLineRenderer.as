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
package collaboRhythm.shared.ui.healthCharts.view
{
	import mx.charts.renderers.LineRenderer;
	import mx.graphics.IStroke;

	public class DashedLineRenderer extends LineRenderer
	{
		private var _lineSegment:Object;
		private var _pattern:Array = [10,15];

		public function DashedLineRenderer() {
			super();
		}
				
		[Inspectable(environment="none")]
		override public function get data():Object
		{
			return _lineSegment;
		}

		override public function set data(value:Object):void
		{
			_lineSegment = value;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			var stroke:IStroke = getStyle("lineStroke");		
			var form:String = getStyle("form");
			var pattern:Array = getStyle("dashingPattern");
			pattern = (pattern == null) ? _pattern : pattern;
			
			graphics.clear();
	
			DashedGraphicUtilities.drawDashedPolyLine(graphics, stroke, pattern, _lineSegment.items);
		}
	}
}