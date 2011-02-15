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
package collaboRhythm.plugins.problems.model
{
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class Problem
	{
		private var _name:String;
		private var _commonName:String;
		private var _dateOnset:Date;
		private var _dateResolution:Date;
		private var _currentDateSource:ICurrentDateSource;
		
		public function Problem(problemXml:XML)
		{
			_name = problemXml.name;
			_commonName = problemXml.comments;
			_dateOnset = HealthRecordServiceBase.parseDate(problemXml.dateOnset.toString());
			_dateResolution = HealthRecordServiceBase.parseDate(problemXml.dateResolution.toString());
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}
		
		public function get commonNameLabel():String
		{
			if (_commonName != null && _commonName.length > 0)
				return "(" + _commonName + ")";
			
			return null;
		}
		
		public function get commonName():String
		{
			return _commonName;
		}

		public function set commonName(value:String):void
		{
			_commonName = value;
		}

		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get isInactive():Boolean
		{
			if (_dateResolution != null)
			{
				return _dateResolution < _currentDateSource.now();
			}
			return false;
		}
	}
}