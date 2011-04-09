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
package com.dougmccune.controls
{
	import spark.layouts.BasicLayout;

	/**
	 * Layout which does not change the target component's size based on its children.
	 */
	public class ChildIndependentLayout extends BasicLayout
	{
		public function ChildIndependentLayout()
		{
			super();
		}

		override public function measure():void
		{
			// Don't do anything; even if children don't fit, the size of the target should not change
		}

	}
}
