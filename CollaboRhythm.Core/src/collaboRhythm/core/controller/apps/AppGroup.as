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
	import collaboRhythm.shared.controller.apps.AppControllerBase;

	import mx.collections.ArrayCollection;

	/**
	 * Container for a group of apps (AppControllerBase instances).
	 */
	public class AppGroup
	{
		private var _id:String;
		private var _apps:Vector.<AppControllerBase> = new Vector.<AppControllerBase>();

		public function AppGroup()
		{
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get apps():Vector.<AppControllerBase>
		{
			return _apps;
		}

		public function set apps(value:Vector.<AppControllerBase>):void
		{
			_apps = value;
		}

		/**
		 * Generates a collection of app descriptors (currently, just the app class names) which can be useful for
		 * persisting the AppGroup.
		 */
		public function get appDescriptors():ArrayCollection
		{
			var appDescriptors:ArrayCollection = new ArrayCollection();

			for each (var app:AppControllerBase in apps)
			{
				appDescriptors.addItem(app.appClassName);
			}

			return appDescriptors;
		}
	}
}
