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
package collaboRhythm.plugins.bloodPressure.view.simulation
{
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;

	import spark.components.Group;

	[Event(name="backUpLevel",type="collaboRhythm.plugins.bloodPressure.view.simulation.SimulationLevelEvent")]
	[Event(name="drillDownLevel",type="collaboRhythm.plugins.bloodPressure.view.simulation.SimulationLevelEvent")]
	public class SimulationLevelGroup extends Group
	{
		public function SimulationLevelGroup()
		{
		}

		private var _simulationModel:SimulationModel;

		[Bindable]
		public function get simulationModel():SimulationModel
		{
			return _simulationModel;
		}

		public function set simulationModel(value:SimulationModel):void
		{
			_simulationModel = value;
		}

		public function initializeModel(simulationModel:SimulationModel):void
		{
			_simulationModel = simulationModel;
		}
	}
}
