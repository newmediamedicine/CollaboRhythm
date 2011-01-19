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
package com.dougmccune.skins
{
	import mx.skins.Border;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 *  The skin for a ProgressBar.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class GreenProgressBarSkin extends Border
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function GreenProgressBarSkin()
		{
			super();		
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  measuredWidth
		//----------------------------------
		
		/**
		 *  @private
		 */    
		override public function get measuredWidth():Number
		{
			return 200;
		}
		
		//----------------------------------
		//  measuredHeight
		//----------------------------------
		
		/**
		 *  @private
		 */        
		override public function get measuredHeight():Number
		{
			return 6;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */        
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			
			
			// User-defined styles
			var barColorStyle:* = getStyle("barColor");
			var barColor:uint = styleManager.isValidStyleValue(barColorStyle) ?
				barColorStyle :
				getStyle("themeColor");
			
			barColor = 0x00AA00;
			var barColor0:Number = ColorUtil.adjustBrightness2(barColor, 40);
			
			// default fill color for halo uses theme color
			var fillColors:Array = [ barColor0, barColor ]; 
			
			graphics.clear();
			
			// glow
			drawRoundRect(
				0, 0, w, h, 0,
				fillColors, 0.5,
				verticalGradientMatrix(0, 0, w - 2, h - 2));
			
			// fill
			drawRoundRect(
				1, 1, w - 2, h - 2, 0,
				fillColors, 1,
				verticalGradientMatrix(0, 0, w - 2, h - 2));
		}
	}
}