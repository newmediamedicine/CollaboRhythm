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
package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.model.User;

	/**
	 * Data used by the response handler in the health record service when a blood pressure report is returned.
	 */
	public class BloodPressureReportUserData
	{
		private var _user:User;
		private var _category:String;
		public function BloodPressureReportUserData(user:User, category:String)
		{
			_user = user;
			_category = category;
		}

		public function get user():User
		{
			return _user;
		}

		public function get category():String
		{
			return _category;
		}
	}
}
