package collaboRhythm.plugins.medications.model
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
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.EventDispatcher;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	[Bindable]
	public class MedicationHealthActionCreationModel extends EventDispatcher implements IHealthActionCreationModel
	{
		private static const DEFAULT_RECURRENCE_COUNT:int = 120;
		private static const DEFAULT_DOSE:String = "1";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _rxNormService:RxNormService;
		private var _rxNormConceptsArrayCollection:ArrayCollection = new ArrayCollection();
		private var _areRxNormConceptsAvailable:Boolean = true;
		private var _areNdcCodesAvailable:Boolean;
		private var _currentDateSource:ICurrentDateSource;

		private var _medicationScheduleItem:MedicationScheduleItem;

		private var _currentRxNormConcept:RxNormConcept;
		private var _instructions:String;
		private var _dose:String;
		private var _doseUnit:CollaboRhythmCodedValue;
		private var _frequency:int;
		private var _currentNdcCode:String;

		private var _medicationScheduleItems:Vector.<MedicationScheduleItem> = new Vector.<MedicationScheduleItem>();
		private var _oldMedicationScheduleItemIds:Vector.<String> = new Vector.<String>();
		private var _newMedicationScheduleItemIdCount:int = 0;
		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();

		public function MedicationHealthActionCreationModel(activeAccount:Account, activeRecordAccount:Account,
															scheduleItemOccurrence:ScheduleItemOccurrence = null)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_rxNormService = new RxNormService(this);

			if (scheduleItemOccurrence)
			{
				if (scheduleItemOccurrence.scheduleItem as MedicationScheduleItem)
				{
					_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;

					currentRxNormConcept = new RxNormConcept();
					currentRxNormConcept.name = _medicationScheduleItem.name.text;
					currentRxNormConcept.rxcui = _medicationScheduleItem.name.value;

					_medicationScheduleItem = medicationScheduleItem;

					if (_medicationScheduleItem.scheduledMedicationOrder)
					{
						var medicationOrder:MedicationOrder = _medicationScheduleItem.scheduledMedicationOrder;

						if (medicationOrder.medicationFill)
						{
							currentNdcCode = medicationOrder.medicationFill.ndc.text;
						}
					}
				}
			}

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function queryDrugName(drugName:String):void
		{
			rxNormService.queryDrugName(drugName);
		}

		public function queryNdcCodes():void
		{
			rxNormService.queryNdcCodes(currentRxNormConcept);
		}

		public function saveMedication():void
		{
			if (_medicationScheduleItem)
			{
				var medicationOrder:MedicationOrder = _medicationScheduleItem.scheduledMedicationOrder;

				createMedicationFill(medicationOrder);

				dispatchEvent(new SaveMedicationCompleteEvent(SaveMedicationCompleteEvent.SAVE_MEDICATION, 1))
			}
			else
			{
				createMedication();
			}

			_activeRecordAccount.primaryRecord.saveAllChanges();

			resetMedicationHealthActionCreationModel();
		}

		public function createMedication():void
		{
			var medicationOrder:MedicationOrder = createMedicationOrder();

			createMedicationScheduleItems(medicationOrder);

			createMedicationFill(medicationOrder);
		}

		private function createMedicationOrder():MedicationOrder
		{
			var codedValueFactory:CodedValueFactory = new CodedValueFactory();

			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.name = new CollaboRhythmCodedValue(MedicationOrder.RXCUI_CODED_VALUE_TYPE, currentRxNormConcept.rxcui, null,
					currentRxNormConcept.name);
			medicationOrder.orderType = MedicationOrder.PRESCRIBED_ORDER_TYPE;
			medicationOrder.orderedBy = _activeAccount.accountId;
			medicationOrder.dateOrdered = _currentDateSource.now();
			//TODO: Indication should not be required by the server. This can be removed once this is fixed
			//Alternatively, the UI could allow an indication to be specified
			medicationOrder.indication = "Diabetes";
			if (doseUnit.text == "Unit")
			{
				medicationOrder.amountOrdered = new CollaboRhythmValueAndUnit("1",
						codedValueFactory.createPrefilledSyringeCodedValue());
			}
			else
			{
				medicationOrder.amountOrdered = new CollaboRhythmValueAndUnit(DEFAULT_RECURRENCE_COUNT.toString(), doseUnit);
			}
			medicationOrder.instructions = instructions;

			medicationOrder.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationOrder);

			return medicationOrder;
		}

		private function createMedicationScheduleItems(medicationOrder:MedicationOrder):void
		{
			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord, _activeAccount.accountId, _currentDateSource);

			for (var administrationPerDay:int = 0; administrationPerDay <= frequency; administrationPerDay++)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
				medicationScheduleItem.meta.id = UIDUtil.createUID();
				medicationScheduleItem.name = medicationOrder.name;
				scheduleCreator.initializeDefaultSchedule(medicationScheduleItem);

				if (!dose)
				{
					dose = DEFAULT_DOSE;
				}
				medicationScheduleItem.dose = new CollaboRhythmValueAndUnit(dose, doseUnit);
				medicationScheduleItem.instructions = instructions;

				medicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationScheduleItem);

				medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
				_activeRecordAccount.primaryRecord.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
						medicationOrder, medicationScheduleItem, true);

				_medicationScheduleItems.push(medicationScheduleItem);
				_oldMedicationScheduleItemIds.push(medicationScheduleItem.meta.id);
				_changeWatchers.push(BindingUtils.bindSetter(medicationScheduleItemId_changeHandler, medicationScheduleItem.meta, "id"));

			}
		}

		// It is necessary to make sure that the meta data id for each medicationScheduleItem is updated after being saved to the server
		// before the scheduleItems HashMap of the medicationOrder is updated and before the CreateMedicationOrderView is popped
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

				dispatchEvent(new SaveMedicationCompleteEvent(SaveMedicationCompleteEvent.SAVE_MEDICATION, 2))
			}
		}

		private function createMedicationFill(medicationOrder:MedicationOrder):void
		{
			if (currentNdcCode)
			{
				var medicationFill:MedicationFill = new MedicationFill();
				medicationFill.name = medicationOrder.name;
				medicationFill.filledBy = _activeAccount.accountId;
				medicationFill.dateFilled = _currentDateSource.now();
				medicationFill.amountFilled = medicationOrder.amountOrdered;
				medicationFill.ndc = new CollaboRhythmCodedValue(null, null, null, currentNdcCode);

				medicationFill.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationFill);

				medicationOrder.medicationFill = medicationFill;
				_activeRecordAccount.primaryRecord.addRelationship(MedicationOrder.RELATION_TYPE_MEDICATION_FILL,
						medicationOrder, medicationFill, true);
			}
		}

		public function resetMedicationHealthActionCreationModel():void
		{
			_rxNormConceptsArrayCollection.removeAll();
			currentNdcCode = null;
			currentRxNormConcept = null;
			instructions = null;
			dose = null;
			frequency = NaN;
		}

		public function get rxNormService():RxNormService
		{
			return _rxNormService;
		}

		public function get rxNormConceptsArrayCollection():ArrayCollection
		{
			return _rxNormConceptsArrayCollection;
		}

		public function get currentRxNormConcept():RxNormConcept
		{
			return _currentRxNormConcept;
		}

		public function set currentRxNormConcept(value:RxNormConcept):void
		{
			_currentRxNormConcept = value;
		}

		public function get areRxNormConceptsAvailable():Boolean
		{
			return _areRxNormConceptsAvailable;
		}

		public function set areRxNormConceptsAvailable(value:Boolean):void
		{
			_areRxNormConceptsAvailable = value;
		}

		public function get areNdcCodesAvailable():Boolean
		{
			return _areNdcCodesAvailable;
		}

		public function set areNdcCodesAvailable(value:Boolean):void
		{
			_areNdcCodesAvailable = value;
		}

		public function get currentNdcCode():String
		{
			return _currentNdcCode;
		}

		public function set currentNdcCode(value:String):void
		{
			_currentNdcCode = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}

		public function get dose():String
		{
			return _dose;
		}

		public function set dose(value:String):void
		{
			_dose = value;
		}

		public function get doseUnit():CollaboRhythmCodedValue
		{
			return _doseUnit;
		}

		public function set doseUnit(value:CollaboRhythmCodedValue):void
		{
			_doseUnit = value;
		}

		public function get frequency():int
		{
			return _frequency;
		}

		public function set frequency(value:int):void
		{
			_frequency = value;
		}

		public function get medicationScheduleItem():MedicationScheduleItem
		{
			return _medicationScheduleItem;
		}
	}
}
