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
package collaboRhythm.mobile.view.skins.supportClasses
{
import flash.display.Graphics;

import spark.core.SpriteVisualElement;

public class MenuButtonDown extends SpriteVisualElement
	{
		public function MenuButtonDown()
		{
			super();
		}
		
		/**
		 * Called during the validation pass by the Flex LayoutManager via
		 * the layout object.
		 * @param width
		 * @param height
		 * @param postLayoutTransform
		 * 
		 */
		override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void 
		{
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			//call our drawing function
			draw(width, height);
		}
		
		/**
		 * Draw the ruler 
		 * 
		 * TODO: logic to actually reuse commands and data if nothing has changed
		 * @param w width of ruler
		 * @param h height of ruler
		 * 
		 */
		protected function draw(w:Number, h:Number):void 
		{
			var g:Graphics = this.graphics;
			
			w = isNaN(w) ? this.width : w;
			h = (isNaN(h) ? this.height : h) - 1;
			
			//redraw
			g.clear();
			
			// TODO: draw a shadow (?) around the inner edge of the button
//			g.beginFill(
//			g.drawRect(0, 0, w, h);
//			g.endFill();
		}
	}
}