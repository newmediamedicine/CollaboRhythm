////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package embed_assets.ui.skins
{

import flash.display.GradientType;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 * This is a modified version of the default mx.skins.halo.ScrollTrackSkin
 * that uses a single border color.
 * 
 * NOTE: This skin has also been tweaked to not draw its right, top, or bottom border in 
 *       order to match the visual design exactly.
 */
public class SimpleScrollTrackSkin extends Border
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SimpleScrollTrackSkin()
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
        return 1;
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

		// User-defined styles.
		var fillColors:Array = getStyle("trackColors");
		styleManager.getColorNames(fillColors);
		
		var borderColor:uint = getStyle("borderColor");
			
		graphics.clear();
		
		// border
		drawRoundRect(
			0, 0, w, h, 0,
			borderColor, 1,
			verticalGradientMatrix(0, 0, w, h),
			GradientType.LINEAR, null,
			{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }); 
		// fill
		drawRoundRect(
			1, 0, w - 1, h, 0,
			fillColors, 1, 
			horizontalGradientMatrix(1, 1, w / 3 * 2, h - 2)); 
		
		// draw the top-bottom lines like the fill over the border
		//drawRoundRect( 1, 0, w-2, 1, 0, fillColors[0], 1 );
		//drawRoundRect( 1, h-1, w-2, 1, 0, fillColors[0], 1 );
	}
}

}
