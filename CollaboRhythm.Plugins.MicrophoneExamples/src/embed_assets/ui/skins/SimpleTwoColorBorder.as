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
import flash.display.Graphics;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.FlexVersion;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.graphics.RectangularDropShadow;
import mx.skins.RectangularBorder;
import mx.styles.IStyleClient;
import mx.utils.ColorUtil;
import mx.graphics.GradientEntry;
import mx.skins.Border;

use namespace mx_internal;

/**
 * This is a modified version of the halo border that allows us to have a simple,
 * square border with two different colors. 
 */
public class SimpleTwoColorBorder extends RectangularBorder
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SimpleTwoColorBorder() 
	{
		super(); 
	}

	//--------------------------------------------------------------------------
	//
	//  Fields
	//
	//--------------------------------------------------------------------------
	

	mx_internal var backgroundColor:Object;	
	mx_internal var backgroundAlphaName:String; 
	
	/**
	 *  @private
	 *  A reference to the object used to cast a drop shadow.
	 *  See the drawDropShadow() method for details.
	 */	 
	private var dropShadow:RectangularDropShadow;
	
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  borderMetrics
	//----------------------------------

	/**
	 *  @private
	 *  Internal object that contains the thickness of each edge
	 *  of the border
	 */
	protected var _borderMetrics:EdgeMetrics;

	/**
	 *  @private
	 *  Return the thickness of the border edges.
	 *
	 *  @return Object	top, bottom, left, right thickness in pixels
	 */
	override public function get borderMetrics():EdgeMetrics
	{		
		if (_borderMetrics)
			return _borderMetrics;
			
		var borderThickness:Number = getStyle("borderThickness");
		_borderMetrics = new EdgeMetrics( borderThickness, borderThickness, borderThickness, borderThickness );

		return _borderMetrics;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  If borderStyle may have changed, clear the cached border metrics.
	 */
	override public function styleChanged(styleProp:String):void
	{
		if (styleProp == null ||
			styleProp == "styleName" ||
			styleProp == "borderStyle" ||
			styleProp == "borderThickness")
		{
			_borderMetrics = null;
		}
		
		invalidateDisplayList();
	}

	/**
	 *  @private
	 *  Draw the border, either 3D or 2D or nothing at all.
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{	
		if (isNaN(w) || isNaN(h))
			return;
			
		super.updateDisplayList(w, h);

		// Store background color in an object,
		// so that null is distinct from black.
		backgroundColor = getBackgroundColor();
		
		backgroundAlphaName = "backgroundAlpha";

		drawBorder(w,h);		
		drawBackground(w,h);
		drawDropShadow(0, 0, w, h, 0, 0, 0, 0);
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
		var outerBorderColor : int = getStyle( "outerBorderColor" );
		var borderThickness : Number = getStyle("borderThickness");
		var borderStyle : String = getStyle( "borderStyle" );
	
		var g:Graphics = graphics;
		g.clear();
		
		if ( borderStyle == "none" )
			return;
	
		if ( borderThickness <= 1 || isNaN( outerBorderColor) )
		{							
			g.beginFill(borderColor);
			g.drawRect(0, 0, w, h);
			g.endFill();	
		}
		else
		{	
			
			var half : Number = Math.floor( borderThickness / 2 );
			g.beginFill(outerBorderColor);
			g.drawRect(0, 0, w, h );
			g.endFill();
			
			g.beginFill(borderColor);
			g.drawRect( half, half, w - 2 * half, h - 2 * half );
			g.endFill();		
		}

	}


	/**
	 *  @private
	 */
	mx_internal function drawBackground(w:Number, h:Number):void
	{
		// The behavior used to be that we always create a background
		// regardless of whether we have a background color or not.
		// Now we only create a background if we have a color
		// or if the mouseShield or mouseShieldChildren styles are true.
		// Look at Container.addEventListener and Container.isBorderNeeded
		// for the mouseShield logic. JCS 6/24/05
		if ((backgroundColor !== null &&
		     backgroundColor !== "") ||
			getStyle("mouseShield") ||
			getStyle("mouseShieldChildren"))
		{
			var nd:Number = Number(backgroundColor);
			var alpha:Number = 1.0;
			var bm:EdgeMetrics = getBackgroundColorMetrics();
			var g:Graphics = graphics;
			
			if (isNaN(nd) ||
				backgroundColor === "" ||
				backgroundColor === null)
			{
				alpha = 0;
				nd = 0xFFFFFF;
			}
			else
			{
				alpha = getStyle(backgroundAlphaName);
			}

			
			g.beginFill(nd, alpha);
			g.drawRect(bm.left, bm.top,
					   w - bm.right - bm.left, h - bm.bottom - bm.top);
			g.endFill();
		}
		

	}

	/**
	 *  @private
	 *  Apply a drop shadow using a bitmap filter.
	 *
	 *  Bitmap filters are slow, and their slowness is proportional
	 *  to the number of pixels being filtered.
	 *  For a large HaloBorder, it's wasteful to create a big shadow.
	 *  Instead, we'll create the shadow offscreen
	 *  and stretch it to fit the HaloBorder.
	 */
	mx_internal function drawDropShadow(x:Number, y:Number, 
									width:Number, height:Number,
									tlRadius:Number, trRadius:Number, 
									brRadius:Number, blRadius:Number):void
	{
		// Do I need a drop shadow in the first place?  If not, return
		// immediately.
		if (getStyle("dropShadowEnabled") == false || 
		    getStyle("dropShadowEnabled") == "false" ||
			width == 0 || 
			height == 0)
		{
			return;
		}

		// Calculate the angle and distance for the shadow
		var distance:Number = getStyle("shadowDistance");
		var direction:String = getStyle("shadowDirection");
		var angle:Number;	
			
		angle = getDropShadowAngle(distance, direction);
		distance = Math.abs(distance) + 2;
		
		// Create a RectangularDropShadow object, set its properties,
		// and draw the shadow
		if (!dropShadow)
			dropShadow = new RectangularDropShadow();

		dropShadow.distance = distance;
		dropShadow.angle = angle;
		dropShadow.color = getStyle("dropShadowColor");
		dropShadow.alpha = 0.4;

		dropShadow.tlRadius = tlRadius;
		dropShadow.trRadius = trRadius;
		dropShadow.blRadius = blRadius;
		dropShadow.brRadius = brRadius;

		dropShadow.drawShadow(graphics, x, y, width, height);
	}

	/**
	 *  @private
	 *  Convert the value of the shadowDirection property
	 *  into a shadow angle.
	 */
	mx_internal function getDropShadowAngle(distance:Number,
										direction:String):Number
	{
		if (direction == "left")
			return distance >= 0 ? 135 : 225;

		else if (direction == "right")
			return distance >= 0 ? 45 : 315;
		
		else // direction == "center"
			return distance >= 0 ? 90 : 270;
	}
	

	/**
	 *  @private
	 */
	mx_internal function getBackgroundColor():Object
	{
		var p:IUIComponent = parent as IUIComponent;
		if (p && !p.enabled)
		{
			var color:Object = getStyle("backgroundDisabledColor");
			if (color)
				return color;
		}

		return getStyle("backgroundColor");
	}
	
	/**
	 *  @private
	 */
	mx_internal function getBackgroundColorMetrics():EdgeMetrics
	{
		return borderMetrics;
	}
}

}
