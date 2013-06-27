package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.Event;

	import flash.events.TimerEvent;

	import flash.utils.Timer;

	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class MedicationConcentrationCurvesBuilder
	{
		protected var _logger:ILogger;
		protected var _currentDateSource:ICurrentDateSource;

		private var _record:Record;
		// To test, try setting _autoUpdateInterval to something short, like 20 seconds (1000 * 20)
		private var _autoUpdateInterval:Number = 1000 * 60 * 60;
		private var _nextAutoUpdate:Date;
		private var _autoUpdateTimer:Timer = new Timer(0);
		private var _autoUpdateCushion:Number = 1000;

		public function MedicationConcentrationCurvesBuilder()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			_autoUpdateTimer.addEventListener(TimerEvent.TIMER, autoUpdateTimer_timerHandler, false, 0, true);
			_currentDateSource.addEventListener(Event.CHANGE, currentDateSource_changeHandler, false, 0, true);
		}
		public function createMedicationConcentrationCollections(record:Record):void
		{
			_record = record;
			var adherenceItemsModel:AdherenceItemsModel = _record.adherenceItemsModel;
			var medicationAdministrationsModel:MedicationAdministrationsModel = _record.medicationAdministrationsModel;

			for each (var key:String in adherenceItemsModel.adherenceItemsCollectionsByCode.keys)
			{
				var adherenceItemsCollection:ArrayCollection = adherenceItemsModel.adherenceItemsCollectionsByCode[key];
				var builder:MedicationConcentrationCurveBuilder = new MedicationConcentrationCurveBuilder();
				builder.medicationAdministrationCollection = adherenceItemsCollection;
				// TODO: customize parameters of the pharmicokinetics (?) to match the current medication, person, dose, etc
				builder.calculateConcentrationCurve();
				medicationAdministrationsModel.medicationConcentrationCurvesByCode.put(key, builder.concentrationCurve);
				var firstAdherenceItem:AdherenceItem = adherenceItemsCollection[0];
				_logger.info("Calculated curve for " + firstAdherenceItem.name.text + " (" + key + ") with " +
							 builder.concentrationCurve.length + " data points from " + adherenceItemsCollection.length + " AdherenceItem documents");
			}
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
			if (_nextAutoUpdate && _record)
			{
				var now:Date = _currentDateSource.now();
				if (now.valueOf() > _nextAutoUpdate.valueOf())
				{
					updateMedicationConcentrationCollections();
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

		private function updateMedicationConcentrationCollections():void
		{
			var adherenceItemsModel:AdherenceItemsModel = _record.adherenceItemsModel;
			var medicationAdministrationsModel:MedicationAdministrationsModel = _record.medicationAdministrationsModel;
			for each (var key:String in adherenceItemsModel.adherenceItemsCollectionsByCode.keys)
			{
				var adherenceItemsCollection:ArrayCollection = adherenceItemsModel.adherenceItemsCollectionsByCode[key];
				var builder:MedicationConcentrationCurveBuilder = new MedicationConcentrationCurveBuilder();
				builder.medicationAdministrationCollection = adherenceItemsCollection;
				// TODO: customize parameters of the pharmicokinetics (?) to match the current medication, person, dose, etc
				builder.concentrationCurve = medicationAdministrationsModel.medicationConcentrationCurvesByCode.getItem(key);
				builder.updateConcentrationCurve();
				var firstAdherenceItemName:String = adherenceItemsCollection.length > 0 ? adherenceItemsCollection[0].name.text : "some medication";
				_logger.info("Updated curve for " + firstAdherenceItemName + " (" + key + ") with " +
							 builder.concentrationCurve.length + " data points from " + adherenceItemsCollection.length + " AdherenceItem documents");
			}
			medicationAdministrationsModel.updateComplete();
		}
	}
}
