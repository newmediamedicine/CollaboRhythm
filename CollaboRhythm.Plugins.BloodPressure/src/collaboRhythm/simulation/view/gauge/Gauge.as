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
package collaboRhythm.simulation.view.gauge
{
	import flash.display.Sprite;

	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;

	import spark.components.supportClasses.SkinnableComponent;

	public class Gauge extends SkinnableComponent
	{
		private var _valueMinimum:Number;
		private var _valueMaximum:Number;
		private var _valueLow0:Number;
		private var _valueLow1:Number;
		private var _valueHigh0:Number;
		private var _valueHigh1:Number;
		
		private static const rotationMinimum:Number = -90;
		private static const rotationMaximum:Number = 90;
		private static const rotationLow0:Number = -40;
		private static const rotationLow1:Number = -70;
		private static const rotationHigh0:Number = 40;
		private static const rotationHigh1:Number = 70;

		private var _value:Number;

		[SkinPart(required="false")]
		public var needle:Sprite;

		// http://flexdevtips.blogspot.com/2009/03/setting-default-styles-for-custom.html
		private static var classConstructed:Boolean = classConstruct();

		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.
					getStyleDeclaration("collaboRhythm.plugins.bloodPressure.view.simulation.gauge.Gauge"))
			{
				// No CSS definition for StyledRectangle,  so create and set default values
				var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
				styleDeclaration.defaultFactory = function():void
				{
					this.skinClass = GaugeSkin;
				};

				FlexGlobals.topLevelApplication.styleManager.
						setStyleDeclaration("collaboRhythm.plugins.bloodPressure.view.simulation.gauge.Gauge", styleDeclaration, true);
			}
			return true;
		}

		public function Gauge()
		{
		}

		[Bindable]
		public function get valueMinimum():Number
		{
			return _valueMinimum;
		}

		public function set valueMinimum(value:Number):void
		{
			_valueMinimum = value;
		}

		[Bindable]
		public function get valueMaximum():Number
		{
			return _valueMaximum;
		}

		public function set valueMaximum(value:Number):void
		{
			_valueMaximum = value;
		}

		[Bindable]
		public function get valueLow0():Number
		{
			return _valueLow0;
		}

		public function set valueLow0(value:Number):void
		{
			_valueLow0 = value;
		}

		[Bindable]
		public function get valueLow1():Number
		{
			return _valueLow1;
		}

		public function set valueLow1(value:Number):void
		{
			_valueLow1 = value;
		}

		[Bindable]
		public function get valueHigh0():Number
		{
			return _valueHigh0;
		}

		public function set valueHigh0(value:Number):void
		{
			_valueHigh0 = value;
		}

		[Bindable]
		public function get valueHigh1():Number
		{
			return _valueHigh1;
		}

		public function set valueHigh1(value:Number):void
		{
			_valueHigh1 = value;
		}

		[Bindable]
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;

			updateNeedle();
		}

		private function updateNeedle():void
		{
			if (needle)
			{
				if (!isNaN(value))
				{
					if (value < valueLow1)
						needle.rotation = linearTransform(value, valueMinimum, valueLow1, rotationMinimum, rotationLow1);
					else if (value >= valueLow1 && value < valueLow0)
						needle.rotation = linearTransform(value, valueLow1, valueLow0, rotationLow1, rotationLow0);
					else if (value >= valueLow0 && value < valueHigh0)
						needle.rotation = linearTransform(value, valueLow0, valueHigh0, rotationLow0, rotationHigh0);
					else if (value >= valueHigh0 && value < valueHigh1)
						needle.rotation = linearTransform(value, valueHigh0, valueHigh1, rotationHigh0, rotationHigh1);
					else if (value >= valueHigh1)
						needle.rotation = linearTransform(value, valueHigh1, valueMaximum, rotationHigh1, rotationMaximum);
				}
				needle.visible = !isNaN(value);
			}
		}

		private static function linearTransform(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			return min2 + percentOfRange(value, min, max) * (max2 - min2);
		}

		private static function percentOfRange(value:Number, min:Number, max:Number):Number
		{
			return Math.max(0, Math.min(1, (value - min) / (max - min)));
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

			if (instance == needle)
			{
				updateNeedle();
			}
		}

		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);

			if (instance == needle)
			{
			}
		}

	}
}
