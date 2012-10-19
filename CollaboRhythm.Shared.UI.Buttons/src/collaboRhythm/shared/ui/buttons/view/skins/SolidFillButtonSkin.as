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

package collaboRhythm.shared.ui.buttons.view.skins
{
	import mx.core.mx_internal;

	use namespace mx_internal;

	public class SolidFillButtonSkin extends TransparentButtonSkin
	{
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var chromeColor:uint = getStyle(fillColorStyleName);
			var chromeAlpha:Number = 1;

			graphics.beginFill(chromeColor, chromeAlpha);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
		}
	}
}