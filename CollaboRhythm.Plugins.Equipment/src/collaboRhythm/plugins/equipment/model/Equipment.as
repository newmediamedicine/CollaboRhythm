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
package collaboRhythm.plugins.equipment.model
{
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class Equipment extends DocumentMetadata
	{
		private var _dateStarted:Date;
		private var _dateStopped:Date;
		//TODO: type collides with an element of the metadata, fix in schema
//		private var _type:String;
		private var _name:String;
		private var _vendor:String;
		//TODO: id collides with an element of the metadata, fix in schema
//		private var _id:String;
		private var _description:String;
		private var _specification:String;
		private var _certification:String;
		
		private var _currentDateSource:ICurrentDateSource;
		
		public function Equipment(equipmentReportXML:XML)
		{
			parseDocumentMetadata(equipmentReportXML.Meta.Document[0], this);
			var equipmentXML:XML = equipmentReportXML.Item.Equipment[0];
			_dateStarted = DateUtil.parseW3CDTF(equipmentXML.dateStarted.toString());
			_dateStopped = DateUtil.parseW3CDTF(equipmentXML.dateStopped.toString());
//			_type = equipmentXML.type;
			_name = equipmentXML.name;
			_vendor = equipmentXML.vendor;
//			_id = equipmentXML.id;
			_description = equipmentXML.description;
			_specification = equipmentXML.specification;
			_certification = equipmentXML.certification;
			
//			_dateStarted = dateStarted;
//			_dateStopped = dateStopped;
//			_type = type;
//			_name = name;
//			_vendor = vendor;
//			_id = id;
//			_description = description;
//			_specification = specification;
//			_certification = certification;
			
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function get dateStarted():Date
		{
			return _dateStarted;
		}

		public function set dateStarted(value:Date):void
		{
			_dateStarted = value;
		}

		public function get dateStopped():Date
		{
			return _dateStopped;
		}

		public function set dateStopped(value:Date):void
		{
			_dateStopped = value;
		}

//		public function get type():String
//		{
//			return _type;
//		}
//
//		public function set type(value:String):void
//		{
//			_type = value;
//		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get vendor():String
		{
			return _vendor;
		}

		public function set vendor(value:String):void
		{
			_vendor = value;
		}

//		public function get id():String
//		{
//			return _id;
//		}
//
//		public function set id(value:String):void
//		{
//			_id = value;
//		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get specification():String
		{
			return _specification;
		}

		public function set specification(value:String):void
		{
			_specification = value;
		}

		public function get certification():String
		{
			return _certification;
		}

		public function set certification(value:String):void
		{
			_certification = value;
		}
		
		public function get isInactive():Boolean
		{
			if (_dateStopped != null)
			{
				return _dateStopped < _currentDateSource.now();
			}
			return false;
		}

	}
}