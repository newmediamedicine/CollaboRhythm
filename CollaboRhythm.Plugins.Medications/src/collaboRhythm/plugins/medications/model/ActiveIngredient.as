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
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.ValueAndUnit;

	public class ActiveIngredient
	{
		private var _name:CodedValue;
		private var _strength:ValueAndUnit;
		
		public function ActiveIngredient(name:CodedValue, strength:ValueAndUnit)
		{
			_name = name;
			_strength = strength;
		}	
		
		public function get name():CodedValue
		{
			return _name;
		}

		public function get strength():ValueAndUnit
		{
			return _strength;
		}
	}
}