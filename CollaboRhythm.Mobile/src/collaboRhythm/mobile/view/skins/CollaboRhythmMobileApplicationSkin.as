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
package collaboRhythm.mobile.view.skins
{
	import net.flashdan.containers.busyindicator.BusyIndicator;

	import spark.components.ViewNavigator;
	import spark.skins.mobile.ViewNavigatorApplicationSkin;

	public class CollaboRhythmMobileApplicationSkin extends ViewNavigatorApplicationSkin
	{
		public var busyIndicator:BusyIndicator;

		[Embed("/assets/animation1.swf")]
		[Bindable]
		public var busyIndicatorSourceAnimation:Class;

		public function CollaboRhythmMobileApplicationSkin()
		{
			super();
		}

		override protected function createChildren():void
		{
			busyIndicator = new BusyIndicator();
			busyIndicator.setStyle("source", busyIndicatorSourceAnimation);
			busyIndicator.setStyle("scale", true);
			busyIndicator.busy = true;
			addChild(busyIndicator);

			navigator = new ViewNavigator();
			navigator.percentHeight = 100;
			navigator.percentWidth = 100;
			busyIndicator.addElement(navigator);
		}

		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			busyIndicator.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
			busyIndicator.setLayoutBoundsPosition(0, 0);
		}
	}
}
