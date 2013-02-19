////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package collaboRhythm.tablet.view.skins
{
import flash.display.GradientType;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.IconPlacement;
	import spark.skins.mobile.ButtonSkin;
	import spark.skins.mobile.assets.ViewMenuItem_down;
import spark.skins.mobile.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile.assets.ViewMenuItem_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile320.assets.ViewMenuItem_down;
import spark.skins.mobile320.assets.ViewMenuItem_showsCaret;
import spark.skins.mobile320.assets.ViewMenuItem_up;

use namespace mx_internal;

/**
 *  Tablet skin for ViewMenuItem. Supports a label, icon and iconPlacement and draws a background.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */ 
public class TabletViewMenuItemSkin extends ButtonSkin
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabletViewMenuItemSkin()
    {
        super();
        
		layoutBorderSize = 0;

		upBorderSkin = Invisible;
    	downBorderSkin = Invisible;
		showsCaretBorderSkin = Invisible;
		useCenterAlignment = false;

        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                layoutGap = 12;
                layoutPaddingLeft = 24;
                layoutPaddingRight = 12;
                layoutPaddingTop = 12;
                layoutPaddingBottom = 12;

                break;
            }
            case DPIClassification.DPI_240:
            {   
                layoutGap = 8;
                layoutPaddingLeft = 16;
                layoutPaddingRight = 8;
                layoutPaddingTop = 8;
                layoutPaddingBottom = 8;

                break;
                
            }
            default:
            {
                layoutGap = 6;
                layoutPaddingLeft = 12;
                layoutPaddingRight = 6;
                layoutPaddingTop = 6;
                layoutPaddingBottom = 6;
            }
        }
    }


	override protected function createChildren():void
	{
		super.createChildren();
		setStyle("textAlign", "left");
	}

    /**
     *  Class to use for the border in the showsCaret state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     *       
     *  @default Button_down
     */ 
    protected var showsCaretBorderSkin:Class;
    
    /**
     *  @private
     */
    override protected function getBorderClassForCurrentState():Class
    {
        var borderClass:Class = super.getBorderClassForCurrentState();
        
        if (currentState == "showsCaret")
            borderClass = showsCaretBorderSkin;  
        
        return borderClass;
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit call to super.drawBackground(), drawRect instead
        
        if (currentState == "showsCaret" || currentState == "down")
        {
            graphics.beginFill(getStyle("focusColor"));
        }
        else
        {
			graphics.beginFill(getStyle("chromeColor"));
        }
        
        graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
        graphics.endFill();
    }
}
}