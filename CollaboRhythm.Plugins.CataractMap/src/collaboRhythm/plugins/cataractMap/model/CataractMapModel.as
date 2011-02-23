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
package collaboRhythm.plugins.cataractMap.model
{
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	[Bindable]
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

		public function get showFps():Boolean
		{
			return _showFps;
		}

		public function set showFps(value:Boolean):void
		{
			_showFps = value;
		}

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
		
		public function get data():ArrayCollection
		{
			return _data;
		}
		
		public function set data(value:ArrayCollection):void
		{
			_data = value;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}
		
		
	}
}