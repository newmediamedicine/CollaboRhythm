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
package collaboRhythm.shared.apps.bloodPressure.model
{

	public class StepsProvider implements IStepsProvider
	{
		private var _valueRanges:Vector.<Number>;
		private var _stepsVectors:Vector.<Vector.<String>>;

		public function StepsProvider(valueRanges:Vector.<Number>, stepsVectors:Vector.<Vector.<String>>)
		{
			_valueRanges = valueRanges;
			_stepsVectors = stepsVectors;
		}

		public function updateSteps(oldConcentration:Number, medicationComponentAdherenceModel:MedicationComponentAdherenceModel):void
		{
			var stepsIndex:int = getStepsIndex(medicationComponentAdherenceModel.concentration);
			if (medicationComponentAdherenceModel.steps == null || getStepsIndex(oldConcentration) != stepsIndex)
			{
				medicationComponentAdherenceModel.steps = _stepsVectors[stepsIndex];
			}
		}

		private function getStepsIndex(concentration:Number):int
		{
			for (var i:int = 0; i < _valueRanges.length; i++)
			{
				if (concentration < _valueRanges[i])
					return i;
			}
			return _valueRanges.length;
		}
	}
}
