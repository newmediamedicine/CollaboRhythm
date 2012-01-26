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
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.*;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;

	import com.adobe.utils.DateUtil;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	public class MedicationAdministrationsHealthRecordService extends DocumentStorageServiceBase
	{
		private var _medicationAdministrationsModel:MedicationAdministrationsModel;
		// To test, try setting _autoUpdateInterval to something short, like 20 seconds (1000 * 20)
		private var _autoUpdateInterval:Number = 1000 * 60 * 60;
		private var _nextAutoUpdate:Date;
		private var _autoUpdateTimer:Timer = new Timer(0);
		private var _autoUpdateCushion:Number = 1000;

		public function MedicationAdministrationsHealthRecordService(consumerKey:String, consumerSecret:String,
																	 baseURL:String, account:Account,
																	 debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled,
				  MedicationAdministration.DOCUMENT_TYPE, MedicationAdministration,
				  Schemas.MedicationAdministrationSchema);

			_autoUpdateTimer.addEventListener(TimerEvent.TIMER, autoUpdateTimer_timerHandler, false, 0, true);
			_currentDateSource.addEventListener(Event.CHANGE, currentDateSource_changeHandler, false, 0, true);
		}

        override public function loadDocuments(record:Record):void
        {
			super.loadDocuments(record);

			// TODO: figure out what is wrong with order_by for this report; it is currently causing an error
			var params:URLVariables = new URLVariables();
//			params["order_by"] = "date_administered";

			var medicationAdministrationsModel:MedicationAdministrationsModel = record.medicationAdministrationsModel;
			medicationAdministrationsModel.isInitialized = false;
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(null, null, record);
            _pha.reports_minimal_X_GET(params, null, null, null, record.id, "medicationadministrations", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
			var medicationAdministrationsModel:MedicationAdministrationsModel = healthRecordServiceRequestDetails.record.medicationAdministrationsModel;
			parseMedicationAdministrationsReportXml(responseXml, healthRecordServiceRequestDetails.record);
			createMedicationConcentrationCollections(medicationAdministrationsModel);
			medicationAdministrationsModel.isInitialized = true;

			super.handleResponse(event, responseXml, healthRecordServiceRequestDetails);
        }

		public function parseMedicationAdministrationsReportXml(value:XML, record:Record):void
		{
			// clear any data that may have been previously loaded
			record.medicationAdministrationsModel.clearMedicationAdministrations();

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			var data:ArrayCollection = new ArrayCollection();

            for each (var medicationAdministrationXml:XML in value.Report)
            {
                var medicationAdministration:MedicationAdministration = unmarshallReportXml(medicationAdministrationXml) as MedicationAdministration;
				DocumentMetadata.parseDocumentMetadata(medicationAdministrationXml.Meta.Document[0], medicationAdministration.meta);
				loadReplacedDocuments(record, medicationAdministration);
                if (medicationAdministration)
				{
					if (medicationAdministration.dateAdministered.valueOf() <= nowTime && medicationAdministration.dateReported.valueOf() <= nowTime)
					{
						data.addItem(medicationAdministration);
					}
				}
            }

			// TODO: get order_by working and remove this sorting
			data = new ArrayCollection(data.toArray().sortOn("dateAdministeredValue", Array.NUMERIC));

			for each (medicationAdministration in data)
			{
				record.addDocument(medicationAdministration);
			}
		}

		public function initFromReportXML(reportXml:XML, medicationAdministration:MedicationAdministration):Boolean
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			if (DocumentMetadata.validateDocumentMetadata(reportXml.Meta.Document[0]))
			{
				DocumentMetadata.parseDocumentMetadata(reportXml.Meta.Document[0], medicationAdministration.meta);
				var medicationAdministrationXml:XML = reportXml.Item.MedicationAdministration[0];
				medicationAdministration.name = HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.name[0]);
				medicationAdministration.reportedBy = medicationAdministrationXml.reportedBy;
				medicationAdministration.dateReported = collaboRhythm.shared.model.DateUtil.parseW3CDTF(medicationAdministrationXml.dateReported.toString());
				medicationAdministration.dateAdministered = collaboRhythm.shared.model.DateUtil.parseW3CDTF(medicationAdministrationXml.dateAdministered.toString());
				medicationAdministration.amountAdministered = new ValueAndUnit(medicationAdministrationXml.amountAdministered.value, HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.amountAdministered.unit[0]));
				if (medicationAdministrationXml.amountRemaining[0])
					medicationAdministration.amountRemaining = new ValueAndUnit(medicationAdministrationXml.amountRemaining.value, HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.amountRemaining.unit[0]));

				_relationshipXmlMarshaller.unmarshallRelationships(reportXml, medicationAdministration);
				return true;
			}
			else
			{
				_logger.warn("Report does not contain valid metadata; document not loaded: " + reportXml.toXMLString());
				return false;
			}
		}

		public function convertToXML(medicationAdministration:MedicationAdministration):XML
		{
			var medicationAdministrationXml:XML = <MedicationAdministration/>;
			medicationAdministrationXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
			// TODO: Write a helper method for coded value to xml
			medicationAdministrationXml.name = medicationAdministration.name.text;
			medicationAdministrationXml.name.@type = medicationAdministration.name.type;
			medicationAdministrationXml.name.@value = medicationAdministration.name.value;
			medicationAdministrationXml.name.@abbrev = medicationAdministration.name.abbrev;
			medicationAdministrationXml.reportedBy = medicationAdministration.reportedBy;
			medicationAdministrationXml.dateOrdered = DateUtil.toW3CDTF(medicationAdministration.dateReported);
			if (medicationAdministration.dateAdministered)
				medicationAdministrationXml.dateExpires = DateUtil.toW3CDTF(medicationAdministration.dateAdministered);
			if (medicationAdministration.amountAdministered)
			{
				medicationAdministrationXml.amountAdministered.value = medicationAdministration.amountAdministered.value;
				medicationAdministrationXml.amountAdministered.unit = medicationAdministration.amountAdministered.unit.text;
				medicationAdministrationXml.amountAdministered.unit.@type = medicationAdministration.amountAdministered.unit.type;
				medicationAdministrationXml.amountAdministered.unit.@value = medicationAdministration.amountAdministered.unit.value;
				medicationAdministrationXml.amountAdministered.unit.@abbrev = medicationAdministration.amountAdministered.unit.abbrev;
			}
			if (medicationAdministration.amountRemaining)
			{
				medicationAdministrationXml.amountRemaining.value = medicationAdministration.amountRemaining.value;
				medicationAdministrationXml.amountRemaining.unit = medicationAdministration.amountRemaining.unit.text;
				medicationAdministrationXml.amountRemaining.unit.@type = medicationAdministration.amountRemaining.unit.type;
				medicationAdministrationXml.amountRemaining.unit.@value = medicationAdministration.amountRemaining.unit.value;
				medicationAdministrationXml.amountRemaining.unit.@abbrev = medicationAdministration.amountRemaining.unit.abbrev;
			}

			return medicationAdministrationXml;
		}

		private function createMedicationConcentrationCollections(medicationAdministrationsModel:MedicationAdministrationsModel):void
		{
			for each (var key:String in medicationAdministrationsModel.medicationAdministrationsCollectionsByCode.keys)
			{
				var administrationCollection:ArrayCollection = medicationAdministrationsModel.medicationAdministrationsCollectionsByCode[key];
				var builder:MedicationConcentrationCurveBuilder = new MedicationConcentrationCurveBuilder();
				builder.medicationAdministrationCollection = administrationCollection;
				// TODO: customize parameters of the pharmicokinetics (?) to match the current medication, person, dose, etc
				builder.calculateConcentrationCurve();
				medicationAdministrationsModel.medicationConcentrationCurvesByCode.put(key, builder.concentrationCurve);
				var firstMedicationAdministration:MedicationAdministration = administrationCollection[0];
				_logger.info("Calculated curve for " + firstMedicationAdministration.name.text + " (" + key + ") with " +
							 builder.concentrationCurve.length + " data points from " + administrationCollection.length + " MedicationAdministration documents");
			}
			_medicationAdministrationsModel = medicationAdministrationsModel;
			setAutoUpdateTimer(_currentDateSource.now());
		}

		private function autoUpdateTimer_timerHandler(event:TimerEvent):void
		{
			autoUpdateIfTimeElapsed();
		}

		private function currentDateSource_changeHandler(event:Event):void
		{
			autoUpdateIfTimeElapsed();
		}

		private function autoUpdateIfTimeElapsed():void
		{
			if (_nextAutoUpdate && _activeAccount)
			{
				var now:Date = _currentDateSource.now();
				if (now.valueOf() > _nextAutoUpdate.valueOf())
				{
					updateMedicationConcentrationCollections(_medicationAdministrationsModel);
					setAutoUpdateTimer(now);
				}
				else
				{
					resetAutoUpdateTimer(_nextAutoUpdate.valueOf() - now.valueOf())
				}
			}
		}

		/**
		 * Sets the time for _nextAutoUpdate and resets the timer
		 * @param now The current time
		 */
		private function setAutoUpdateTimer(now:Date):void
		{
			_nextAutoUpdate = new Date();
			_nextAutoUpdate.setTime(now.valueOf() + _autoUpdateInterval);
			resetAutoUpdateTimer(_autoUpdateInterval);
		}

		private function resetAutoUpdateTimer(delay:Number):void
		{
			_autoUpdateTimer.stop();
			_autoUpdateTimer.delay = delay + _autoUpdateCushion;
			_autoUpdateTimer.start();
		}

		private function updateMedicationConcentrationCollections(medicationAdministrationsModel:MedicationAdministrationsModel):void
		{
			for each (var key:String in medicationAdministrationsModel.medicationAdministrationsCollectionsByCode.keys)
			{
				var administrationCollection:ArrayCollection = medicationAdministrationsModel.medicationAdministrationsCollectionsByCode[key];
				var builder:MedicationConcentrationCurveBuilder = new MedicationConcentrationCurveBuilder();
				builder.medicationAdministrationCollection = administrationCollection;
				// TODO: customize parameters of the pharmicokinetics (?) to match the current medication, person, dose, etc
				builder.concentrationCurve = medicationAdministrationsModel.medicationConcentrationCurvesByCode.getItem(key);
				builder.updateConcentrationCurve();
				var firstMedicationAdministration:MedicationAdministration = administrationCollection[0];
				_logger.info("Updated curve for " + firstMedicationAdministration.name.text + " (" + key + ") with " +
							 builder.concentrationCurve.length + " data points from " + administrationCollection.length + " MedicationAdministration documents");
			}
			medicationAdministrationsModel.updateComplete();
		}
	}
}
