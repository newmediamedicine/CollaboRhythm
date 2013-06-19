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

	public class MedicationAdministrationsHealthRecordService extends DocumentStorageSingleReportServiceBase
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
				  Schemas.MedicationAdministrationSchema, "MedicationAdministration", "dateAdministered", 1000, "dateAdministeredValue");

			_autoUpdateTimer.addEventListener(TimerEvent.TIMER, autoUpdateTimer_timerHandler, false, 0, true);
			_currentDateSource.addEventListener(Event.CHANGE, currentDateSource_changeHandler, false, 0, true);
		}

		override protected function updateModelAfterHandleReportResponse(event:IndivoClientEvent, responseXml:XML,
														   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.updateModelAfterHandleReportResponse(event, responseXml, healthRecordServiceRequestDetails);

			var medicationAdministrationsModel:MedicationAdministrationsModel = healthRecordServiceRequestDetails.record.medicationAdministrationsModel;
			createMedicationConcentrationCollections(medicationAdministrationsModel);
		}

		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
			// TODO: we don't clear the model for any other *HealthRecordService; is it really necessary to do it here?
			// clear any data that may have been previously loaded
			healthRecordServiceRequestDetails.record.medicationAdministrationsModel.clearMedicationAdministrations();

			super.handleResponse(event, responseXml, healthRecordServiceRequestDetails);
        }

		public function createMedicationConcentrationCollections(medicationAdministrationsModel:MedicationAdministrationsModel):void
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
				var firstMedicationAdministrationName:String = administrationCollection.length > 0 ? administrationCollection[0].name.text : "some medication";
				_logger.info("Updated curve for " + firstMedicationAdministrationName + " (" + key + ") with " +
							 builder.concentrationCurve.length + " data points from " + administrationCollection.length + " MedicationAdministration documents");
			}
			medicationAdministrationsModel.updateComplete();
		}
	}
}
