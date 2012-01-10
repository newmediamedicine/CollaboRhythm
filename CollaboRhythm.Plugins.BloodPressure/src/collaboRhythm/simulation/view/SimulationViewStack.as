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
	import mx.containers.ViewStack;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.Effect;
	import mx.effects.EffectManager;
	import mx.events.EffectEvent;
	use namespace mx_internal;

	public class SimulationViewStack extends ViewStack
	{
		public function SimulationViewStack()
		{
		}

		/**
		 *  Commits the selected index. This function is called during the commit
		 *  properties phase when the selectedIndex (or selectedItem) property
		 *  has changed.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override protected function commitSelectedIndex(newIndex:int):void
		{
			super.commitSelectedIndex(newIndex);

//			var currentChild:UIComponent = UIComponent(getChildAt(lastIndex));
//			if (currentChild.getStyle("hideEffect"))
//			{
//				var hideEffect:Effect = EffectManager.lastEffectCreated; // This should be the hideEffect
//
//				if (hideEffect)
//				{
//					hideEffect.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END));
//				}
//			}
		}
	}
}
