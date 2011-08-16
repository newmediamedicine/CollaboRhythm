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

	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;

	[Bindable]
	public class MedicationComponentAdherenceModel
	{
		public static const CONCENTRATION_SEVERITY_LEVEL_VERY_LOW:int = 0;
		public static const CONCENTRATION_SEVERITY_LEVEL_LOW:int = 1;
		public static const CONCENTRATION_SEVERITY_LEVEL_GOAL:int = 2;

		private var _name:CodedValue;
		private var _drugClass:String;
		private var _concentration:Number;
		private var _steps:Vector.<String>;
		private var _stepsProvider:IStepsProvider;
		private var _concentrationSeverityLevel:int = -1;
		private var _concentrationSeverityColor:uint;
		private var _concentrationSeverityProvider:IConcentrationSeverityProvider;
		private var _goalConcentrationMinimum:Number = 0.05;
		private var _goalConcentrationMaximum:Number = 0.35;
		private var _concentrationAxisMaximum:Number = 0.4;
		private var _medicationScheduleItem:MedicationScheduleItem;

		public function MedicationComponentAdherenceModel()
		{
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function get simpleName():String
		{
			return name.text;
		}

		public function get drugClass():String
		{
			return _drugClass;
		}

		public function set drugClass(value:String):void
		{
			_drugClass = value;
		}

		public function get concentration():Number
		{
			return _concentration;
		}

		public function set concentration(value:Number):void
		{
			var oldConcentration:Number = _concentration;
			_concentration = value;
			if (_stepsProvider)
				_stepsProvider.updateSteps(oldConcentration, this);
			if (_concentrationSeverityProvider)
				_concentrationSeverityProvider.updateConcentrationSeverity(oldConcentration, this);
		}

		public function get steps():Vector.<String>
		{
			return _steps;
		}

		public function set steps(value:Vector.<String>):void
		{
			_steps = value;
		}

		public function get stepsProvider():IStepsProvider
		{
			return _stepsProvider;
		}

		public function set stepsProvider(value:IStepsProvider):void
		{
			_stepsProvider = value;
		}

		public function get concentrationSeverityLevel():int
		{
			return _concentrationSeverityLevel;
		}

		public function set concentrationSeverityLevel(value:int):void
		{
			_concentrationSeverityLevel = value;
		}

		public function get concentrationSeverityColor():uint
		{
			return _concentrationSeverityColor;
		}

		public function set concentrationSeverityColor(value:uint):void
		{
			_concentrationSeverityColor = value;
		}

		public function get concentrationSeverityProvider():IConcentrationSeverityProvider
		{
			return _concentrationSeverityProvider;
		}

		public function set concentrationSeverityProvider(value:IConcentrationSeverityProvider):void
		{
			_concentrationSeverityProvider = value;
		}

		public function get goalConcentrationMinimum():Number
		{
			return _goalConcentrationMinimum;
		}

		public function set goalConcentrationMinimum(value:Number):void
		{
			_goalConcentrationMinimum = value;
		}

		public function get goalConcentrationMaximum():Number
		{
			return _goalConcentrationMaximum;
		}

		public function set goalConcentrationMaximum(value:Number):void
		{
			_goalConcentrationMaximum = value;
		}

		public function get concentrationAxisMaximum():Number
		{
			return _concentrationAxisMaximum;
		}

		public function set concentrationAxisMaximum(value:Number):void
		{
			_concentrationAxisMaximum = value;
		}

		public function get medicationScheduleItem():MedicationScheduleItem
		{
			return _medicationScheduleItem;
		}

		public function set medicationScheduleItem(value:MedicationScheduleItem):void
		{
			_medicationScheduleItem = value;
		}
	}
}
