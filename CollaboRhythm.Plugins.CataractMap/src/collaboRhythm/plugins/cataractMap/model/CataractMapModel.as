/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.cataractMap.model
{
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import com.hurlant.crypto.symmetric.NullPad;
	
	import mx.collections.ArrayCollection;

	public class CataractMapModel
	{
		private var _rawData:XML;
		private var _data:ArrayCollection;
		private var _currentDateSource:ICurrentDateSource;
		private var _adherenceDataCollection:ArrayCollection;
		private var _showFps:Boolean;
		private var _simulation:SimulationModel = new SimulationModel();
		public static const CATARACT_MAP_KEY:String = "cataractMap";

		public function get rawData():XML
		{
			return _rawData;
		}

		public function set rawData(value:XML):void
		{
			_rawData = value;
		}

		[Bindable]
		public function get simulation():SimulationModel
		{
			return _simulation;
		}

		public function set simulation(value:SimulationModel):void
		{
			_simulation = value;
		}

//		public function get showHeartRate():Boolean
//		{
//			return _showHeartRate;
//		}
//
//		public function get showAdherence():Boolean
//		{
//			return _showAdherence;
//		}

		[Bindable]
		public function get showFps():Boolean
		{
			return _showFps;
		}

		public function set showFps(value:Boolean):void
		{
			_showFps = value;
		}


		[Bindable]
		public function get adherenceDataCollection():ArrayCollection
		{
			return _adherenceDataCollection;
		}

		public function set adherenceDataCollection(value:ArrayCollection):void
		{
			_adherenceDataCollection = value;
		}


		public function CataractMapModel()
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}
		
		private const intervalDuration:Number = 2 * 1000 * 60 * 60; // duration of one interval in milliseconds (1000 ms * 60 sec * 60 min = 1 hour)
		
		private function extendAdherenceCurveCollection(adherenceCurveCollection:ArrayCollection, startDate:Date, intervals:Number, nowTime:Number):ArrayCollection
		{
			for (var interval:Number = 0; interval < intervals; interval++)
			{
				var time:Number = startDate.time + (interval * intervalDuration);
				if (time > nowTime)
					break;
				var dataItem:Object = new Object();
				var date:Date = new Date(time);
				dataItem["date"] = date;
				dataItem["concentration"] = 0;
				adherenceCurveCollection.addItem(dataItem);
			}
			
			return adherenceCurveCollection;
		}
		
		private var matchStartDateOfSource:Boolean = true;

		public function calculateAdherenceCurve():void
		{
			var singleCurve:Array = calculateSingleDoseCurve();
			
			var adherenceCurveCollection:ArrayCollection = new ArrayCollection();
			var previousAdherenceIndex:int = 0; // index into adherenceDataCollection for beginning of previous curve 
			
			var nowTime:Number = currentDateSource.now().time;
			var lastAdherenceDate:Date = _data[_data.length-1]["date"];
			nowTime = Math.min(nowTime, lastAdherenceDate.time);

			if (matchStartDateOfSource)
			{
				// start with a date for the curve that matches the first data point in the main data set
				if (_data.length > 0)
					extendAdherenceCurveCollection(adherenceCurveCollection, _data[0].date, 1, nowTime);
			}
			
//			_showAdherence = false;
			
			for each (var dataItem:Object in _data)
			{
//				trace("Current date", dataItem.date);
				if (dataItem.hasOwnProperty("adherence") == true)
				{
//					_showAdherence = true;
					
					var adherent:Boolean = dataItem["adherence"] == "yes";
					var intervalsToAdvance:int;
					if (adherenceCurveCollection.length > 0)
					{
						// determine where in the curve to align this curve
						var previousDate:Date = adherenceCurveCollection[previousAdherenceIndex].date;
						
						// validate that the current date is not before the previous date
						if (dataItem.date.time < previousDate.time)
							throw new Error("Dates are not in ascending order: " + previousDate.toString() + ", " + dataItem.date.toString());
						
						intervalsToAdvance = (dataItem.date.time - previousDate.time) / intervalDuration;
					}
					else
					{
						intervalsToAdvance = 0;
					}
					
					var additionalIntervalsRequired:int;
					var extensionStartDate:Date;
					var currentAdherenceIndex:int;
					
					if (previousAdherenceIndex + intervalsToAdvance > adherenceCurveCollection.length - 1)
					{
						// curve of current dose starts beyond the end of the complete curve (end of previous curve)
						currentAdherenceIndex = adherenceCurveCollection.length;
						additionalIntervalsRequired = adherent ? singleCurve.length : 1;
						extensionStartDate = dataItem.date;
					}
					else
					{
						// curve of current dose overlaps complete curve (starts before the end of the previous curve)
						currentAdherenceIndex = previousAdherenceIndex + intervalsToAdvance;
						var intervalsAvailable:int = adherenceCurveCollection.length - 1 - currentAdherenceIndex;
						additionalIntervalsRequired = (adherent ? singleCurve.length : 1) - intervalsAvailable;
						extensionStartDate = new Date(adherenceCurveCollection[adherenceCurveCollection.length - 1].date.time + intervalDuration);
					}

					extendAdherenceCurveCollection(adherenceCurveCollection, extensionStartDate, additionalIntervalsRequired, nowTime);

					if (currentAdherenceIndex >= adherenceCurveCollection.length)
						break;
					
					// TODO: ensure we have the exact time instead of nearest hour
					adherenceCurveCollection[currentAdherenceIndex]["adherence"] = dataItem["adherence"];
					adherenceCurveCollection[currentAdherenceIndex]["adherencePosition"] = 0;
					
					if (adherent)
					{
						var index:Number = 0;
						for each (var value:Number in singleCurve)
						{
							if (currentAdherenceIndex + index >= adherenceCurveCollection.length)
								break;
							
							adherenceCurveCollection[currentAdherenceIndex + index]["concentration"] += value;
							index += 1;
						}
					}
					
					// prepare for next iteration
					previousAdherenceIndex = currentAdherenceIndex;
				}
			}

			var lastConcentraCurveDate:Date = adherenceCurveCollection[adherenceCurveCollection.length - 1].date;
			if (lastAdherenceDate.time > lastConcentraCurveDate.time)
			{
				extendAdherenceCurveCollection(adherenceCurveCollection, lastAdherenceDate, 1, nowTime);
				
				// avoid having a zero value for concentration
				adherenceCurveCollection[adherenceCurveCollection.length - 1]["concentration"] = adherenceCurveCollection[adherenceCurveCollection.length - 2]["concentration"]; 
			}
			
			adherenceDataCollection = adherenceCurveCollection;
		}
		
		private function calculateSingleDoseCurve():Array
		{
			var D:Number = 25;
			var F:Number = 0.55;
			var Ka:Number = Math.log(2)/0.5;
			var Ke:Number = Math.log(2)/10;
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

		[Bindable]
		public function get data():ArrayCollection
		{
			return _data;
		}
		
		public function set data(value:ArrayCollection):void
		{
			_data = value;
//			calculateAdherenceCurve();
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}
		
		
	}
}