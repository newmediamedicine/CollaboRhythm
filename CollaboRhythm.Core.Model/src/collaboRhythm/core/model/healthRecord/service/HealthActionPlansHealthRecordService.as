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
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.Action;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionGroup;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionStep;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.DevicePlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.MeasurementPlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.MedicationPlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.StopCondition;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.Target;

	public class HealthActionPlansHealthRecordService extends DocumentStorageSingleReportServiceBase
	{
		public function HealthActionPlansHealthRecordService(consumerKey:String, consumerSecret:String,
																  baseURL:String, account:Account,
																  debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled,
				  HealthActionPlan.DOCUMENT_TYPE, HealthActionPlan, Schemas.HealthActionPlanSchema,
				  "HealthActionPlan");
		}

		override protected function initializeXmlMarshaller():void
		{
			super.initializeXmlMarshaller();

			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "Action"), Action);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "ActionGroup"), ActionGroup);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "ActionStep"), ActionStep);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "DevicePlan"), DevicePlan);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "MeasurementPlan"), MeasurementPlan);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "MedicationPlan"), MedicationPlan);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "StopCondition"), StopCondition);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents/healthActionPlan#", "Target"), Target);
		}
	}
}