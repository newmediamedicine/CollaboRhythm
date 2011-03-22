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
package collaboRhythm.mobile.view.skins
{
import collaboRhythm.mobile.view.skins.supportClasses.MenuButtonDown;
import collaboRhythm.mobile.view.skins.supportClasses.MenuButtonUp;

import spark.skins.mobile.ButtonSkin;

public class MenuButtonSkin extends ButtonSkin
	{
		public function MenuButtonSkin()
		{
			super();
			gap = 0;
			paddingBottom = paddingLeft = paddingRight = paddingTop = 2;
			upBorderSkin = MenuButtonUp;
			downBorderSkin = MenuButtonDown;
			
			setStyle("iconPlacement", "top");
			setStyle("cornerRadius", 0);
			setStyle("fontSize", 20);
			setStyle("fontWeight", "normal");
			setStyle("chromeColor", 0x000000);
		}

		/**
		 *  Draws the background of the skin. Override this function to change the background. 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 *       
		 *  @default Button_down
		 */ 
		protected override function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.clear();
			
			var chromeColor:uint = getStyle("chromeColor");

			if (currentState == "down")
				graphics.beginFill(0x00FF00, 0.8);
			else
				graphics.beginFill(chromeColor, 0.8);
			
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
		}
		
		/**
		 *  Called whenever the currentState changes. Skins should override
		 *  this function if they make any appearance changes during 
		 *  a state change
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5 
		 *  @productversion Flex 4.5
		 */ 
		protected override function commitCurrentState():void
		{
//			trace("MenuButtonSkin commitCurrentState", currentState);
			
			super.commitCurrentState();
			
			// TODO: instead of hard-coded colors, get the appropriate colors from somewhere
			if (currentState == "down")
				this.setStyle("color", 0x000000);
			else
				this.setStyle("color", 0xFFFFFF);
		}
	}
}