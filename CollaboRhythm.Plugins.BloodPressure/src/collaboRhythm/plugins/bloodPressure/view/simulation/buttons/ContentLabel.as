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
package collaboRhythm.plugins.bloodPressure.view.simulation.buttons
{

	import collaboRhythm.plugins.bloodPressure.view.simulation.*;
	import collaboRhythm.plugins.bloodPressure.view.simulation.buttons.ContentButtonSkin;

	import collaboRhythm.plugins.bloodPressure.view.simulation.buttons.ContentLabelSkin;

	import flash.events.Event;

	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.BitFlagUtil;

	import spark.components.Button;
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.IDisplayText;
	import spark.layouts.supportClasses.LayoutBase;

	use namespace mx_internal;

	/**
	 *  @copy flashx.textLayout.formats.ITextLayoutFormat#color
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="color", type="uint", format="Color", inherit="yes")]

	/**
	 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontSize
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="fontSize", type="Number", format="Length", inherit="yes", minValue="1.0", maxValue="720.0")]

	/**
	 *  The radius of the corners of this component.
	 *
	 *  @default 4
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark", minValue="0.0")]

	public class ContentLabel extends SkinnableComponent implements IDisplayText
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected static const CONTENT_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		protected static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		protected static const LEFT_GROUP_PROPERTIES_INDEX:uint = 0;
		
		/**
		 *  @private
		 */
		protected static const RIGHT_GROUP_PROPERTIES_INDEX:uint = 1;
		
		/**
		 *  @private
		 */
		protected var contentGroupProperties:Array = [{}, {}];
		
		/**
		 * Cache original skin layouts
		 * @private
		 */
		protected var contentGroupLayouts:Array = [null, null];

		private var _text:String;

		// http://flexdevtips.blogspot.com/2009/03/setting-default-styles-for-custom.html
		private static var classConstructed:Boolean = classConstruct();

		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.
					getStyleDeclaration("collaboRhythm.plugins.bloodPressure.view.simulation.buttons.ContentLabel"))
			{
				// No CSS definition for StyledRectangle,  so create and set default values
				var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
				styleDeclaration.defaultFactory = function():void
				{
					this.skinClass = ContentLabelSkin;
					this.cornerRadius = 5;
					this.fontFamily = "Myriad Pro Light";
					this.fontSize = "36";
					this.fontWeight = "bold";
					this.lineHeight = "120%";
					this.kerning = "on";
				};

				FlexGlobals.topLevelApplication.styleManager.
						setStyleDeclaration("collaboRhythm.plugins.bloodPressure.view.simulation.buttons.ContentLabel", styleDeclaration, true);
			}
			return true;
		}

		public function ContentLabel()
		{
		}

		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]

		/**
		 *  A skin part that defines the label of the button.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var labelDisplay:IDisplayText;

		//----------------------------------------
		// Navigator Controls
		//----------------------------------------
		
		[SkinPart(required="false")]
		public var rightGroup:Group;
		
		[SkinPart(required="false")]
		public var leftGroup:Group;

		//----------------------------------
		//  leftContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the leftGroup of the
		 *  ActionBar. If leftContent is not null, it's visual elements replace
		 *  the mxmlContent of leftGroup. If leftContent is null, the
		 *  leftDisplay skin part, if present, replaces the mxmlContent of
		 *  leftGroup.
		 *  The location and appearance of the leftGroup of the ActionBar
		 *  container is determined by the spark.skins.mobile.ActionBarSkin class.
		 *  By default, the ActionBarSkin class defines the leftGroup to appear in
		 *  the center of the ActionBar.
		 *  Create a custom skin to change the default location and appearance of the leftGroup.
		 *  
		 *  @default null
		 *
		 *  @see spark.skins.mobile.ActionBarSkin
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get leftContent():Array
		{
			if (leftGroup)
				return leftGroup.getMXMLContent();
			else
				return contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX].content;
		}
		
		/**
		 *  @private
		 */
		public function set leftContent(value:Array):void
		{
			if (leftGroup)
			{
				leftGroup.mxmlContent = value;
				contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX] = 
					BitFlagUtil.update(contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX] as uint,
						CONTENT_PROPERTY_FLAG, value != null);
			}
			else
			{
				contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX].content = value;
			}
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  leftLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the leftGroup.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get leftLayout():LayoutBase
		{
			if (leftGroup)
				return leftGroup.layout;
			else
				return contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX].layout;
		}
		
		/**
		 *  @private
		 */
		public function set leftLayout(value:LayoutBase):void
		{
			if (leftGroup)
			{
				leftGroup.layout = (value) ? value : contentGroupLayouts[LEFT_GROUP_PROPERTIES_INDEX];
				contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX] =
					BitFlagUtil.update(contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX] as uint, 
						LAYOUT_PROPERTY_FLAG, true);
			}
			else
				contentGroupProperties[LEFT_GROUP_PROPERTIES_INDEX].layout = value;
		}
    

		//----------------------------------
		//  rightContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the rightGroup of the
		 *  ActionBar. If rightContent is not null, it's visual elements replace
		 *  the mxmlContent of rightGroup. If rightContent is null, the
		 *  rightDisplay skin part, if present, replaces the mxmlContent of
		 *  rightGroup.
		 *  The location and appearance of the rightGroup of the ActionBar
		 *  container is determined by the spark.skins.mobile.ActionBarSkin class.
		 *  By default, the ActionBarSkin class defines the rightGroup to appear in
		 *  the center of the ActionBar.
		 *  Create a custom skin to change the default location and appearance of the rightGroup.
		 *  
		 *  @default null
		 *
		 *  @see spark.skins.mobile.ActionBarSkin
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get rightContent():Array
		{
			if (rightGroup)
				return rightGroup.getMXMLContent();
			else
				return contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX].content;
		}
		
		/**
		 *  @private
		 */
		public function set rightContent(value:Array):void
		{
			if (rightGroup)
			{
				rightGroup.mxmlContent = value;
				contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX] = 
					BitFlagUtil.update(contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX] as uint,
						CONTENT_PROPERTY_FLAG, value != null);
			}
			else
			{
				contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX].content = value;
			}
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  rightLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the rightGroup.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get rightLayout():LayoutBase
		{
			if (rightGroup)
				return rightGroup.layout;
			else
				return contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX].layout;
		}
		
		/**
		 *  @private
		 */
		public function set rightLayout(value:LayoutBase):void
		{
			if (rightGroup)
			{
				rightGroup.layout = (value) ? value : contentGroupLayouts[RIGHT_GROUP_PROPERTIES_INDEX];
				contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX] =
					BitFlagUtil.update(contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX] as uint, 
						LAYOUT_PROPERTY_FLAG, true);
			}
			else
				contentGroupProperties[RIGHT_GROUP_PROPERTIES_INDEX].layout = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			var group:Group;
			var index:int = -1;

			// set ID for CSS selectors
			// (e.g. to style actionContent Buttons: s|ActionBar s|Group#actionGroup s|Button)
			if (instance == leftGroup)
			{
				group = leftGroup;
				index = LEFT_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == rightGroup)
			{
				group = rightGroup;
				index = RIGHT_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == labelDisplay)
			{
				labelDisplay.addEventListener("isTruncatedChanged",
											  labelDisplay_isTruncatedChangedHandler);

				// Push down to the part only if the label was explicitly set
				if (_text !== null)
					labelDisplay.text = text;
			}


			if (index > -1)
			{
				// cache original layout
				contentGroupLayouts[index] = group.layout;

				var newContentGroupProperties:uint = 0;

				if (contentGroupProperties[index].content !== undefined)
				{
					group.mxmlContent = contentGroupProperties[index].content;
					newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties,
						CONTENT_PROPERTY_FLAG, true);
				}

				if (contentGroupProperties[index].layout !== undefined)
				{
					group.layout = contentGroupProperties[index].layout;
					newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties,
						LAYOUT_PROPERTY_FLAG, true);
				}

				contentGroupProperties[index] = newContentGroupProperties;
			}
		}

		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);

			var group:Group;
			var index:int = -1;

			if (instance == leftGroup)
			{
				group = leftGroup;
				index = LEFT_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == rightGroup)
			{
				group = rightGroup;
				index = RIGHT_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == labelDisplay)
			{
				labelDisplay.removeEventListener("isTruncatedChanged",
												 labelDisplay_isTruncatedChangedHandler);
			}


			if (index > -1)
			{
				var newContentGroupProperties:Object = {};

				if (BitFlagUtil.isSet(contentGroupProperties[index] as uint, CONTENT_PROPERTY_FLAG))
					newContentGroupProperties.content = group.getMXMLContent();

				if (BitFlagUtil.isSet(contentGroupProperties[index] as uint, LAYOUT_PROPERTY_FLAG))
					newContentGroupProperties.layout = group.layout;

				contentGroupProperties[index] = newContentGroupProperties;

				group.mxmlContent = null;
				group.layout = null;
			}
		}

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;

			// Push to the optional labelDisplay skin part
			if (labelDisplay)
				labelDisplay.text = value;
		}

		public function get isTruncated():Boolean
		{
			return false;
		}

		/**
		 *  @private
		 */
		private function labelDisplay_isTruncatedChangedHandler(event:Event):void
		{
			var isTruncated:Boolean = labelDisplay.isTruncated;

			// If the label is truncated, show the whole label string as a tooltip.
			// We set super.toolTip to avoid setting our own _explicitToolTip.
			super.toolTip = isTruncated ? labelDisplay.text : null;
		}
	}
}
