package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleCreator;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionStep;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.html.script.Package;

	import mx.collections.ArrayCollection;

	import mx.utils.UIDUtil;

	public class InsulinTitrationSupportHealthActionCreationModel
	{
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _currentDateSource:ICurrentDateSource;

		public function InsulinTitrationSupportHealthActionCreationModel(activeAccount:Account,
																	   activeRecordAccount:Account)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function createDecisionHealthAction():void
		{
			// find or create the action plan
			var decisionHealthActionPlan:HealthActionPlan = findDecisionHealthActionPlan();
			if (decisionHealthActionPlan == null)
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

				decisionHealthActionPlan.name = new CodedValue(null, null, null, "Insulin Titration Decision");
				decisionHealthActionPlan.planType = "Prescribed";
				decisionHealthActionPlan.plannedBy = _activeAccount.accountId;
				decisionHealthActionPlan.datePlanned = _currentDateSource.now();
				decisionHealthActionPlan.indication = "Type II Diabetes Mellitus";
				decisionHealthActionPlan.instructions = "Use CollaboRhythm to follow the algorithm for changing your dose of basal insulin (generally every three days).";
				decisionHealthActionPlan.system = new CodedValue(null, null, null, "CollaboRhythm Insulin Titration Support");
				var actionStep:ActionStep = new ActionStep();
				actionStep.name = new CodedValue(null, null, null, "Choose a new dose for your insulin");
				actionStep.type = new CodedValue(null, null, null, "Decide");
				decisionHealthActionPlan.actions = new ArrayCollection([actionStep]);
				_activeRecordAccount.primaryRecord.addDocument(decisionHealthActionPlan, true);
			}

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

			healthActionSchedule.name = new CodedValue(null, null, null, "Insulin Titration Decision");

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord, _activeAccount.accountId, _currentDateSource);
			scheduleCreator.initializeDefaultSchedule(healthActionSchedule);

			healthActionSchedule.scheduledHealthAction = decisionHealthActionPlan;
			_activeRecordAccount.primaryRecord.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
					decisionHealthActionPlan, healthActionSchedule, true);

			_activeRecordAccount.primaryRecord.addDocument(healthActionSchedule, true);

			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		private function findDecisionHealthActionPlan():HealthActionPlan
		{
			var decisionHealthActionPlan:HealthActionPlan;

			for each (var healthActionPlan:HealthActionPlan in
					_activeRecordAccount.primaryRecord.healthActionPlansModel.documents)
			{
				if (healthActionPlan.name.text == "Insulin Titration Decision")
				{
					decisionHealthActionPlan = healthActionPlan;
					break;
				}
			}
			return decisionHealthActionPlan;
		}

		public function createBloodGlucoseHealthAction():void
		{
			// find or create the action plan
			var bloodGlucoseEquipment:Equipment = findBloodGlucoseEquipment();
			if (bloodGlucoseEquipment == null)
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
				bloodGlucoseEquipment = new Equipment();
				bloodGlucoseEquipment.meta.id = UIDUtil.createUID();
				bloodGlucoseEquipment.name = "FORA D40b";
				bloodGlucoseEquipment.dateStarted = _currentDateSource.now();
				bloodGlucoseEquipment.type = "Blood Glucose Meter";
				_activeRecordAccount.primaryRecord.addDocument(bloodGlucoseEquipment, true);
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

			healthActionSchedule.name = new CodedValue(null, null, null, "FORA D40b");
			healthActionSchedule.instructions = "Use device to record blood glucose. Insert test strip into device and apply a drop of blood.";

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord, _activeAccount.accountId, _currentDateSource);
			scheduleCreator.initializeDefaultSchedule(healthActionSchedule);

			healthActionSchedule.scheduledHealthAction = bloodGlucoseEquipment;
			healthActionSchedule.scheduledEquipment = bloodGlucoseEquipment;
			_activeRecordAccount.primaryRecord.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
					bloodGlucoseEquipment, healthActionSchedule, true);

			_activeRecordAccount.primaryRecord.addDocument(healthActionSchedule, true);

			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		private function findBloodGlucoseEquipment():Equipment
		{
			var bloodGlucoseEquipment:Equipment;

			for each (var equipment:Equipment in
					_activeRecordAccount.primaryRecord.equipmentModel.equipmentCollection)
			{
				if ((equipment.type && equipment.type.toLowerCase().indexOf("blood glucose") != -1) || (equipment.name == "FORA D40b"))
				{
					bloodGlucoseEquipment = equipment;
					break;
				}
			}
			return bloodGlucoseEquipment;
		}
	}
}
