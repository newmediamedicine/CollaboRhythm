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
	import collaboRhythm.plugins.bloodPressure.view.simulation.gauge.Gauge;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;

	/**
	 * Gauge used to indicate severity of hypertension. Also shows hypotension. Values based on systolic blood pressure
	 * only (in mmHg).
	 */
	public class HydrochlorothiazideGauge extends Gauge
	{
		public function HydrochlorothiazideGauge()
		{
			valueMinimum = SimulationModel.HYDROCHLOROTHIAZIDE_MINIMUM;
			valueLow1 = SimulationModel.HYDROCHLOROTHIAZIDE_LOW;
			valueLow0 = SimulationModel.HYDROCHLOROTHIAZIDE_GOAL;
			valueHigh0 = SimulationModel.HYDROCHLOROTHIAZIDE_HIGH0;
			valueHigh1 = SimulationModel.HYDROCHLOROTHIAZIDE_HIGH1;
			valueMaximum = SimulationModel.HYDROCHLOROTHIAZIDE_MAXIMUM;

//			valueMinimum="0"
//			valueLow1="{0.5 * SimulationModel.goalConcentration}"
//			valueLow0="{SimulationModel.goalConcentration}"
//			valueHigh0="{SimulationModel.goalConcentrationHigh0}"
//			valueHigh1="{SimulationModel.goalConcentrationHigh1}"
//			valueMaximum="{SimulationModel.concentrationMaximum}"
		}
	}
}
