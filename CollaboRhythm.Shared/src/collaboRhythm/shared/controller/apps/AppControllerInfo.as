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
package collaboRhythm.shared.controller.apps
{
	import castle.flexbridge.reflection.ReflectionUtils;

	public class AppControllerInfo
	{
		private var _appControllerClass:Class;
		private var _initializationOrderConstraints:Vector.<AppOrderConstraint> = new Vector.<AppOrderConstraint>();

		public function AppControllerInfo(appControllerClass:Class)
		{
			_appControllerClass = appControllerClass
		}

		public function get appControllerClass():Class
		{
			return _appControllerClass;
		}

		public function set appControllerClass(value:Class):void
		{
			_appControllerClass = value;
		}

		public function get initializationOrderConstraints():Vector.<AppOrderConstraint>
		{
			return _initializationOrderConstraints;
		}

		public function get appId():String
		{
			return ReflectionUtils.getClassInfo(appControllerClass).name;
		}


		public function toString():String
		{
			return "AppControllerInfo{appId=" + appId + "}";
		}
	}
}