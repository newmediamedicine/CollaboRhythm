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
	import collaboRhythm.shared.ui.buttons.view.skins320.TransparentButton_up;

	import mx.core.DPIClassification;
	import mx.core.mx_internal;

	import spark.skins.mobile.supportClasses.ActionBarButtonSkinBase;

	use namespace mx_internal;

	/**
	 *  The default skin class for buttons in the navigation area of the Spark ActionBar component
	 *  in mobile applications.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	public class TransparentButtonSkin extends ActionBarButtonSkinBase
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
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 *
		 */
		public function TransparentButtonSkin()
		{
			super();

			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					layoutBorderSize = 1;
					layoutPaddingTop = 12;
					layoutPaddingBottom = 10;
					layoutPaddingLeft = 20;
					layoutPaddingRight = 20;
					measuredDefaultWidth = 20;
					measuredDefaultHeight = 20;

					break;
				}
				case DPIClassification.DPI_240:
				{
					layoutBorderSize = 1;
					layoutPaddingTop = 9;
					layoutPaddingBottom = 8;
					layoutPaddingLeft = 16;
					layoutPaddingRight = 16;
					measuredDefaultWidth = 20;
					measuredDefaultHeight = 20;

					break;
				}
				default:
				{
					// default DPI_160
					layoutBorderSize = 1;
					layoutPaddingTop = 6;
					layoutPaddingBottom = 5;
					layoutPaddingLeft = 10;
					layoutPaddingRight = 10;
					measuredDefaultWidth = 20;
					measuredDefaultHeight = 20;

					break;
				}
			}

			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					upBorderSkin = collaboRhythm.shared.ui.buttons.view.skins320.TransparentButton_up;
					downBorderSkin = collaboRhythm.shared.ui.buttons.view.skins320.TransparentButton_down;

					break;
				}
				default:
				{
					upBorderSkin = collaboRhythm.shared.ui.buttons.view.skins.TransparentButton_up;
					downBorderSkin = TransparentButton_down;

					break;
				}
			}
		}

		override mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// trailing vertical separator is outside the right bounds of the button
			setElementSize(border, unscaledWidth + layoutBorderSize, unscaledHeight);
			setElementPosition(border, 0, 0);
		}

		private function initializeLayoutFromStyles():void
		{
			var paddingLeft:Number = getStyle("paddingLeft");
			if (!isNaN(paddingLeft)) layoutPaddingLeft = paddingLeft;
			var paddingRight:Number = getStyle("paddingRight");
			if (!isNaN(paddingRight)) layoutPaddingRight = paddingRight;
			var paddingTop:Number = getStyle("paddingTop");
			if (!isNaN(paddingTop)) layoutPaddingTop = paddingTop;
			var paddingBottom:Number = getStyle("paddingBottom");
			if (!isNaN(paddingBottom)) layoutPaddingBottom = paddingBottom;
		}

		override public function styleChanged(styleProp:String):void
		{
			if (styleProp == "paddingLeft")
			{
				var paddingLeft:Number = getStyle("paddingLeft");
				if (!isNaN(paddingLeft)) layoutPaddingLeft = paddingLeft;
				invalidateDisplayList();
			}
			if (styleProp == "paddingRight")
			{
				var paddingRight:Number = getStyle("paddingRight");
				if (!isNaN(paddingRight)) layoutPaddingRight = paddingRight;
				invalidateDisplayList();
			}
			if (styleProp == "paddingTop")
			{
				var paddingTop:Number = getStyle("paddingTop");
				if (!isNaN(paddingTop)) layoutPaddingTop = paddingTop;
				invalidateDisplayList();
			}
			if (styleProp == "paddingBottom")
			{
				var paddingBottom:Number = getStyle("paddingBottom");
				if (!isNaN(paddingBottom)) layoutPaddingBottom = paddingBottom;
				invalidateDisplayList();
			}

			super.styleChanged(styleProp);
		}

		override protected function measure():void
		{
			initializeLayoutFromStyles();
			super.measure();
		}

		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			initializeLayoutFromStyles();
			super.layoutContents(unscaledWidth, unscaledHeight);
		}
	}
}