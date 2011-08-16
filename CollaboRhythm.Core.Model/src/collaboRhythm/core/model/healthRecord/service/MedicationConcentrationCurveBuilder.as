package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.healthRecord.derived.MedicationConcentrationSample;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	public class MedicationConcentrationCurveBuilder
	{
		private var matchStartDateOfSource:Boolean = true;
		private var _data:ArrayCollection;
		private var _concentrationCurve:ArrayCollection;
		private var _medicationAdministrationCollection:ArrayCollection;
		private var _currentDateSource:ICurrentDateSource;

//		private var _intervalDuration:Number = 2 * 1000 * 60 * 60;
		private var _intervalDuration:Number = 1000 * 60 * 10;
		// duration of one interval in milliseconds (1000 ms * 60 sec * 60 min = 1 hour)
//		private const intervalDuration:Number = 10 * 1000 * 60 * 60; // duration of one interval in milliseconds (1000 ms * 60 sec * 60 min = 1 hour)

		public function MedicationConcentrationCurveBuilder()
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function get concentrationCurve():ArrayCollection
		{
			return _concentrationCurve;
		}

		public function set concentrationCurve(value:ArrayCollection):void
		{
			_concentrationCurve = value;
		}

		public function set medicationAdministrationCollection(adherenceData:ArrayCollection):void
		{
			_medicationAdministrationCollection = adherenceData;
		}

		public function get medicationAdministrationCollection():ArrayCollection
		{
			return _medicationAdministrationCollection;
		}

		public function get data():ArrayCollection
		{
			return _data;
		}

		public function set data(value:ArrayCollection):void
		{
			_data = value;
		}

		private function extendConcentrationCurveCollection(concentrationCurveCollection:ArrayCollection, startDate:Date, intervals:Number, maxTime:Number):ArrayCollection
		{
			for (var interval:Number = 0; interval < intervals; interval++)
			{
				var time:Number = startDate.time + (interval * intervalDuration);
				if (time > maxTime)
					break;
				var dataItem:MedicationConcentrationSample = new MedicationConcentrationSample();
				var date:Date = new Date(time);
				dataItem.date = date;
				dataItem.concentration = 0;
				concentrationCurveCollection.addItem(dataItem);
			}

			return concentrationCurveCollection;
		}

		// TODO: update the showAdherence flag
		public function calculateConcentrationCurve():void
		{
			if (medicationAdministrationCollection && medicationAdministrationCollection.length > 0)
			{
				var singleCurve:Array = calculateSingleDoseCurve();

				var currentConcentrationCurve:ArrayCollection = new ArrayCollection();
				var previousAdministrationIndex:int = 0; // index into medicationAdministrationCollection for beginning of previous curve

				var maxTime:Number = currentDateSource.now().time;
				var lastMedicationAdministration:MedicationAdministration = medicationAdministrationCollection[medicationAdministrationCollection.length - 1];
				var lastAdministrationDate:Date = lastMedicationAdministration.dateAdministered;
				maxTime = Math.min(maxTime, lastAdministrationDate.time + singleCurve.length * intervalDuration);

				if (matchStartDateOfSource)
				{
					// start with a date for the curve that matches the first data point in the main data set
					if (medicationAdministrationCollection.length > 0 && data && data.length > 0)
						extendConcentrationCurveCollection(currentConcentrationCurve, data[0].date, 1, maxTime);
				}

				for each (var dataItem:MedicationAdministration in medicationAdministrationCollection)
				{
					var intervalsToAdvance:int;
					if (currentConcentrationCurve.length > 0)
					{
						// determine where in the curve to align this curve
						var previousDate:Date = currentConcentrationCurve[previousAdministrationIndex].date;

/*
						// validate that the current date is not before the previous date
						if (dataItem.dateAdministered.time < previousDate.time)
							throw new Error("Dates are not in ascending order: " + previousDate.toString() + ", " + dataItem.dateAdministered.toString());
*/

						intervalsToAdvance = Math.ceil((dataItem.dateAdministered.time - previousDate.time) / intervalDuration);
					}
					else
					{
						intervalsToAdvance = 0;
					}

					var additionalIntervalsRequired:int;
					var extensionStartDate:Date;

					/**
					 * Index into currentConcentrationCurve corresponding to the start of the current administration
					 */
					var currentAdministrationIndex:int;

					if (previousAdministrationIndex + intervalsToAdvance > currentConcentrationCurve.length - 1)
					{
						// curve of current dose starts beyond the end of the complete curve (end of previous curve)
						currentAdministrationIndex = currentConcentrationCurve.length;
						additionalIntervalsRequired = singleCurve.length;
						extensionStartDate = dataItem.dateAdministered;
					}
					else
					{
						// curve of current dose overlaps complete curve (starts before the end of the previous curve)
						currentAdministrationIndex = previousAdministrationIndex + intervalsToAdvance;
						var intervalsAvailable:int = currentConcentrationCurve.length - 1 - currentAdministrationIndex;
						additionalIntervalsRequired = singleCurve.length - intervalsAvailable;
						extensionStartDate = new Date(currentConcentrationCurve[currentConcentrationCurve.length - 1].date.time + intervalDuration);
					}

					extendConcentrationCurveCollection(currentConcentrationCurve, extensionStartDate,
												   additionalIntervalsRequired, maxTime);

					if (currentAdministrationIndex >= currentConcentrationCurve.length)
						break;

					var index:Number = 0;
					for each (var value:Number in singleCurve)
					{
						if (currentAdministrationIndex + index >= currentConcentrationCurve.length)
							break;

						currentConcentrationCurve[currentAdministrationIndex + index].concentration += value;
						index += 1;
					}

					// prepare for next iteration
					previousAdministrationIndex = currentAdministrationIndex;
				}

				if (currentConcentrationCurve.length > 0)
				{
					var lastConcentrationCurveDate:Date = currentConcentrationCurve[currentConcentrationCurve.length - 1].date;
					if (lastAdministrationDate.time > lastConcentrationCurveDate.time)
					{
						extendConcentrationCurveCollection(currentConcentrationCurve, lastAdministrationDate, 1,
														   maxTime);

						// avoid having a zero value for concentration
						currentConcentrationCurve[currentConcentrationCurve.length - 1].concentration = currentConcentrationCurve[currentConcentrationCurve.length - 2].concentration;
					}
				}

				concentrationCurve = currentConcentrationCurve;
			}
			else
			{
				// no adherence data; use an empty ArrayCollection
				concentrationCurve = new ArrayCollection();
			}
		}

		private function calculateSingleDoseCurve():Array
		{
			var D:Number = 25;
			var F:Number = 0.55;
			var Ka:Number = Math.log(2)/0.5;
			var Ke:Number = Math.log(2)/15;
			var Vd:Number = 45.5;

			// conversion from interval index to time in hours
			var intervalToTimeConversion:Number = intervalDuration / (1000 * 60 * 60);
			const singleCurveIntervalCount:int = 100 / intervalToTimeConversion;

			var singleCurve:Array = new Array(singleCurveIntervalCount);

			for (var i:Number=0; i<singleCurveIntervalCount; i++)
			{
				var t:Number = i * intervalToTimeConversion;
				var concentration:Number = ((F * D * Ka) / (Vd * (Ka - Ke))) * ((Math.exp(-Ke*t)) - Math.exp((-Ka*t)));
				singleCurve[i] = concentration;
			}

			return singleCurve;
		}

		public function extendBeginningOfAdherenceCurveCollection(date:Date):void
		{
			if (matchStartDateOfSource)
			{
				// start with a date for the curve that matches the first data point in the main data set
				if (concentrationCurve && concentrationCurve.length > 0 && date)
				{
					var dataItem:MedicationConcentrationSample = new MedicationConcentrationSample();
					dataItem.date = date;
					dataItem.concentration = 0;
					concentrationCurve.addItemAt(dataItem, 0);
				}
			}
		}

		public function get intervalDuration():Number
		{
			return _intervalDuration;
		}

		public function set intervalDuration(value:Number):void
		{
			_intervalDuration = value;
		}
	}
}
