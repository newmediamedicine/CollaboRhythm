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
package collaboRhythm.shared.apps.healthCharts.model
{
	public class ConcentrationSeverityProvider implements IConcentrationSeverityProvider
	{
		private var _concentrationRanges:Vector.<Number>;
		private var _concentrationColors:Vector.<uint>;

		public function get concentrationRanges():Vector.<Number>
		{
			return _concentrationRanges;
		}

		public function set concentrationRanges(value:Vector.<Number>):void
		{
			_concentrationRanges = value;
		}

		public function get concentrationColors():Vector.<uint>
		{
			return _concentrationColors;
		}

		public function set concentrationColors(value:Vector.<uint>):void
		{
			_concentrationColors = value;
		}

		public function ConcentrationSeverityProvider(concentrationRanges:Vector.<Number>, concentrationColors:Vector.<uint>)
		{
			_concentrationRanges = concentrationRanges;
			_concentrationColors = concentrationColors;
		}

		public function updateConcentrationSeverity(oldConcentration:Number,
													medicationComponentAdherenceModel:MedicationComponentAdherenceModel):void
		{
			var level:int = getSeverityLevel(medicationComponentAdherenceModel.concentration);
			if (medicationComponentAdherenceModel.concentrationSeverityLevel == -1 || getSeverityLevel(oldConcentration) != level)
			{
				medicationComponentAdherenceModel.concentrationSeverityLevel = level;
				medicationComponentAdherenceModel.concentrationSeverityColor = concentrationColors[level];
			}
		}

		private function getSeverityLevel(concentration:Number):int
		{
			for (var i:int = 0; i < _concentrationRanges.length; i++)
			{
				if (concentration < _concentrationRanges[i])
					return i;
			}
			return _concentrationRanges.length;
		}
	}
}
