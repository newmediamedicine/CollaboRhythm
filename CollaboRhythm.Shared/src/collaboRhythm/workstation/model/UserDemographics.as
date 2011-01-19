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
package collaboRhythm.workstation.model
{
	import castle.flexbridge.common.NotSupportedError;
	
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class UserDemographics
	{
		private var _rawData:XML;
		
		private var _dateOfBirth:Date;
		private var _dateOfDeath:Date;
		private var _gender:String;
		private var _ethnicity:String;
		private var _language:String;
		private var _maritalStatus:String;
		private var _employmentStatus:String;
		private var _employmentIndustry:String;
		private var _occupation:String;
		private var _religion:String;
		private var _income:String;
		private var _highestEducation:String;
		private var _organDonor:Boolean;

		private var _currentDateSource:ICurrentDateSource;

		public function UserDemographics(rawData:XML=null)
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			this.rawData = rawData;
		}
		
		public function get rawData():XML
		{
			return _rawData;
		}
		
		public function set rawData(value:XML):void
		{
			_rawData = value;
		
			if (rawData.dateOfBirth.length() == 1)
			{
				this.dateOfBirth = HealthRecordServiceBase.parseDate(rawData.dateOfBirth.toString());
			}
			
			if (rawData.dateOfDeath.length() == 1)
			{
				this.dateOfDeath = HealthRecordServiceBase.parseDate(rawData.dateOfDeath.toString());
			}
			
			if (rawData.gender.length() == 1)
			{
				this.gender = rawData.gender.toString();
			}
			
			if (rawData.ethnicity.length() == 1)
			{
				this.ethnicity = rawData.ethnicity.toString();
			}
			
			if (rawData.language.length() == 1)
			{
				this.language = rawData.language.toString();
			}
			
			if (rawData.maritalStatus.length() == 1)
			{
				this.maritalStatus = rawData.maritalStatus.toString();
			}
			
			if (rawData.employmentStatus.length() == 1)
			{
				this.employmentStatus = rawData.employmentStatus.toString();
			}
			
			if (rawData.employmentIndustry.length() == 1)
			{
				this.employmentIndustry = rawData.employmentIndustry.toString();
			}
			
			if (rawData.occupation.length() == 1)
			{
				this.occupation = rawData.occupation.toString();
			}
			
			if (rawData.religion.length() == 1)
			{
				this.religion = rawData.religion.toString();
			}
			
			if (rawData.income.length() == 1)
			{
				this.income = rawData.income.toString();
			}
			
			if (rawData.highestEducation.length() == 1)
			{
				this.highestEducation = rawData.highestEducation.toString();
			}
			
			if (rawData.organDonor.length() == 1)
			{
				this.organDonor = rawData.organDonor.toString() == true.toString();
			}
		}

		public function get dateOfBirth():Date
		{
			return _dateOfBirth;
		}
		
		private function set dateOfBirth(value:Date):void
		{
			_dateOfBirth = value;
			dispatchAgeChangeEvent();
		}
		
		public function dispatchAgeChangeEvent():void
		{
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "age", NaN, this.age));
		}
		
		public function get dateOfDeath():Date
		{
			return _dateOfDeath;
		}
		
		private function set dateOfDeath(value:Date):void
		{
			_dateOfDeath = value;
		}
		
		public function get gender():String
		{
			return _gender;
		}
		
		private function set gender(value:String):void
		{
			_gender = value;
		}
		
		public function get ethnicity():String
		{
			return _ethnicity;
		}
		
		private function set ethnicity(value:String):void
		{
			_ethnicity = value;
		}
		
		public function get language():String
		{
			return _language;
		}
		
		private function set language(value:String):void
		{
			_language = value;
		}
		
		public function get maritalStatus():String
		{
			return _maritalStatus;
		}
		
		private function set maritalStatus(value:String):void
		{
			_maritalStatus = value;
		}
		
		public function get employmentStatus():String
		{
			return _employmentStatus;
		}
		
		private function set employmentStatus(value:String):void
		{
			_employmentStatus = value;
		}
		
		public function get employmentIndustry():String
		{
			return _employmentIndustry;
		}
		
		private function set employmentIndustry(value:String):void
		{
			_employmentIndustry = value;
		}
		
		public function get occupation():String
		{
			return _occupation;
		}
		
		private function set occupation(value:String):void
		{
			_occupation = value;
		}
		
		public function get religion():String
		{
			return _religion;
		}
		
		private function set religion(value:String):void
		{
			_religion = value;
		}
		
		public function get income():String
		{
			return _income;
		}
		
		private function set income(value:String):void
		{
			_income = value;
		}
		
		public function get highestEducation():String
		{
			return _highestEducation;
		}
		
		private function set highestEducation(value:String):void
		{
			_highestEducation = value;
		}
		
		public function get organDonor():Boolean
		{
			return _organDonor;
		}
		
		private function set organDonor(value:Boolean):void
		{
			_organDonor = value;
		}
		
		public function get age():Number
		{
			return dateToAge(this.dateOfBirth);
		}
		
		private function set age(value:Number):void
		{
			throw new NotSupportedError("set age not supported");
		}

		private function dateToAge(start:Date):Number
		{
			var now:Date = _currentDateSource.now();
			var nowMs:Number = now.getTime();
			var startMs:Number = start.getTime();
			var difference:Date = new Date(nowMs - startMs);
			return (difference.getFullYear() - 1970);
		}
	}
}