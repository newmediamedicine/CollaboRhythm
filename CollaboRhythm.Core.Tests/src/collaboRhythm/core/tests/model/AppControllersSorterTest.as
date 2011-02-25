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
package collaboRhythm.core.tests.model
{
	import collaboRhythm.core.controller.apps.AppControllersSorter;
	import collaboRhythm.core.tests.model.testResources.AppControllerA;
	import collaboRhythm.core.tests.model.testResources.AppControllerB;
	import collaboRhythm.core.tests.model.testResources.AppControllerC;
	import collaboRhythm.core.tests.model.testResources.AppControllerD;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.controller.apps.AppOrderConstraint;

	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;

	public class AppControllersSorterTest
	{
		public function AppControllersSorterTest()
		{
		}

		[Test(description = "Tests that the order does not change if there are no constraints")]
		public function orderWithNoConstraintsUnchanged():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);

			var originalArray:Array = [a, b];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(a, b));
		}

		[Test(description = "Tests that the order does not change if there are no constraints, even for reverse alphabetical")]
		public function orderReverseAlphabeticalWithNoConstraintsUnchanged():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);

			var originalArray:Array = [b, a];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(b, a));
		}

		[Test(description = "Tests that an ORDER_AFTER constraint changes the order")]
		public function orderAfter():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			a.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, b.appId));

			var originalArray:Array = [a, b];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(b, a));
		}

		[Test(description = "Tests that an ORDER_BEFORE constraint changes the order")]
		public function orderBefore():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			b.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_BEFORE, a.appId));

			var originalArray:Array = [a, b];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(b, a));
		}


		[Test(description = "Tests that an ORDER_AFTER constraint does not change the order if it is already correct")]
		public function orderAfterNoChange():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			b.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, a.appId));

			var originalArray:Array = [a, b];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(a, b));
		}

		[Test(description = "Tests that an ORDER_BEFORE constraint does not change the order if it is already correct")]
		public function orderBeforeNoChange():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			a.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_BEFORE, b.appId));

			var originalArray:Array = [a, b];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(a, b));
		}

		[Test(description = "Tests that combining an ORDER_BEFORE and an ORDER_AFTER constraint changes the order correctly")]
		public function orderBeforeAndAfter():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			var c:AppControllerInfo = new AppControllerInfo(AppControllerC);
			var d:AppControllerInfo = new AppControllerInfo(AppControllerD);
			d.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_BEFORE, a.appId));
			d.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, b.appId));

			var originalArray:Array = [a, b, c, d];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(b, d, a, c));
		}

		[Test(description = "Tests that the order is changed correctly when there are multiple cascading ORDER_AFTER constraints")]
		public function orderCascadingEffectOfAfterConstraints():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			var c:AppControllerInfo = new AppControllerInfo(AppControllerC);
			var d:AppControllerInfo = new AppControllerInfo(AppControllerD);
			b.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, a.appId)); // no change, initially
			a.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, d.appId)); // now a and b need to be moved after d

			var originalArray:Array = [a, b, c, d];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(c, d, a, b));
		}

		[Test(description = "Tests that multiple info objects, each with an ORDER_AFTER constraint, changes the order correctly")]
		public function orderMultipleObjectsWithSingleAfterConstraint():void
		{
			var a:AppControllerInfo = new AppControllerInfo(AppControllerA);
			var b:AppControllerInfo = new AppControllerInfo(AppControllerB);
			var c:AppControllerInfo = new AppControllerInfo(AppControllerC);
			var d:AppControllerInfo = new AppControllerInfo(AppControllerD);
			a.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, d.appId));
			b.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, d.appId));
			c.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, d.appId));

			var originalArray:Array = [a, b, c, d];
			var orderedArray:Array = AppControllersSorter.orderAppsByInitializationOrderConstraints(originalArray);

			assertThat(orderedArray, array(d, a, b, c));
		}
	}
}
