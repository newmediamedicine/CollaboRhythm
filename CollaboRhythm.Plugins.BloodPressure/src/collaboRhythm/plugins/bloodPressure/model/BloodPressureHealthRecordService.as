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
package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.apps.bloodPressure.model.AdherenceItem;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureDataItem;
	import collaboRhythm.shared.apps.bloodPressure.model.ConcentrationSeverityProvider;
	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;
	import collaboRhythm.shared.apps.bloodPressure.model.StepsProvider;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

	import flash.net.URLVariables;
	import flash.xml.XMLDocument;

	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;

	import org.indivo.client.IndivoClientEvent;

	public class BloodPressureHealthRecordService extends PhaHealthRecordServiceBase
	{
		private const systolicCategory:String = "Blood Pressure Systolic";
		private const diastolicCategory:String = "Blood Pressure Diastolic";

		private static const VITALS_REPORT:String = "vitals";
		private static const ADHERENCE_ITEMS_REPORT:String = "adherenceitems";

		private static const millisecondsPerHour:int = 1000 * 60 * 60;

		public function BloodPressureHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		public function loadBloodPressure(recordAccount:Account):void
		{
			// clear any existing data
			recordAccount.bloodPressureModel.data = null;
			recordAccount.bloodPressureModel.isSystolicReportLoaded = false;
			recordAccount.bloodPressureModel.isDiastolicReportLoaded = false;

			var params:URLVariables = new URLVariables();
			params["order_by"] = "date_measured_start";

			if (recordAccount.primaryRecord != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
			{
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, recordAccount.primaryRecord.id, systolicCategory, _activeAccount.oauthAccountToken,
												  _activeAccount.oauthAccountTokenSecret,
												  new BloodPressureReportUserData(recordAccount, VITALS_REPORT, systolicCategory));
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, recordAccount.primaryRecord.id, diastolicCategory, _activeAccount.oauthAccountToken,
												  _activeAccount.oauthAccountTokenSecret,
												  new BloodPressureReportUserData(recordAccount, VITALS_REPORT, diastolicCategory));

				// TODO: figure out what is wrong with order_by for this report; it is currently causing an error
//				var adherenceParams:URLVariables = new URLVariables();
//				adherenceParams["order_by"] = "date_reported";
				_pha.reports_minimal_X_GET(null, null, null, null, recordAccount.primaryRecord.id, ADHERENCE_ITEMS_REPORT, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, new BloodPressureReportUserData(recordAccount, ADHERENCE_ITEMS_REPORT))
			}
		}

		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (responseXml.localName() == "Reports")
			{
				var bloodPressureReportUserData:BloodPressureReportUserData = event.userData as BloodPressureReportUserData;
				if (bloodPressureReportUserData == null)
					throw new Error("userData must be a BloodPressureReportUserData object");

				var account:Account = bloodPressureReportUserData.account;
				if (account == null)
					throw new Error("userData.user must be a User object");

				if (bloodPressureReportUserData.report == VITALS_REPORT)
				{
					if (responseXml.Report.Item.VitalSign.length() > 0)
					{
						account.bloodPressureModel.data = parseVitalSignReportData(responseXml,
																	   getFieldNameFromCategory(bloodPressureReportUserData.category),
																	   account.bloodPressureModel.data);

						if (bloodPressureReportUserData.category == systolicCategory)
							account.bloodPressureModel.isSystolicReportLoaded = true;
						else if (bloodPressureReportUserData.category == diastolicCategory)
							account.bloodPressureModel.isDiastolicReportLoaded = true;
					}
				}
				else if (bloodPressureReportUserData.report == ADHERENCE_ITEMS_REPORT)
				{
					account.bloodPressureModel.adherenceData = parseAdherenceItemReportData(responseXml);
					initializeMedicationSimulationModel(account.bloodPressureModel.simulation, responseXml);
				}
			}
			else
			{
				throw new Error("Unexpected response: " + responseXml);
			}
		}

		private static const _hydrochlorothiazideCode:String = "310798";
		private static const _atenololCode:String = "??????";

		private function initializeMedicationSimulationModel(simulation:SimulationModel, responseXml:XML):void
		{
			for each (var itemXml:XML in responseXml.Report.Item.AdherenceItem)
			{
				if (itemXml.name.length() == 1)
				{
					var name:CodedValue = HealthRecordHelperMethods.xmlToCodedValue(itemXml.name[0]);

					var index:int = simulation.medicationsByCode.getIndexByKey(name.value);
					if (index == -1)
					{
						var medication:MedicationComponentAdherenceModel = new MedicationComponentAdherenceModel();

						medication.name = name;

						// TODO: get steps from an external source
						if (name.value == _hydrochlorothiazideCode)
						{
							initializeHydrochlorothiazideModel(medication);
						}
						else if (name.value == _atenololCode)
						{
							initializeAtenololModel(medication);
						}

						simulation.addMedication(medication);
					}
				}
			}
		}

		private function initializeHydrochlorothiazideModel(medication:MedicationComponentAdherenceModel):void
		{
			medication.drugClass = "Thiazide Diuretic";
			medication.stepsProvider = new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "Urine volume decreased",
																 "Venous blood volume increased",
																 "Preload on heart increased",
															 	 "Stroke volume of heart increased",
															 	 "Blood pressure increased"],
															 new <String>[
																 "Urine volume increased",
																 "Venous blood volume decreased",
																 "Preload on heart decreased",
															 	 "Stroke volume of heart decreased",
															 	 "Blood pressure decreased"],
															 new <String>[
																 "Urine volume increased",
																 "Venous blood volume decreased",
																 "Preload on heart decreased",
															 	 "Stroke volume of heart decreased",
															 	 "Blood pressure decreased"]
														 ]);
			medication.concentrationSeverityProvider = new ConcentrationSeverityProvider(SimulationModel.concentrationRanges,
																						 SimulationModel.concentrationColors);
		}

		private function initializeAtenololModel(medication:MedicationComponentAdherenceModel):void
		{
			medication.drugClass = "Beta Blocker";
			medication.stepsProvider = new StepsProvider(new <Number>[SimulationModel.HYDROCHLOROTHIAZIDE_LOW, SimulationModel.HYDROCHLOROTHIAZIDE_GOAL],
														 new <Vector.<String>>[
															 new <String>[
																 "Atenolol very low step 1",
																 "Atenolol very low step 2",
																 "Atenolol very low step 3"
															 	 ],
															 new <String>[
																 "Atenolol low step 1",
																 "Atenolol low step 2",
																 "Atenolol low step 3",
															 	 "Atenolol low step 4"
															 	 ],
															 new <String>[
																 "Atenolol at goal step 1",
																 "Atenolol at goal step 2",
																 "Atenolol at goal step 3",
															 	 "Atenolol at goal step 4",
															 	 "Atenolol at goal step 5"]
														 ]);
			medication.concentrationSeverityProvider = new ConcentrationSeverityProvider(SimulationModel.concentrationRanges,
																						 SimulationModel.concentrationColors);
		}


		private function getFieldNameFromCategory(category:String):String
		{
			if (category == systolicCategory)
				return "systolic";
			else if (category == diastolicCategory)
				return "diastolic";
			else
				throw new Error("Unhandled category value " + category)
		}

		private function parseVitalSignReportData(responseXml:XML, valueFieldName:String,
										 data:ArrayCollection=null):ArrayCollection
		{
			var searchForExistingData:Boolean;
			if (data == null || data.length == 0)
				data = new ArrayCollection();
			else
				searchForExistingData = true;

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			var i:int = 0;

			for each (var itemXml:XML in responseXml.Report.Item.VitalSign)
			{
				var dateMeasuredStartString:String = itemXml.dateMeasuredStart.toString();
				var dateMeasuredStart:Date = DateUtil.parseW3CDTF(dateMeasuredStartString);

				// TODO: should we do anything with unit, site, or position?
				if (dateMeasuredStart.valueOf() > nowTime)
				{
					break;
				}
				else
				{
					var item:BloodPressureDataItem;
					if (searchForExistingData)
					{
						if (data.length > i && datesAreClose(data[i].date, dateMeasuredStart))
						{
							item = data[i];
							i++;
						}
						else
						{
							// TODO: implement searching; implement creating a new instance if not found
							throw new Error("Date does not match for index " + i.toString() +
													". Expected: " + dateMeasuredStart.toString() +
													" Found: " + ((data.length > i) ? data[i].date.toString() : "(data.length = " + data.length + ")"));
						}
					}
					else
					{
						item = new BloodPressureDataItem();
						data.addItem(item);
					}

					item.date = dateMeasuredStart;

					item[valueFieldName] = itemXml.result.value.toString();
				}
			}
			return data;
		}

		private function parseAdherenceItemReportData(responseXml:XML):ArrayCollection
		{
			var data:ArrayCollection = new ArrayCollection();

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			for each (var itemXml:XML in responseXml.Report.Item.AdherenceItem)
			{
				var dateReportedString:String = itemXml.dateReported.toString();
				var dateReported:Date = DateUtil.parseW3CDTF(dateReportedString);

				if (dateReported.valueOf() > nowTime)
				{
					// TODO: get order_by working and then we can optimize by breaking here instead of continuing to parse all data
//					break;
				}
				else
				{
					var item:AdherenceItem;
					item = new AdherenceItem();

					if (itemXml.name.length() == 1)
						item.name = HealthRecordHelperMethods.xmlToCodedValue(itemXml.name[0]);
					if (itemXml.reportedBy.length() == 1)
						item.reportedBy = itemXml.reportedBy.toString();
					if (itemXml.dateReported.length() == 1)
						item.dateReported = dateReported;
					if (itemXml.adherence.length() == 1)
						item.adherence = itemXml.adherence.toString() == true.toString();
					if (itemXml.nonadherenceReason.length() == 1)
						item.nonAdherenceReason = itemXml.nonadherenceReason.toString() == true.toString();

					data.addItem(item);
				}
			}

			// TODO: get order_by working and remove this sorting
			data = new ArrayCollection(data.toArray().sortOn("dateValue", Array.NUMERIC));

			return data;
		}

		private function datesAreClose(date1:Date, date2:Date):Boolean
		{
			return (Math.abs(date1.time - date2.time) < millisecondsPerHour * 12);
		}

		private function xmlToArrayCollection(xml:XML):ArrayCollection
		{
			var xmlDoc:XMLDocument = new XMLDocument(xml.toString());
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
			var resultObj:Object = decoder.decodeXML(xmlDoc);
			//			var ac:ArrayCollection = new ArrayCollection(new Array(resultObj.root.list.source.item));
			var ac:ArrayCollection = resultObj.BloodPressureData.data;
			return ac;
			//			var temp:String = '<items>' + xml.toString() + '</items>';
			//			xml = XML(temp);
			//			var xmlDoc:XMLDocument = new XMLDocument(xml.toString());
			//			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
			//			var resultObj:Object = decoder.decodeXML(xmlDoc);
			//			var ac:ArrayCollection;
			//			ac = new ArrayCollection();
			//			ac.addItem(resultObj.items);
			//			return ac;
		}
	}
}