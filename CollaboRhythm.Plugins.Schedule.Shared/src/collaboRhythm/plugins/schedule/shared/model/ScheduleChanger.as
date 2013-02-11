package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	public class ScheduleChanger
	{
		/**
		 * Potentially useful during testing/debugging as a way to terminate the schedule for a medication, such as
		 * when you want to switch from one kind of insulin to another.
		 */
		private static const DISABLE_CREATION_OF_NEW_SCHEDULE:Boolean = false;

		protected var _logger:ILogger;
		private var _record:Record;
		private var _accountId:String;
		private var _currentDateSource:ICurrentDateSource;

		public function ScheduleChanger(record:Record, accountId:String, currentDateSource:ICurrentDateSource)
		{
			_record = record;
			_accountId = accountId;
			_currentDateSource = currentDateSource;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		/**
		 * Updates the schedule by either (a) updating the existing schedule document if we are dealing with the first
		 * occurrence or (b) creating a new schedule document with the changes and updating the existing schedule
		 * document to preserve its schedule (previous occurrences) up to (but not including) the target occurrence.
		 *
		 * @param currentScheduleItem
		 * @param occurrence
		 * @param updateScheduleItemPropertiesFunction
		 * @param saveSucceeded
		 * @return true if save succeeded
		 */
		public function updateScheduleItem(currentScheduleItem:ScheduleItemBase,
										   occurrence:ScheduleItemOccurrence,
										   updateScheduleItemPropertiesFunction:Function, saveSucceeded:Boolean):Boolean
		{
			var administeredOccurrenceCount:int = occurrence.recurrenceIndex;
			if (administeredOccurrenceCount > 0)
			{
				if (currentScheduleItem.recurrenceRule)
				{
					var remainingOccurrenceCount:int = currentScheduleItem.recurrenceRule.count -
							administeredOccurrenceCount;
					if (remainingOccurrenceCount > 0)
					{
						currentScheduleItem.recurrenceRule.count = administeredOccurrenceCount;
						if (currentScheduleItem.pendingAction == null)
							currentScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;

						if (!DISABLE_CREATION_OF_NEW_SCHEDULE)
						{
							createNewScheduleItem(currentScheduleItem, remainingOccurrenceCount,
									updateScheduleItemPropertiesFunction, occurrence);
						}
					}
					else
					{
						// schedule has ended; no future occurrences to reschedule or change the dose for
						// TODO: warn the user why the update (such as dose change for medication) cannot be changed; possibly provide a means to extend the schedule beyond the original recurrence range
						_logger.warn("User is attempting to update the schedule item " +
								currentScheduleItem.name.text + " with dateStart of " +
								currentScheduleItem.dateStart.toLocaleString() +
								" but the schedule has ended; no future occurrences to reschedule or change.");
						saveSucceeded = false;
					}
				}
			}
			else
			{
				if (currentScheduleItem.pendingAction == null)
					currentScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;
				updateScheduleItemPropertiesFunction(currentScheduleItem);
			}
			return saveSucceeded;
		}

		private function createNewScheduleItem(currentScheduleItem:ScheduleItemBase, remainingOccurrenceCount:int,
											   updateScheduleItemPropertiesFunction:Function,
											   occurrence:ScheduleItemOccurrence):void
		{
			if (currentScheduleItem is MedicationScheduleItem)
			{
				createNewMedicationScheduleItem(currentScheduleItem as MedicationScheduleItem, remainingOccurrenceCount,
						updateScheduleItemPropertiesFunction, occurrence);
			}
			else if (currentScheduleItem is HealthActionSchedule)
			{
				createNewHealthActionSchedule(currentScheduleItem as HealthActionSchedule, remainingOccurrenceCount,
						updateScheduleItemPropertiesFunction, occurrence);
			}
		}

		private function createNewMedicationScheduleItem(currentMedicationScheduleItem:MedicationScheduleItem,
														 remainingOccurrenceCount:int,
														 updateScheduleItemPropertiesFunction:Function,
														 occurrence:ScheduleItemOccurrence):void
		{
			// create new MedicationScheduleItem with new dose starting at cut off day
			var scheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
			scheduleItem.dose = currentMedicationScheduleItem.dose.clone();

			if (currentMedicationScheduleItem.scheduledMedicationOrder)
			{
				var relationship:Relationship = record.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
						currentMedicationScheduleItem.scheduledMedicationOrder, scheduleItem,
						true);
				scheduleItem.scheduledMedicationOrder = currentMedicationScheduleItem.scheduledMedicationOrder;

				// TODO: Use the correct id for the scheduleItem; we are currently using the temporary id that we assigned ourselves; the actual id of the document will not bet known until we get a response from the server after creation
				currentMedicationScheduleItem.scheduledMedicationOrder.scheduleItems.put(scheduleItem.meta.id,
						scheduleItem);
			}

			prepareNewScheduleItem(scheduleItem, currentMedicationScheduleItem, remainingOccurrenceCount,
					updateScheduleItemPropertiesFunction, occurrence);
		}

		private function createNewHealthActionSchedule(currentScheduleItem:HealthActionSchedule,
													   remainingOccurrenceCount:int,
													   updateScheduleItemPropertiesFunction:Function,
													   occurrence:ScheduleItemOccurrence):void
		{
			// create new MedicationScheduleItem with new dose starting at cut off day
			var scheduleItem:HealthActionSchedule = new HealthActionSchedule();

			if (currentScheduleItem.scheduledHealthAction)
			{
				record.addRelationship(ScheduleItemBase.RELATION_TYPE_HEALTH_ACTION_SCHEDULE,
						currentScheduleItem.scheduledHealthAction, scheduleItem,
						true);
				scheduleItem.scheduledHealthAction = currentScheduleItem.scheduledHealthAction;
			}
			if (currentScheduleItem.scheduledEquipment)
			{
				record.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
						currentScheduleItem.scheduledEquipment, scheduleItem,
						true);
				scheduleItem.scheduledEquipment = currentScheduleItem.scheduledEquipment;

				// TODO: Use the correct id for the scheduleItem; we are currently using the temporary id that we assigned ourselves; the actual id of the document will not bet known until we get a response from the server after creation
				currentScheduleItem.scheduledEquipment.scheduleItems.put(scheduleItem.meta.id,
						scheduleItem);
			}

			prepareNewScheduleItem(scheduleItem, currentScheduleItem, remainingOccurrenceCount,
					updateScheduleItemPropertiesFunction, occurrence);
		}

		private function prepareNewScheduleItem(newScheduleItem:ScheduleItemBase,
												currentScheduleItem:ScheduleItemBase,
												remainingOccurrenceCount:int,
												updateScheduleItemPropertiesFunction:Function,
												occurrence:ScheduleItemOccurrence):void
		{
			newScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;

			newScheduleItem.name = currentScheduleItem.name.clone();
			newScheduleItem.instructions = currentScheduleItem.instructions;
			newScheduleItem.scheduledBy = accountId;
			newScheduleItem.dateScheduled = currentDateSource.now();
			newScheduleItem.dateStart = occurrence.dateStart;
			newScheduleItem.dateEnd = occurrence.dateEnd;
			newScheduleItem.recurrenceRule = new RecurrenceRule();
			newScheduleItem.recurrenceRule.frequency = currentScheduleItem.recurrenceRule.frequency;
			newScheduleItem.recurrenceRule.interval = currentScheduleItem.recurrenceRule.interval;
			newScheduleItem.recurrenceRule.count = remainingOccurrenceCount;

			updateScheduleItemPropertiesFunction(newScheduleItem);

			record.addDocument(newScheduleItem);
		}

	}
}
