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
package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.*;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;

	public class EquipmentHealthRecordService extends DocumentStorageSingleReportServiceBase
	{
		public function EquipmentHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													 account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account,
				  Equipment.DOCUMENT_TYPE, Equipment, Schemas.EquipmentSchema, "equipment");
		}

		override protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			var equipment:Equipment = document as Equipment;
			return equipment.dateStarted.valueOf() <= nowTime;
		}

		override protected function unmarshallSpecialRelationships(reportXml:XML, document:IDocument):void
		{
			var equipment:Equipment = document as Equipment;
			for each (var scheduleItemXml:XML in reportXml..relatesTo.relation.(@type == ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM).relatedDocument)
			{
				equipment.scheduleItems.put(scheduleItemXml.@id, null);
			}
		}
	}
}