package collaboRhythm.shared.model.medications
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleCreator;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionStep;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	public class TitrationHealthActionCreator
	{
		private var _activeAccountId:String;
		private var _record:Record;
		private var _currentDateSource:ICurrentDateSource;

		private var _indication:String;
		private var _decisionPlanInstructions:String;
		private var _decisionPlanName:String;
		private var _decisionPlanStepName:String;
		private var _decisionPlanStepType:String;
		private var _decisionPlanSystem:String;

		private var _equipmentName:String;
		private var _equipmentType:String;
		private var _equipmentInstructions:String;
		private var _equipmentTypeMatchString:String;

		public function TitrationHealthActionCreator(activeAccountId:String, record:Record)
		{
			_activeAccountId = activeAccountId;
			_record = record;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function createDecisionHealthAction():void
		{
			var decisionHealthActionPlan:HealthActionPlan = getTitrationDecisionPlan(true);
			// create a new schedule
			/*
			 <HealthActionSchedule xmlns="http://indivo.org/vocab/xml/documents#"
			 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			 <name>Insulin Titration Decision</name>
			 <scheduledBy>jking@records.media.mit.edu</scheduledBy>
			 <dateScheduled>2012-07-27T09:00:00-04:00</dateScheduled>
			 <dateStart>2012-07-28T13:00:00Z</dateStart>
			 <dateEnd>2012-07-28T17:00:00Z</dateEnd>
			 <recurrenceRule>
			 <frequency>DAILY</frequency>
			 <count>120</count>
			 </recurrenceRule>
			 </HealthActionSchedule>
			 */

			var healthActionSchedule:HealthActionSchedule = new HealthActionSchedule();
			healthActionSchedule.meta.id = UIDUtil.createUID();

			healthActionSchedule.name = new CollaboRhythmCodedValue(null, _decisionPlanName, null, _decisionPlanName);

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_record, _activeAccountId, _currentDateSource);
			scheduleCreator.initializeDefaultSchedule(healthActionSchedule);

			healthActionSchedule.scheduledHealthAction = decisionHealthActionPlan;

			_record.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
					decisionHealthActionPlan, healthActionSchedule, true);

			_record.addDocument(healthActionSchedule, true);
		}

		/**
		 * Finds the HealthActionPlan for titration decision, or creates one if it does not exist.
		 * @return a HealthActionPlan corresponding to the titration decision
		 */
		public function getTitrationDecisionPlan(createIfNeeded:Boolean):HealthActionPlan
		{
			// find or create the action plan
			var decisionHealthActionPlan:HealthActionPlan = findDecisionHealthActionPlan();
			if (decisionHealthActionPlan == null && createIfNeeded)
			{
				// create a new plan
				/*
				 Example:

				 <HealthActionPlan xmlns="http://indivo.org/vocab/xml/documents/healthActionPlan#"
				 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
				 <name>Insulin Titration Decision</name>
				 <planType>Prescribed</planType>
				 <plannedBy>jking@records.media.mit.edu</plannedBy>
				 <datePlanned>2012-07-27T09:00:00-04:00</datePlanned>
				 <indication>Type II Diabetes Mellitus</indication>
				 <instructions>Use CollaboRhythm to follow the algorithm for changing your dose of basal insulin
				 (generally every three days).
				 </instructions>
				 <system>CollaboRhythm Insulin Titration Support</system>
				 <actions>
				 <action xsi:type="ActionStep">
				 <name>Choose a new dose for your insulin</name>
				 <type>Decide</type>
				 </action>
				 </actions>
				 </HealthActionPlan>
				 */

				decisionHealthActionPlan = new HealthActionPlan();
				decisionHealthActionPlan.meta.id = UIDUtil.createUID();

				decisionHealthActionPlan.name = new CollaboRhythmCodedValue(null, null, null,
						_decisionPlanName);
				decisionHealthActionPlan.planType = "Prescribed";
				decisionHealthActionPlan.plannedBy = _activeAccountId;
				decisionHealthActionPlan.datePlanned = _currentDateSource.now();
				decisionHealthActionPlan.indication = _indication;
				decisionHealthActionPlan.instructions = _decisionPlanInstructions;
				decisionHealthActionPlan.system = new CollaboRhythmCodedValue(null, null, null,
						_decisionPlanSystem);
				if (_decisionPlanStepName && _decisionPlanStepType)
				{
					var actionStep:ActionStep = new ActionStep();
					actionStep.name = new CollaboRhythmCodedValue(null, null, null, _decisionPlanStepName);
					actionStep.type = new CollaboRhythmCodedValue(null, null, null, _decisionPlanStepType);
					decisionHealthActionPlan.actions = new ArrayCollection([actionStep]);
				}
				_record.addDocument(decisionHealthActionPlan, true);
			}
			return decisionHealthActionPlan;
		}

		public function findDecisionHealthActionPlan():HealthActionPlan
		{
			var decisionHealthActionPlan:HealthActionPlan;

			// go in reverse order to start with most recent
			for (var i:int = _record.healthActionPlansModel.documents.length - 1; i >= 0; i--)
			{
				var plan:HealthActionPlan = _record.healthActionPlansModel.documents[i];

				if (plan.name.text == _decisionPlanName)
				{
					decisionHealthActionPlan = plan;
					break;
				}
			}
			return decisionHealthActionPlan;
		}

		public function createMeasurementHealthAction():void
		{
			// find or create the action plan
			var equipment:Equipment = findMeasurementEquipment();
			if (equipment == null)
			{
				// create a new Equipment
				/*
				 Example:

				 <Equipment xmlns="http://indivo.org/vocab/xml/documents#">
				 <dateStarted>2012-07-27</dateStarted>
				 <type>Blood Glucose Meter</type>
				 <name xmlns="">FORA D40b</name>
				 </Equipment>
				 */
				equipment = new Equipment();
				equipment.meta.id = UIDUtil.createUID();
				equipment.name = _equipmentName;
				equipment.dateStarted = _currentDateSource.now();
				equipment.type = _equipmentType;
				_record.addDocument(equipment, true);
			}

			// create a new schedule
			/*
			 <HealthActionSchedule xmlns="http://indivo.org/vocab/xml/documents#">
			 <name xmlns="">FORA D40b</name>
			 <scheduledBy>jking@records.media.mit.edu</scheduledBy>
			 <dateScheduled>2012-07-27T19:13:11Z</dateScheduled>
			 <dateStart>2012-07-28T13:00:00Z</dateStart>
			 <dateEnd>2012-07-28T17:00:00Z</dateEnd>
			 <recurrenceRule>
			 <frequency>DAILY</frequency>
			 <count>120</count>
			 </recurrenceRule>
			 <instructions xmlns="">Use device to record blood glucose. Insert test strip into device and apply a drop of blood.</instructions>
			 </HealthActionSchedule>
			 */

			var healthActionSchedule:HealthActionSchedule = new HealthActionSchedule();
			healthActionSchedule.meta.id = UIDUtil.createUID();

			healthActionSchedule.name = new CollaboRhythmCodedValue(null, _equipmentName, null, _equipmentName);
			healthActionSchedule.instructions = _equipmentInstructions;

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_record, _activeAccountId, _currentDateSource);
			scheduleCreator.initializeDefaultSchedule(healthActionSchedule);

			healthActionSchedule.scheduledHealthAction = equipment;
			healthActionSchedule.scheduledEquipment = equipment;

			_record.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
					equipment, healthActionSchedule, true);

			_record.addDocument(healthActionSchedule, true);
		}

		private function findMeasurementEquipment():Equipment
		{
			var bloodGlucoseEquipment:Equipment;

			for each (var equipment:Equipment in
					_record.equipmentModel.equipmentCollection)
			{
				if ((equipment.type && equipment.type.toLowerCase().indexOf(_equipmentTypeMatchString) != -1) ||
						(equipment.name == _equipmentName))
				{
					bloodGlucoseEquipment = equipment;
					break;
				}
			}
			return bloodGlucoseEquipment;
		}

		public function get activeAccountId():String
		{
			return _activeAccountId;
		}

		public function set activeAccountId(value:String):void
		{
			_activeAccountId = value;
		}

		public function get record():Record
		{
			return _record;
		}

		public function set record(value:Record):void
		{
			_record = value;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function set currentDateSource(value:ICurrentDateSource):void
		{
			_currentDateSource = value;
		}

		public function get indication():String
		{
			return _indication;
		}

		public function set indication(value:String):void
		{
			_indication = value;
		}

		public function get decisionPlanInstructions():String
		{
			return _decisionPlanInstructions;
		}

		public function set decisionPlanInstructions(value:String):void
		{
			_decisionPlanInstructions = value;
		}

		public function get decisionPlanName():String
		{
			return _decisionPlanName;
		}

		public function set decisionPlanName(value:String):void
		{
			_decisionPlanName = value;
		}

		public function get decisionPlanStepName():String
		{
			return _decisionPlanStepName;
		}

		public function set decisionPlanStepName(value:String):void
		{
			_decisionPlanStepName = value;
		}

		public function get decisionPlanStepType():String
		{
			return _decisionPlanStepType;
		}

		public function set decisionPlanStepType(value:String):void
		{
			_decisionPlanStepType = value;
		}

		public function get decisionPlanSystem():String
		{
			return _decisionPlanSystem;
		}

		public function set decisionPlanSystem(value:String):void
		{
			_decisionPlanSystem = value;
		}

		public function get equipmentName():String
		{
			return _equipmentName;
		}

		public function set equipmentName(value:String):void
		{
			_equipmentName = value;
		}

		public function get equipmentType():String
		{
			return _equipmentType;
		}

		public function set equipmentType(value:String):void
		{
			_equipmentType = value;
		}

		public function get equipmentInstructions():String
		{
			return _equipmentInstructions;
		}

		public function set equipmentInstructions(value:String):void
		{
			_equipmentInstructions = value;
		}

		public function get equipmentTypeMatchString():String
		{
			return _equipmentTypeMatchString;
		}

		public function set equipmentTypeMatchString(value:String):void
		{
			_equipmentTypeMatchString = value;
		}
	}
}
