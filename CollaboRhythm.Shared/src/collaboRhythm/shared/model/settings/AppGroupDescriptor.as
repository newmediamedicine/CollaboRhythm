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
package collaboRhythm.shared.model.settings
{
	import mx.collections.ArrayCollection;

	/**
	 * Describes a group of apps in a serializable format, ready to be persisted.
	 */
	[Bindable]
	public class AppGroupDescriptor
	{
		private var _id:String;
		private var _appDescriptors:ArrayCollection;

		public function AppGroupDescriptor(appGroupId:String=null, appDescriptors:ArrayCollection=null)
		{
			_id = appGroupId;
			_appDescriptors = appDescriptors;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get appDescriptors():ArrayCollection
		{
			return _appDescriptors;
		}

		public function set appDescriptors(value:ArrayCollection):void
		{
			_appDescriptors = value;
		}
	}
}
