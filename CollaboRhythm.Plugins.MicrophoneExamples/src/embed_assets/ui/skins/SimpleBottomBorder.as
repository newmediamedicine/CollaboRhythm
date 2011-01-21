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

import flash.display.Graphics;

import mx.core.EdgeMetrics;
import mx.core.mx_internal;
import mx.skins.ProgrammaticSkin;

use namespace mx_internal;

/**
 * This is a modified version of the halo border that allows us to have a simple,
 * square border with two different colors. 
 */
public class SimpleBottomBorder extends ProgrammaticSkin
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SimpleBottomBorder() 
	{
		super(); 
	}

	//--------------------------------------------------------------------------
	//
	//  Fields
	//
	//--------------------------------------------------------------------------
		
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------


	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Draw the border, either 3D or 2D or nothing at all.
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{	
		if (isNaN(w) || isNaN(h))
			return;
			
		super.updateDisplayList(w, h);

		drawBorder(w,h);		
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	mx_internal function drawBorder(w:Number, h:Number):void
	{
		var borderColor : int = getStyle("borderColor");		
		var borderThickness : Number = getStyle("borderThickness");
	
		var g:Graphics = graphics;
		g.clear();
									
		g.lineStyle(borderThickness, borderColor);
		g.moveTo(0, h);
		g.lineTo(x, h);	

	}
}

}
