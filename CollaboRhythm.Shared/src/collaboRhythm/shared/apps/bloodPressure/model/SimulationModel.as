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

	import com.theory9.data.types.OrderedMap;

	import mx.binding.utils.BindingUtils;

	import mx.events.PropertyChangeEvent;

	/**
	 * Represents the data used by the blood pressure simulation.
	 */
	[Bindable]
	public class SimulationModel
	{
		private var _date:Date;
		private var _dataPointDate:Date;
		private var _systolic:Number;
		private var _diastolic:Number;
		private var _concentration:Number;
		private var _medications:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _medicationsByCode:OrderedMap = new OrderedMap();
		private var _isInitialized:Boolean

		private var _alphaBlockers:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _betaBlockers:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _thiazideDiuretics:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _aceInhibitors:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _angiotensinReceptorBlockers:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();
		private var _calciumChannelBlockers:Vector.<MedicationComponentAdherenceModel> = new Vector.<MedicationComponentAdherenceModel>();

		private var _preload:int;
		private var _contractility:int;
		private var _afterload:int;
		private var _damage:int;

		public static const ALPHA_BLOCKER:String = "Alpha Blocker";
		public static const BETA_BLOCKER:String = "Beta Blocker";
		public static const THIAZIDE_DIURETIC:String = "Thiazide Diuretic";
		public static const ACE_INHIBITOR:String = "ACE Inhibitor";
		public static const ANGIOTENSIN_RECEPTOR_BLOCKER:String = "Angiotensin Receptor Blocker";
		public static const CALCIUM_CHANNEL_BLOCKER:String = "Calcium Channel Blocker";
		public static const DRUG_CLASS_UNKNOWN:String = "Drug Class Unknown";

		private static const SYSTOLIC_GOAL:int = 130;

		/**
		 * Maximum value to use for the plugRatio, the ratio of plugs (medication) to gaps, in the simulation.
		 */
		public static const maxPlugRatio:Number = 2.0;

		/**
		 * Goal value for the concentration of medication in the blood. A concentration at or above goalConcentration
		 * will result in ideal functioning of the medication.
		 */
		public static const HYDROCHLOROTHIAZIDE_MINIMUM:Number = 0;
		public static const HYDROCHLOROTHIAZIDE_LOW:Number = HYDROCHLOROTHIAZIDE_GOAL / 2;
		public static const HYDROCHLOROTHIAZIDE_GOAL:Number = 0.05;
		public static const HYDROCHLOROTHIAZIDE_HIGH0:Number = 0.35;
		public static const HYDROCHLOROTHIAZIDE_HIGH1:Number = 0.45;
		public static const HYDROCHLOROTHIAZIDE_MAXIMUM:Number = 1;

		public static const QD_MINIMUM:Number = 0;
		public static const QD_LOW:Number = QD_GOAL / 2;
		public static const QD_GOAL:Number = 0.05;
		public static const QD_HIGH0:Number = 0.35;
		public static const QD_HIGH1:Number = 0.45;
		public static const QD_MAXIMUM:Number = 1;

		public static const BID_MINIMUM:Number = 0;
		public static const BID_LOW:Number = BID_GOAL / 2;
		public static const BID_GOAL:Number = 0.05;
		public static const BID_HIGH0:Number = 0.35;
		public static const BID_HIGH1:Number = 0.45;
		public static const BID_MAXIMUM:Number = 1;

		/**
		 * Values lower than this are considered "very highly" hypotensive. Note that his value has been chosen somewhat arbitrarily.
		 */
		public static const SYSTOLIC_HYPOTENSION2:Number = 30;
		/**
		 * Values lower than this are considered "highly" hypotensive. Note that his value has been chosen somewhat arbitrarily.
		 */
		public static const SYSTOLIC_HYPOTENSION1:Number = 60;
		/**
		 * Values lower than this are considered hypotensive.
		 */
		public static const SYSTOLIC_HYPOTENSION0:Number = 90;
		public static const SYSTOLIC_PREHYPERTENSION:Number = 120;
		public static const SYSTOLIC_HYPERTENSION_STAGE1:Number = 140;
		public static const SYSTOLIC_HYPERTENSION_STAGE2:Number = 160;
		public static const SYSTOLIC_HYPERTENSION_CRISIS:Number = 180;

		public static const SEVERITY_COLOR_HIGH:uint = 0xC64A5C;
		public static const SEVERITY_COLOR_MEDIUM:uint = 0xFFF3AB;
		public static const SEVERITY_COLOR_GOAL:uint = 0x79A873;
		private static const systolicColors:Vector.<uint> = new <uint>[
			SEVERITY_COLOR_HIGH,
			SEVERITY_COLOR_MEDIUM,
			SEVERITY_COLOR_GOAL,
			SEVERITY_COLOR_MEDIUM,
			SEVERITY_COLOR_HIGH];
		private static const systolicRanges:Vector.<Number> = new <Number>[
			SYSTOLIC_HYPOTENSION1,
			SYSTOLIC_HYPOTENSION0,
			SYSTOLIC_PREHYPERTENSION,
			SYSTOLIC_HYPERTENSION_STAGE1];
		public static const concentrationColors:Vector.<uint> = systolicColors;
		public static const concentrationRanges:Vector.<Number> = new <Number>[
			HYDROCHLOROTHIAZIDE_LOW,
			HYDROCHLOROTHIAZIDE_GOAL,
			HYDROCHLOROTHIAZIDE_HIGH0,
			HYDROCHLOROTHIAZIDE_HIGH1];

		public static const qdConcentrationRanges:Vector.<Number> = new <Number>[
			QD_LOW,
			QD_GOAL,
			QD_HIGH0,
			QD_HIGH1];
		public static const bidConcentrationRanges:Vector.<Number> = new <Number>[
			BID_LOW,
			BID_GOAL,
			BID_HIGH0,
			BID_HIGH1];


		private var _mode:String;
		private var _modeLabel:String;
		public static const MOST_RECENT_MODE:String = "mostRecentMode";
		public static const HISTORY_MODE:String = "historyMode";
		private var _isHypertensive:Boolean;
		private var _systolicSeverityColor:uint;
		private var _concentrationSeverityColor:uint;


		public function SimulationModel()
		{
			mode = MOST_RECENT_MODE;
		}

		public function get dataPointDate():Date
		{
			return _dataPointDate;
		}

		public function set dataPointDate(value:Date):void
		{
			_dataPointDate = value;
		}

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}

		public function get systolic():Number
		{
			return _systolic;
		}

		public function set systolic(value:Number):void
		{
			_systolic = value;
			isHypertensive = systolic > SYSTOLIC_HYPERTENSION_STAGE1;
			systolicSeverityColor = determineSeverityColor(systolic, systolicColors, systolicRanges);
		}

		private function determineSeverityColor(value:Number, colors:Vector.<uint>, valueRanges:Vector.<Number>):uint
		{
			if (colors.length != valueRanges.length + 1)
				throw new Error("The colors vector must have one element fewer than valueRanges.");

			for (var i:int = 0; i < valueRanges.length; i++)
			{
				if (value < valueRanges[i])
					return colors[i];
			}
			return colors[colors.length - 1];
		}

		public function get diastolic():Number
		{
			return _diastolic;
		}

		public function set diastolic(value:Number):void
		{
			_diastolic = value;
		}

		public function set concentration(value:Number):void
		{
			_concentration = value;
			concentrationSeverityColor = determineSeverityColor(value, concentrationColors, concentrationRanges);
		}

		public function get mode():String
		{
			return _mode;
		}

		public function set mode(value:String):void
		{
			_mode = value;
			modeLabel = determineModeLabel();
		}

		private function determineModeLabel():String
		{
			switch (mode)
			{
				case MOST_RECENT_MODE:
					return "Present Mode";
					break;
				case HISTORY_MODE:
					return "History Mode";
					break;
				default:
					throw new Error("Unsupported mode: " + mode);
					break;
			}
		}

		public function get modeLabel():String
		{
			return _modeLabel;
		}

		public function set modeLabel(value:String):void
		{
			_modeLabel = value;
		}

		public function get isHypertensive():Boolean
		{
			return _isHypertensive;
		}

		public function set isHypertensive(isHypertensive:Boolean):void
		{
			_isHypertensive = isHypertensive;
		}

		public function get systolicSeverityColor():uint
		{
			return _systolicSeverityColor;
		}

		public function set systolicSeverityColor(value:uint):void
		{
			_systolicSeverityColor = value;
		}

		public function get concentrationSeverityColor():uint
		{
			return _concentrationSeverityColor;
		}

		public function set concentrationSeverityColor(value:uint):void
		{
			_concentrationSeverityColor = value;
		}

		public function get medications():Vector.<MedicationComponentAdherenceModel>
		{
			return _medications;
		}

		public function get medicationsByCode():OrderedMap
		{
			return _medicationsByCode;
		}

		public function getMedication(medicationCode:String):MedicationComponentAdherenceModel
		{
			return medicationsByCode.getValueByKey(medicationCode);
		}

		public function addMedication(medication:MedicationComponentAdherenceModel):void
		{
			medications.push(medication);
			medicationsByCode.addKeyValue(medication.name.value, medication);
			switch (medication.drugClass)
			{
				case ALPHA_BLOCKER:
					_alphaBlockers.push(medication);
					break;
				case BETA_BLOCKER:
					_betaBlockers.push(medication);
					break;
				case THIAZIDE_DIURETIC:
					_thiazideDiuretics.push(medication);
					break;
				case ACE_INHIBITOR:
					_aceInhibitors.push(medication);
					break;
				case ANGIOTENSIN_RECEPTOR_BLOCKER:
					_angiotensinReceptorBlockers.push(medication);
					break;
				case CALCIUM_CHANNEL_BLOCKER:
					_calciumChannelBlockers.push(medication);
					break;
			}
			BindingUtils.bindSetter(medicationConcentrationSeverityLevel_changeHandler, medication, "concentrationSeverityLevel");
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "medications", null, medications));
		}

		private function medicationConcentrationSeverityLevel_changeHandler(value:int):void
		{
			preload = determinePreload();
			contractility = determineContractility();
			afterload = detemineAfterload();
			damage = determineDamage();
		}

		private function determinePreload():int
		{
			for each (var thiazideDiuretic:MedicationComponentAdherenceModel in _thiazideDiuretics)
			{
				if (thiazideDiuretic.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var aceInhibitor:MedicationComponentAdherenceModel in _aceInhibitors)
			{
				if (aceInhibitor.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var angiotensinReceptorBlocker:MedicationComponentAdherenceModel in _angiotensinReceptorBlockers)
			{
				if (angiotensinReceptorBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			return 1;
		}

		private function determineContractility():int
		{
			for each (var betaBlocker:MedicationComponentAdherenceModel in _betaBlockers)
			{
				if (betaBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var calciumChannelBlocker:MedicationComponentAdherenceModel in _calciumChannelBlockers)
			{
				if (calciumChannelBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			return 1;
		}

		private function detemineAfterload():int
		{
			for each (var aceInhibitor:MedicationComponentAdherenceModel in _aceInhibitors)
			{
				if (aceInhibitor.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var angiotensinReceptorBlocker:MedicationComponentAdherenceModel in _angiotensinReceptorBlockers)
			{
				if (angiotensinReceptorBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var alphaBlocker:MedicationComponentAdherenceModel in _alphaBlockers)
			{
				if (alphaBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var betaBlocker:MedicationComponentAdherenceModel in _betaBlockers)
			{
				if (betaBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			for each (var calciumChannelBlocker:MedicationComponentAdherenceModel in _calciumChannelBlockers)
			{
				if (calciumChannelBlocker.concentrationSeverityLevel < 2)
				{
					return 3;
				}
			}
			return 1;
		}

		private function determineDamage():int
		{
			var damage:int = 0;
			if (_preload > 1 || _contractility > 1 || _afterload > 1)
			{
				damage += 1;
			}
			if (_systolic > SYSTOLIC_GOAL)
			{
				damage += 1;
			}
			return damage;
		}

		public function get preload():int
		{
			return _preload;
		}

		public function set preload(value:int):void
		{
			_preload = value;
		}

		public function get contractility():int
		{
			return _contractility;
		}

		public function set contractility(value:int):void
		{
			_contractility = value;
		}

		public function get afterload():int
		{
			return _afterload;
		}

		public function set afterload(value:int):void
		{
			_afterload = value;
		}

		public function get damage():int
		{
			return _damage;
		}

		public function set damage(value:int):void
		{
			_damage = value;
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}
	}
}