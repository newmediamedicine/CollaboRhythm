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
package collaboRhythm.simulation.view
{
	import collaboRhythm.plugins.bloodPressure.view.simulation.*;
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.bloodPressure.view.simulation.skins.SimulationLevelPanelSkin;

	import flash.events.MouseEvent;

	import mx.core.FlexGlobals;
	import mx.core.IButton;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.BitFlagUtil;

	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.IDisplayText;
	import spark.layouts.supportClasses.LayoutBase;

	use namespace mx_internal;


	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event(name=SimulationLevelEvent.BACK_UP_LEVEL,type="collaboRhythm.simulation.view.SimulationLevelEvent")]
	[Event(name=SimulationLevelEvent.DRILL_DOWN_LEVEL,type="collaboRhythm.simulation.view.SimulationLevelEvent")]
	[Event(name="backUpLevel",type="collaboRhythm.simulation.view.SimulationLevelEvent")]
	[Event(name="drillDownLevel",type="collaboRhythm.simulation.view.SimulationLevelEvent")]

	//--------------------------------------
	//  Styles
	//--------------------------------------

	/**
	 *  Alpha level of the background for this component.
	 *  Valid values range from 0.0 to 1.0.
	 *
	 *  @default 1.0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="backgroundAlpha", type="Number", inherit="no", theme="spark")]

	/**
	 *  Background color of a component.
	 *
	 *  @default 0xFFFFFF
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="spark")]

	/**
	 *  The alpha of the border for this component.
	 *
	 *  @default 0.5
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderAlpha", type="Number", inherit="no", theme="spark")]

	/**
	 *  The color of the border for this component.
	 *
	 *  @default 0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the border for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  The radius of the corners for this component.
	 *
	 *  @default 0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the drop shadow for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="dropShadowVisible", type="Boolean", inherit="no", theme="spark")]
	
	public class SimulationLevelPanel extends SkinnableComponent
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
		protected static const TITLE_GROUP_PROPERTIES_INDEX:uint = 0;
		
		/**
		 *  @private
		 */
		protected static const SIMULATION_GROUP_PROPERTIES_INDEX:uint = 1;
		
		/**
		 *  @private
		 */
		protected var contentGroupProperties:Array = [{}, {}];
		
		/**
		 * Cache original skin layouts
		 * @private
		 */
		protected var contentGroupLayouts:Array = [null, null];

		private var _enableBack:Boolean;

		[Bindable]
		public function get enableBack():Boolean
		{
			return _enableBack;
		}

		public function set enableBack(value:Boolean):void
		{
			_enableBack = value;
			if (backButton)
				backButton.enabled = value;
		}

		// http://flexdevtips.blogspot.com/2009/03/setting-default-styles-for-custom.html
		private static var classConstructed:Boolean = classConstruct();

		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.
					getStyleDeclaration("collaboRhythm.plugins.bloodPressure.view.simulation.SimulationLevelPanel"))
			{
				// No CSS definition for StyledRectangle,  so create and set default values
				var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
				styleDeclaration.defaultFactory = function():void
				{
					this.backgroundAlpha = 0;
					this.borderVisible = false;
					this.skinClass = SimulationLevelPanelSkin;
				};

				FlexGlobals.topLevelApplication.styleManager.
						setStyleDeclaration("collaboRhythm.simulation.view.SimulationLevelPanel", styleDeclaration, true);
			}
			return true;
		}

		public function SimulationLevelPanel()
		{
		}

		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------------
		// Navigator Controls
		//----------------------------------------
		
		[SkinPart(required="false")]    
		
		/**
		*  A skin part that defines the back button for navigation.
		*  
		*  @langversion 3.0
		*  @playerversion Flash 10
		*  @playerversion AIR 1.5
		*  @productversion Flex 4
		*/
		public var backButton:IButton;

		[SkinPart(required="false")]
		public var simulationGroup:Group;
		
		[SkinPart(required="false")]
		public var titleGroup:Group;

    
		/**
		 *  The skin part that defines the appearance of the 
		 *  title text in the component.
		 *
		 *  @see spark.skins.mobile.ActionBarSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4
		 */
		public var titleDisplay:IDisplayText;
    
		//----------------------------------
		//  title
		//----------------------------------

		private var _title:String;
		private var titleInvalidated:Boolean = false;

		[Bindable]

		/**
		 *  The default title that should be used if there is no titleContent.
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get title():String
		{
			return _title;
		}

		/**
		 *  @private
		 */
		public function set title(value:String):void
		{
			if (_title != value)
			{
				_title = value;

				// title will only have an effect on the view if titleContent isn't set anywhere else
				if (!titleContent)
				{
					titleInvalidated = true;
					invalidateProperties();
				}
			}
		}

		//----------------------------------
		//  titleContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the titleGroup of the
		 *  ActionBar. If titleContent is not null, it's visual elements replace
		 *  the mxmlContent of titleGroup. If titleContent is null, the
		 *  titleDisplay skin part, if present, replaces the mxmlContent of
		 *  titleGroup.
		 *  The location and appearance of the titleGroup of the ActionBar
		 *  container is determined by the spark.skins.mobile.ActionBarSkin class.
		 *  By default, the ActionBarSkin class defines the titleGroup to appear in
		 *  the center of the ActionBar.
		 *  Create a custom skin to change the default location and appearance of the titleGroup.
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
		public function get titleContent():Array
		{
			if (titleGroup)
				return titleGroup.getMXMLContent();
			else
				return contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content;
		}
		
		/**
		 *  @private
		 */
		public function set titleContent(value:Array):void
		{
			if (titleGroup)
			{
				titleGroup.mxmlContent = value;
				contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] = 
					BitFlagUtil.update(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] as uint,
						CONTENT_PROPERTY_FLAG, value != null);
			}
			else
			{
				contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content = value;
			}
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  titleLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the titleGroup.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get titleLayout():LayoutBase
		{
			if (titleGroup)
				return titleGroup.layout;
			else
				return contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].layout;
		}
		
		/**
		 *  @private
		 */
		public function set titleLayout(value:LayoutBase):void
		{
			if (titleGroup)
			{
				titleGroup.layout = (value) ? value : contentGroupLayouts[TITLE_GROUP_PROPERTIES_INDEX];
				contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] =
					BitFlagUtil.update(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] as uint, 
						LAYOUT_PROPERTY_FLAG, true);
			}
			else
				contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].layout = value;
		}
    

		//----------------------------------
		//  simulationContent
		//---------------------------------- 
		
		[ArrayElementType("mx.core.IVisualElement")]
		
		/**
		 *  The set of components to include in the simulationGroup of the
		 *  ActionBar. If simulationContent is not null, it's visual elements replace
		 *  the mxmlContent of simulationGroup. If simulationContent is null, the
		 *  simulationDisplay skin part, if present, replaces the mxmlContent of
		 *  simulationGroup.
		 *  The location and appearance of the simulationGroup of the ActionBar
		 *  container is determined by the spark.skins.mobile.ActionBarSkin class.
		 *  By default, the ActionBarSkin class defines the simulationGroup to appear in
		 *  the center of the ActionBar.
		 *  Create a custom skin to change the default location and appearance of the simulationGroup.
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
		public function get simulationContent():Array
		{
			if (simulationGroup)
				return simulationGroup.getMXMLContent();
			else
				return contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX].content;
		}
		
		/**
		 *  @private
		 */
		public function set simulationContent(value:Array):void
		{
			if (simulationGroup)
			{
				simulationGroup.mxmlContent = value;
				contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX] = 
					BitFlagUtil.update(contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX] as uint,
						CONTENT_PROPERTY_FLAG, value != null);
			}
			else
			{
				contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX].content = value;
			}
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  simulationLayout
		//---------------------------------- 
		
		/**
		 *  Defines the layout of the simulationGroup.
		 *
		 *  @default HorizontalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get simulationLayout():LayoutBase
		{
			if (simulationGroup)
				return simulationGroup.layout;
			else
				return contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX].layout;
		}
		
		/**
		 *  @private
		 */
		public function set simulationLayout(value:LayoutBase):void
		{
			if (simulationGroup)
			{
				simulationGroup.layout = (value) ? value : contentGroupLayouts[SIMULATION_GROUP_PROPERTIES_INDEX];
				contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX] =
					BitFlagUtil.update(contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX] as uint, 
						LAYOUT_PROPERTY_FLAG, true);
			}
			else
				contentGroupProperties[SIMULATION_GROUP_PROPERTIES_INDEX].layout = value;
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
			if (instance == titleGroup)
			{
				group = titleGroup;
				index = TITLE_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == simulationGroup)
			{
				group = simulationGroup;
				index = SIMULATION_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == titleDisplay)
			{
				titleDisplay.text = title;
			}
			else if (instance == backButton)
			{
				backButton.enabled = enableBack;
				backButton.addEventListener(MouseEvent.CLICK, backButton_click, false, 0, true);
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

			if (instance == titleGroup)
			{
				group = titleGroup;
				index = TITLE_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == simulationGroup)
			{
				group = simulationGroup;
				index = SIMULATION_GROUP_PROPERTIES_INDEX;
			}
			else if (instance == backButton)
			{
				backButton.removeEventListener(MouseEvent.CLICK, backButton_click);
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

		private function backButton_click(event:MouseEvent):void
		{
			dispatchEvent(new SimulationLevelEvent(SimulationLevelEvent.BACK_UP_LEVEL));
		}
	}
}
