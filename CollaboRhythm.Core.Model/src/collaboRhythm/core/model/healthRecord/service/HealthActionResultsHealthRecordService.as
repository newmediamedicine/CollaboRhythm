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
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionGroupResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.DeviceResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Measurement;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;

	public class HealthActionResultsHealthRecordService extends DocumentStorageSingleReportServiceBase
	{
		public function HealthActionResultsHealthRecordService(consumerKey:String, consumerSecret:String,
																  baseURL:String, account:Account,
																  debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled,
				  HealthActionResult.DOCUMENT_TYPE, HealthActionResult, Schemas.HealthActionResultSchema,
				  "healthactionresults");
		}

		override protected function initializeXmlMarshaller():void
		{
			super.initializeXmlMarshaller();

			_xmlMarshaller.addSchema(Schemas.HealthActionResultSupportSchema);

			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "ActionResult"), ActionResult);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "ActionGroupResult"), ActionGroupResult);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "ActionStepResult"), ActionStepResult);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "DeviceResult"), DeviceResult);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "Measurement"), Measurement);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "MedicationAdministration"), MedicationAdministration);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "StopCondition"), StopCondition);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/HealthActionResult#", "Occurrence"), Occurrence);
		}
	}
}