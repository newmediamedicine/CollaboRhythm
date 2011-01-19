////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product. If you have received this file from a source
//  other than Adobe, then your use, modification, or distribution of this file
//  requires the prior written permission of Adobe.
//
////////////////////////////////////////////////////////////////////////////////

package com.dougmccune.skins
{

import mx.skins.Border;
import flash.events.*;
import mx.managers.*;
/**
 *  The skin for the highlighted state of the track of a Slider.
 */
public class SliderHighlightSkin extends Border
{
	//include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 *  Constructor.
	 */
	public function SliderHighlightSkin()
	{
		//super();
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
	 *  The preferred width of this object.
	 */
	override public function get measuredWidth():Number
	{
		return 1;
	}

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  The preferred height of this object.
	 */
	override public function get measuredHeight():Number
	{
		return 2;
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

		var themeColor:int = getStyle("themeColor");
		
		graphics.clear();
		
		
		// Highlight
		drawRoundRect(
			0, h/2, w, 1, 0,
			themeColor, 0.7);
		drawRoundRect(
			0, h/2 - 1, w, 1, 0,
			themeColor, 1);
		drawRoundRect(
			0, h/2 - 2, w, 1, 0,
			themeColor, 0.4);
	}
	
	
}

}
