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
package collaboRhythm.plugins.cataractMap.model
{
	import collaboRhythm.shared.model.IDataItem;

	[Bindable]
	public class CataractMapDataItem implements IDataItem
	{
		private var _date:Date;
		private var _isCataract:Boolean;
		private var _densityMapMax:Number;
		private var _densityMap:Vector.<Number>;
		private var _locationMap:Vector.<Boolean>;
		
		public function CataractMapDataItem()
		{
		}

		public function get isCataract():Boolean
		{
			return _isCataract;
		}

		public function set isCataract(value:Boolean):void
		{
			_isCataract = value;
		}

		public function get densityMapMax():Number
		{
			return _densityMapMax;
		}

		public function set densityMapMax(value:Number):void
		{
			_densityMapMax = value;
		}

		public function get densityMap():Vector.<Number>
		{
			return _densityMap;
		}

		public function set densityMap(value:Vector.<Number>):void
		{
			_densityMap = value;
		}

		public function get locationMap():Vector.<Boolean>
		{
			return _locationMap;
		}

		public function set locationMap(value:Vector.<Boolean>):void
		{
			_locationMap = value;
		}

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}

	}
}