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
package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	[Bindable]
	public class ScheduleItemOccurrence
	{
		private var _dateStart:Date;
		private var _dateEnd:Date;
		private var _recurrenceIndex:int;
		private var _scheduleItem:ScheduleItemBase;
		private var _adherenceItem:AdherenceItem;
		private var _moving:Boolean;
		private var _yPosition:int;
		private var _currentDateSource:ICurrentDateSource;

		public function ScheduleItemOccurrence(scheduleItem:ScheduleItemBase, dateStart:Date, dateEnd:Date,
											   recurrenceIndex:int)
		{
			_dateStart = dateStart;
			_dateEnd = dateEnd;
			_recurrenceIndex = recurrenceIndex;
			_scheduleItem = scheduleItem;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function createAdherenceItem(adherenceResults:Vector.<DocumentBase>,
											record:Record, reportedBy:String):void
		{
			adherenceItem = new AdherenceItem();
			adherenceItem.init(scheduleItem.name, reportedBy, _currentDateSource.now(), _recurrenceIndex,
					adherenceResults);

			adherenceItem.pendingAction = DocumentBase.ACTION_CREATE;
			record.addDocument(adherenceItem);
			record.addNewRelationship(ScheduleItemBase.RELATION_TYPE_ADHERENCE_ITEM,
					scheduleItem, adherenceItem);
			for each (var adherenceResult:DocumentBase in adherenceItem.adherenceResults)
			{
				adherenceResult.pendingAction = DocumentBase.ACTION_CREATE;
				record.addDocument(adherenceResult);
				record.addNewRelationship(AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT,
						adherenceItem, adherenceResult)
			}
		}

		public function voidAdherenceItem(record:Record):void
		{
			record.removeDocument(adherenceItem, DocumentBase.ACTION_VOID, "deleted by user", true);
			adherenceItem = null;
		}

		public function get recurrenceIndex():int
		{
			return _recurrenceIndex;
		}

		public function set recurrenceIndex(value:int):void
		{
			_recurrenceIndex = value;
		}

		public function get scheduleItem():ScheduleItemBase
		{
			return _scheduleItem;
		}

		public function set scheduleItem(value:ScheduleItemBase):void
		{
			_scheduleItem = value;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

		public function set adherenceItem(value:AdherenceItem):void
		{
			_adherenceItem = value;
		}

		public function get dateStart():Date
		{
			return _dateStart;
		}

		public function set dateStart(value:Date):void
		{
			_dateStart = value;
		}

		public function get dateEnd():Date
		{
			return _dateEnd;
		}

		public function set dateEnd(value:Date):void
		{
			_dateEnd = value;
		}

		public function get moving():Boolean
		{
			return _moving;
		}

		public function set moving(value:Boolean):void
		{
			_moving = value;
		}

		public function get yPosition():int
		{
			return _yPosition;
		}

		public function set yPosition(value:int):void
		{
			_yPosition = value;
		}

		/**
		 * The unique deterministic identifier of this occurrence. The id combines the document id of the associated
		 * schedule item and the recurrence index.
		 */
		public function get id():String
		{
			return scheduleItem.meta.id + "." + recurrenceIndex;
		}
	}
}
