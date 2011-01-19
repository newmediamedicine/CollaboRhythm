/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.dougmccune.controls.sliderClasses
{
	
	import com.dougmccune.baseClasses.SliderBase;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	import mx.controls.ButtonPhase;
	import mx.controls.sliderClasses.SliderDirection;
	import mx.core.FlexVersion;
	import mx.core.mx_internal;
	import mx.events.SliderEvent;
	import mx.managers.ISystemManager;
	
	use namespace mx_internal;
	
	/**
	 *  The SliderThumb class represents a thumb of a SliderBase control.
	 *  The SliderThumb class can only be used within the context
	 *  of a SliderBase control.
	 *  You can create a subclass of the SliderThumb class,
	 *  and use it with a SliderBase control by setting the 
	 *  <code>sliderThumbClass</code>
	 *  property of the SliderBase control to your subclass. 
	 *  		
	 *  @see mx.controls.HSlider
	 *  @see mx.controls.VSlider
	 *  @see mx.controls.sliderClasses.Slider
	 *  @see mx.controls.sliderClasses.SliderDataTip
	 *  @see mx.controls.sliderClasses.SliderLabel
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class SliderThumb extends Button
	{
//		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function SliderThumb()
		{
			super();
			
			stickyHighlighting = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/** 
		 *  @private
		 *  The zero-based index number of this thumb. 
		 */
		mx_internal var thumbIndex:int;
		
		/**
		 *  @private
		 *  x-position offset.
		 */
		private var xOffset:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  x
		//----------------------------------
		
		/**
		 *  @private
		 *  Handle changes to the x-position value of the thumb.
		 */
		override public function set x(value:Number):void
		{
			var result:Number = moveXPos(value);
			
			updateValue();
			
			super.x = result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  xPosition
		//----------------------------------
		
		/**
		 *  Specifies the position of the center of the thumb on the x-axis.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get xPosition():Number
		{
			return $x + width / 2;
		}
		
		/**
		 *  @private
		 */
		public function set xPosition(value:Number):void
		{
			$x = value - width / 2;
			
			SliderBase(owner).drawTrackHighlight();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
			{
				measuredWidth = 12;
				measuredHeight = 12;
			}
		}
		
		/**
		 *  @private
		 */
		override public function drawFocus(isFocused:Boolean):void
		{
			phase =  isFocused ? ButtonPhase.DOWN : ButtonPhase.UP;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Button
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override mx_internal function buttonReleased():void
		{
			super.buttonReleased();
			
			if (enabled)
			{
				systemManager.getSandboxRoot().removeEventListener(
					MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				systemManager.deployMouseShields(false);
				
				SliderBase(owner).onThumbRelease(this);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Move the thumb into the correct position.
		 */
		private function moveXPos(value:Number, 
								  overrideSnap:Boolean = false, 
								  noUpdate:Boolean = false):Number
		{
			var result:Number = calculateXPos(value, overrideSnap);
			
			xPosition = result;
			
			if (!noUpdate) 
				updateValue();
			
			return result;
		}
		
		/**
		 *  @private
		 *  Ask the SliderBase if we should be moving into a snap position 
		 *  and make sure we haven't exceeded the min or max position
		 */
		private function calculateXPos(value:Number,
									   overrideSnap:Boolean = false):Number
		{
			var bounds:Object = SliderBase(owner).getXBounds(thumbIndex);
			
			var result:Number = Math.min(Math.max(value, bounds.min), bounds.max);
			
			if (!overrideSnap)
				result = SliderBase(owner).getSnapValue(result, this);	
			
			return result;
		}
		
		/**
		 *	@private
		 *	Used by the SliderBase for animating the sliding of the thumb.
		 */
		mx_internal function onTweenUpdate(value:Number):void
		{
			moveXPos(value, true, true);
		}
		
		/**
		 *	@private
		 *	Used by the SliderBase for animating the sliding of the thumb.
		 */
		mx_internal function onTweenEnd(value:Number):void
		{
			moveXPos(value);
		}
		
		/**
		 *  @private
		 *  Tells the SliderBase to update its value for the thumb based on the thumb's
		 *  current position
		 */
		private function updateValue():void
		{
			SliderBase(owner).updateThumbValue(thumbIndex);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden event handlers: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Handle key presses when focus is on the thumb.
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			var multiThumbs:Boolean = SliderBase(owner).thumbCount > 1;
			var currentVal:Number = xPosition;
			var moveInterval:Number = SliderBase(owner).snapInterval > 0 ?
				SliderBase(owner).getSnapIntervalWidth() :
				1;
			var isHorizontal:Boolean =
				SliderBase(owner).direction == SliderDirection.HORIZONTAL;
			
			var newVal:Number;
			if ((event.keyCode == Keyboard.DOWN && !isHorizontal) ||
				(event.keyCode == Keyboard.LEFT && isHorizontal))
			{
				newVal = currentVal - moveInterval;
			}
			else if ((event.keyCode == Keyboard.UP && !isHorizontal) ||
				(event.keyCode == Keyboard.RIGHT && isHorizontal))
			{
				newVal = currentVal + moveInterval;
			}
			else if ((event.keyCode == Keyboard.PAGE_DOWN && !isHorizontal) ||
				(event.keyCode == Keyboard.HOME && isHorizontal))
			{
				newVal = SliderBase(owner).getXFromValue(SliderBase(owner).minimum);
			}
			else if ((event.keyCode == Keyboard.PAGE_UP && !isHorizontal) ||
				(event.keyCode == Keyboard.END && isHorizontal))
			{
				newVal = SliderBase(owner).getXFromValue(SliderBase(owner).maximum);
			}
			
			if (!isNaN(newVal))
			{
				event.stopPropagation();
				//mark last interaction as key 
				SliderBase(owner).keyInteraction = true;
				moveXPos(newVal);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden event handlers: Button
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			super.mouseDownHandler(event);
			
			if (enabled)
			{
				// Store where the mouse is positioned
				// relative to the thumb when first pressed.
				xOffset = event.localX; 
				
				systemManager.getSandboxRoot().addEventListener(
					MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				systemManager.deployMouseShields(true);
				
				SliderBase(owner).onThumbPress(this);
			}
		}
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Internal function to handle mouse movements
		 *  when the thumb is in a pressed state
		 *  We want the thumb to follow the x-position of the mouse. 
		 */
		private function mouseMoveHandler(event:MouseEvent):void
		{
			if (enabled)
			{
				var pt:Point = new Point(event.stageX, event.stageY);
				pt = SliderBase(owner).innerSlider.globalToLocal(pt);
				
				// Place the thumb in the correct position.
				moveXPos(pt.x - xOffset + width / 2, false, true);
				
				// Callback to the SliderBase to handle tooltips and update its value.
				SliderBase(owner).onThumbMove(this);
			}
		}
	}
	
}
