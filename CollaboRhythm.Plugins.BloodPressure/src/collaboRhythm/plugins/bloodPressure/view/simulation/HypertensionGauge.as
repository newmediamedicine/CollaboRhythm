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
	public class HypertensionGauge extends Gauge
	{
		public function HypertensionGauge()
		{
			valueMinimum = SimulationModel.SYSTOLIC_HYPOTENSION2;
			valueLow1 = SimulationModel.SYSTOLIC_HYPOTENSION1;
			valueLow0 = SimulationModel.SYSTOLIC_HYPOTENSION0;
			valueHigh0 = SimulationModel.SYSTOLIC_PREHYPERTENSION;
			valueHigh1 = SimulationModel.SYSTOLIC_HYPERTENSION_STAGE1;
			valueMaximum = SimulationModel.SYSTOLIC_HYPERTENSION_STAGE2;
		}
	}
}
