package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.plugins.schedule.shared.model.SaveMedicationCompleteEvent;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleCreator;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CodedValueFactory;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.EventDispatcher;

	import mx.binding.utils.BindingUtils;

	import mx.binding.utils.ChangeWatcher;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	public class AddHivMedicationHealthActionCreationModel extends EventDispatcher implements IHealthActionCreationModel
	{
		private static const DEFAULT_RECURRENCE_COUNT:int = 120;
		private static const DEFAULT_DOSE:String = "1";
		private static const DEFAULT_INDICATION:String = "HIV";
		private static const DEFAULT_INSTRUCTIONS:String = "Take with water";
		private static const DEFAULT_FREQUENCY:int = 0;

		//private var _hivMedicationNdcCodesArray:Array = ["000746799", "000740522", "497020211", "000743333", "497020221", "497020206", "001730470", "619580601", "619580401", "596760562", "596760561", "596760570", "000876672", "000876673", "000876674", "000060227", "000560474", "000560510", "000033624", "000033631", "005970046", "001730595", "127830967", "000060573", "155840101", "619580701"];
		private var _hivMedicationNdcArray:Array = ["000746799", "000740522", "000743333"];
		private var _hivMedicationRxcuiArray:Array = ["847741", "847745", "152970"];
		private var _hivMedicationNamesArray:Array = ["lopinavir 200 MG / Ritonavir 50 MG Oral Tablet [Kaletra]", "lopinavir 100 MG / Ritonavir 25 MG Oral Tablet [Kaletra]", "Ritonavir 100 MG Oral Capsule [Norvir]"];

		private var _hivMedicationsArrayCollection:ArrayCollection = new ArrayCollection();
		private var _activeAccount:Account;

		private var _activeRecordAccount:Account;
		private var _currentDateSource:ICurrentDateSource;

		private var _medicationScheduleItems:Vector.<MedicationScheduleItem> = new Vector.<MedicationScheduleItem>();
		private var _oldMedicationScheduleItemIds:Vector.<String> = new Vector.<String>();
		private var _newMedicationScheduleItemIdCount:int = 0;
		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();

		public function AddHivMedicationHealthActionCreationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			for (var index:int = 0; index < _hivMedicationNdcArray.length; index++)
			{
				var medicationFill:MedicationFill = new MedicationFill();
				medicationFill.name = new CollaboRhythmCodedValue("http://rxnav.nlm.nih.gov/REST/rxcui/",
						_hivMedicationRxcuiArray[index], null, _hivMedicationNamesArray[index]);
				;
				medicationFill.ndc = new CollaboRhythmCodedValue(null, null, null, _hivMedicationNdcArray[index]);

				_hivMedicationsArrayCollection.addItem(medicationFill);
			}
		}

		public function get hivMedicationsArrayCollection():ArrayCollection
		{
			return _hivMedicationsArrayCollection;
		}

		public function scheduleMedication(medicationFill:MedicationFill):void
		{
			var medicationOrder:MedicationOrder = createMedicationOrder(medicationFill);

			createMedicationScheduleItems(medicationOrder);

			completeMedicationFill(medicationOrder, medicationFill);

			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		private function createMedicationOrder(medicationFill:MedicationFill):MedicationOrder
		{
			var codedValueFactory:CodedValueFactory = new CodedValueFactory();

			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.name = medicationFill.name;
			medicationOrder.orderType = MedicationOrder.PRESCRIBED_ORDER_TYPE;
			medicationOrder.orderedBy = _activeAccount.accountId;
			medicationOrder.dateOrdered = _currentDateSource.now();
			//TODO: Indication should not be required by the server. This can be removed once this is fixed
			//Alternatively, the UI could allow an indication to be specified
			medicationOrder.indication = DEFAULT_INDICATION;
			var doseUnit:CollaboRhythmCodedValue = codedValueFactory.createTabletCodedValue();
			medicationOrder.amountOrdered = new CollaboRhythmValueAndUnit(DEFAULT_RECURRENCE_COUNT.toString(),
					doseUnit);
			medicationOrder.instructions = DEFAULT_INSTRUCTIONS;

			medicationOrder.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationOrder);

			return medicationOrder;
		}

		private function createMedicationScheduleItems(medicationOrder:MedicationOrder):void
		{
			_medicationScheduleItems = new Vector.<MedicationScheduleItem>();

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord,
					_activeAccount.accountId, _currentDateSource);

			for (var administrationPerDay:int = 0; administrationPerDay <= DEFAULT_FREQUENCY; administrationPerDay++)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
				medicationScheduleItem.meta.id = UIDUtil.createUID();
				medicationScheduleItem.name = medicationOrder.name;
				scheduleCreator.initializeDefaultSchedule(medicationScheduleItem);

				medicationScheduleItem.dose = new CollaboRhythmValueAndUnit(DEFAULT_DOSE, medicationOrder.amountOrdered.unit);
				medicationScheduleItem.instructions = medicationOrder.instructions;

				medicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationScheduleItem);

				medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
				_activeRecordAccount.primaryRecord.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
						medicationOrder, medicationScheduleItem, true);

				_medicationScheduleItems.push(medicationScheduleItem);
				_oldMedicationScheduleItemIds.push(medicationScheduleItem.meta.id);
				_changeWatchers.push(BindingUtils.bindSetter(medicationScheduleItemId_changeHandler,
						medicationScheduleItem.meta, "id"));

			}
		}

		// It is necessary to make sure that the meta data id for each medicationScheduleItem is updated after being saved to the server
		// before the scheduleItems HashMap of the medicationOrder is updated and before the AddHivMedicationHealthActionCreationView is popped
		private function medicationScheduleItemId_changeHandler(id:String):void
		{
			var index:int = _oldMedicationScheduleItemIds.indexOf(id);

			if (index == -1)
			{
				_newMedicationScheduleItemIdCount++;
			}

			if (_newMedicationScheduleItemIdCount == _oldMedicationScheduleItemIds.length)
			{
				for each (var changeWatcher:ChangeWatcher in _changeWatchers)
				{
					changeWatcher.unwatch();
				}

				for each (var medicationScheduleItem:MedicationScheduleItem in _medicationScheduleItems)
				{
					medicationScheduleItem.scheduledMedicationOrder.scheduleItems[medicationScheduleItem.meta.id] = medicationScheduleItem;
				}

				dispatchEvent(new SaveMedicationCompleteEvent(SaveMedicationCompleteEvent.SAVE_MEDICATION, 1))
			}
		}

		private function completeMedicationFill(medicationOrder:MedicationOrder, medicationFill:MedicationFill):void
		{
			medicationFill.filledBy = _activeAccount.accountId;
			medicationFill.dateFilled = _currentDateSource.now();
			medicationFill.amountFilled = medicationOrder.amountOrdered;

			medicationFill.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationFill);

			medicationOrder.medicationFill = medicationFill;
			_activeRecordAccount.primaryRecord.addRelationship(MedicationOrder.RELATION_TYPE_MEDICATION_FILL,
					medicationOrder, medicationFill, true);
		}
	}
}
