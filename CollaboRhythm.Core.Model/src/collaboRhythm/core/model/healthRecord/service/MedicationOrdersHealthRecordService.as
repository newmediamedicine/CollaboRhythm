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
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;

	public class MedicationOrdersHealthRecordService extends DocumentStorageSingleReportServiceBase
	{

		public function MedicationOrdersHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
															account:Account, debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, MedicationOrder.DOCUMENT_TYPE,
				  MedicationOrder, Schemas.MedicationOrderSchema, "medicationorders");
		}
		
		override protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			var medicationOrder:MedicationOrder = document as MedicationOrder;
			return medicationOrder.dateOrdered == null || medicationOrder.dateOrdered.valueOf() <= nowTime;
		}

		override public function unmarshallReportXml(reportXml:XML):IDocument
		{
//			return super.unmarshallReportXml(reportXml);
			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.initFromReportXML(reportXml);
			return medicationOrder;
		}
	}
}