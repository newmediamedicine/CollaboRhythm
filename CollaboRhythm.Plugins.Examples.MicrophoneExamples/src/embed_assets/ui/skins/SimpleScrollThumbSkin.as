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
package embed_assets.ui.skins
{

import flash.display.GradientType;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;
import flash.display.DisplayObject;
import mx.core.UIComponent;

/**
 *  The skin for all the states of the thumb in a ScrollBar.
 * 
 * NOTE: In order to match the visual design, we 
 *       
 */
public class SimpleScrollThumbSkin extends UIComponent
{

	private var thumbIcon : DisplayObject;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SimpleScrollThumbSkin()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	 /**
     *  @private
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        // Create the thumb icon
        if (!thumbIcon)
        {
            var thumbIconClass:Class = getStyle("thumbIcon");
            thumbIcon = new thumbIconClass();
            addChild(thumbIcon);
        }
    }


	//----------------------------------
	//  measuredWidth
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		return 16;
	}
	
	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return 10;
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

		// This will make the thumb overlap the component by a pixel
		w++;
		
		// User-defined styles.
		var borderColor:uint = getStyle("thumbBorderColor");
		var fillColor:uint = getStyle("thumbFillColor");
		var overFillColor:uint = getStyle("thumbOverFillColor");
		
		
		graphics.clear();
		
		switch (name)
		{
			default:
			case "thumbUpSkin":
			{
				drawRoundRect( 0, 0, w, h, 0, borderColor, 1 );
				drawRoundRect( 1, 1, w - 2, h - 2, 0, fillColor, 1 );
				
				break;
			}
			
			case "thumbOverSkin":
			case "thumbDownSkin":
			{
				drawRoundRect( 0, 0, w, h, 0, borderColor, 1 );
				drawRoundRect( 1, 1, w - 2, h - 2, 0, overFillColor, 1 );
				break;
			}
			
		}
	
		thumbIcon.x = ( w - thumbIcon.width ) / 2;
		thumbIcon.y = ( h - thumbIcon.height ) / 2;
	}
}
}