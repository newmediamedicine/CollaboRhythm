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
package collaboRhythm.core.controller.apps
{
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.controller.apps.AppOrderConstraint;

	import mx.collections.ArrayCollection;

	public class AppControllersSorter
	{
		public function AppControllersSorter()
		{
		}

		public static function orderAppsByInitializationOrderConstraints(infoArray:Array):Array
		{
			// copy the array so we can look at each app's constraints once
			var newOrder:ArrayCollection = new ArrayCollection(infoArray.slice());

			// TODO: revise this algorithm to only move items down in the order so that multiple before and after constraints can be used together
			var retryCount:int = 0;
			var orderChanged:Boolean;
			do
			{
				orderChanged = reorder(infoArray, newOrder);
				infoArray = newOrder.toArray();
				retryCount++;
//				trace("Reorder retries: " + retryCount);
//				trace(arrayCollectionToStringForTrace(newOrder));
			}
			while (orderChanged && retryCount < infoArray.length);

			trace(arrayCollectionToStringForTrace(newOrder));
			return newOrder.toArray();
		}

		private static function reorder(infoArray:Array, newOrder:ArrayCollection):Boolean
		{
			var orderChanged:Boolean;
			for each (var appInfo:AppControllerInfo in infoArray)
			{
				if (appInfo.initializationOrderConstraints.length > 0)
				{
					var currentIndex:int = newOrder.getItemIndex(appInfo);
					var newIndex:int = -1;

					for each (var constraint:AppOrderConstraint in appInfo.initializationOrderConstraints)
					{
						var otherAppIndex:int = 0;
						for each (var otherAppInfo:AppControllerInfo in newOrder)
						{
							if (constraint.appMatches(otherAppInfo))
							{
								// Determine the newIndex based on the constraint; only update the index if the
								// constraint is not currently satisfied
								if (constraint.relativeOrder == AppOrderConstraint.ORDER_AFTER && (otherAppIndex + 1 > newIndex && otherAppIndex + 1 > currentIndex))
								{
									newIndex = otherAppIndex + 1;
								}
								if (constraint.relativeOrder == AppOrderConstraint.ORDER_BEFORE && (newIndex == -1 || otherAppIndex < newIndex) && (otherAppIndex < currentIndex))
								{
									newIndex = otherAppIndex;
								}
							}
							otherAppIndex++;
						}
					}

					if (newIndex != -1)
					{
						// move the appInfo to the appropriate place
						if (newIndex != currentIndex)
						{
							trace("    Moving " + appInfo.toString() + " at " + currentIndex + " after " + newOrder.getItemAt(newIndex - 1).toString() + " at " + newIndex);
							orderChanged = true;
							newOrder.addItemAt(appInfo, newIndex);
							if (newIndex < currentIndex)
							{
								// the currentIndex needs adjusting if we are moving the item up in the order
								currentIndex++;
							}
							newOrder.removeItemAt(currentIndex);
						}
					}
				}
			}
			return orderChanged;
		}

		private static function arrayCollectionToStringForTrace(arrayCollection:ArrayCollection):String
		{
			var result:String = "";
			for each (var item:Object in arrayCollection)
			{
				result += item.toString() + "\n";
			}
			return result;
		}
	}
}
