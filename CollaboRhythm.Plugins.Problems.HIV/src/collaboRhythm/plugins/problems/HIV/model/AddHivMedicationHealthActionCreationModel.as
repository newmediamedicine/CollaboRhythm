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
		private static const DEFAULT_INDICATION:String = "HIV";

		public static const _hivMedicationNdcArray:Array = ["000746799", "000740522", "497020211", "000743333", "497020221", "497020206", "001730470", "619580601", "619580401", "596760562", "596760561", "596760570", "000876672", "000876673", "000876674", "000060227", "000560474", "000560510", "000033624", "000033631", "005970046", "001730595", "127830967", "000060573", "155840101", "619580701"];
		private var _hivMedicationRxcuiArray:Array = ["847741", "847745", "201907", "152970", "213460", "602395", "152931", "404587", "352050", "794610", "824876", "758555", "284499", "285027", "284500", "744846", "213390", "352143", "402094", "402093", "211327", "213088", "152944", "153128", "643070", "639888"];
		private var _hivMedicationNamesArray:Array = ["lopinavir 200 MG / Ritonavir 50 MG Oral Tablet [Kaletra]", "lopinavir 100 MG / Ritonavir 25 MG Oral Tablet [Kaletra]", "Zidovudine 100 MG Oral Capsule [Retrovir]", "Ritonavir 100 MG Oral Capsule [Norvir]", "abacavir 300 MG Oral Tablet [Ziagen]", "abacavir 600 MG / Lamivudine 300 MG Oral Tablet [Epzicom]", "Lamivudine 150 MG Oral Tablet [Epivir]", "emtricitabine 200 MG Oral Capsule [Emtriva]", "Tenofovir disoproxil fumarate 300 MG Oral Tablet [Viread]", "darunavir 600 MG Oral Tablet [Prezista]", "darunavir 400 MG Oral Tablet [Prezista]", "etravirine 100 MG Oral Tablet [Intelence]", "Didanosine 200 MG Enteric Coated Capsule [Videx EC]", "Didanosine 250 MG Enteric Coated Capsule [Videx EC]", "Didanosine 400 MG Enteric Coated Capsule [Videx EC]", "raltegravir 400 MG Oral Tablet [ISENTRESS]", "efavirenz 200 MG Oral Capsule [Sustiva]", "efavirenz 600 MG Oral Tablet [Sustiva]", "Atazanavir 150 MG Oral Capsule [Reyataz]", "Atazanavir 200 MG Oral Capsule [Reyataz]", "Nevirapine 200 MG Oral Tablet [Viramune]", "Lamivudine 150 MG / Zidovudine 300 MG Oral Tablet [Combivir]", "Stavudine 40 MG Oral Capsule [Zerit]", "Indinavir 400 MG Oral Capsule [Crixivan]", "efavirenz 600 MG / emtricitabine 200 MG / Tenofovir disoproxil fumarate 300 MG Oral Tablet [Atripla]", "emtricitabine 200 MG / Tenofovir disoproxil fumarate 300 MG Oral Tablet [Truvada]"];
		private var _hivMedicationDoseArray:Array = [2, 4, 2, 6, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 3, 1, 2, 2, 1, 1, 1, 2, 1, 1];
		private var _hivMedicationFrequencyArray:Array = [2, 2, 3, 2, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 2, 2, 2, 3, 1, 1];
		private var _hivMedicationInstructionsArray:Array = ["Can be taken with or without food", "Can be taken with or without food", "Take with food", "Take with food", "Can be taken with or without food", "Can be taken with or without food", "Can be taken with or without food", "Can be taken with or without food", "Take with food", "Take with food", "Take with food", "Take after a meal", "Take on an empty stomach", "Take on an empty stomach", "Take on an empty stomach", "Can be taken with or without food", "Take with water", "Take with ritonavir and food", "Take with ritonavir and food", "Can be taken with or without food", "Take with water", "Take with water", "Take on an empty stomach", "Take with food"];

		private var _hivMedicationChoicesArrayCollection:ArrayCollection = new ArrayCollection();
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
				var hivMedicationChoice:HIVMedicationChoice = new HIVMedicationChoice(_hivMedicationNdcArray[index],
						_hivMedicationRxcuiArray[index], _hivMedicationNamesArray[index],
						_hivMedicationDoseArray[index], _hivMedicationFrequencyArray[index],
						_hivMedicationInstructionsArray[index])

				_hivMedicationChoicesArrayCollection.addItem(hivMedicationChoice);
			}
		}

		public function get hivMedicationChoicesArrayCollection():ArrayCollection
		{
			return _hivMedicationChoicesArrayCollection;
		}

		public function scheduleMedication(hivMedicationChoice:HIVMedicationChoice):void
		{
			var medicationOrder:MedicationOrder = createMedicationOrder(hivMedicationChoice);

			createMedicationScheduleItems(medicationOrder, hivMedicationChoice);

			createMedicationFill(medicationOrder, hivMedicationChoice);

			_activeRecordAccount.primaryRecord.saveAllChanges();
		}

		private function createMedicationOrder(hivMedicationChoice:HIVMedicationChoice):MedicationOrder
		{
			var codedValueFactory:CodedValueFactory = new CodedValueFactory();

			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.name = new CollaboRhythmCodedValue("http://rxnav.nlm.nih.gov/REST/rxcui/",
					hivMedicationChoice.rxCUI, null, hivMedicationChoice.name.rawName);
			medicationOrder.orderType = MedicationOrder.PRESCRIBED_ORDER_TYPE;
			medicationOrder.orderedBy = _activeAccount.accountId;
			medicationOrder.dateOrdered = _currentDateSource.now();
			medicationOrder.indication = DEFAULT_INDICATION;
			var doseUnit:CollaboRhythmCodedValue = codedValueFactory.createTabletCodedValue();
			medicationOrder.amountOrdered = new CollaboRhythmValueAndUnit((DEFAULT_RECURRENCE_COUNT *
					hivMedicationChoice.dose * hivMedicationChoice.frequency).toString(),
					doseUnit);
			medicationOrder.instructions = hivMedicationChoice.instructions;

			medicationOrder.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationOrder);

			return medicationOrder;
		}

		private function createMedicationScheduleItems(medicationOrder:MedicationOrder,
													   hivMedicationChoice:HIVMedicationChoice):void
		{
			_medicationScheduleItems = new Vector.<MedicationScheduleItem>();

			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord,
					_activeAccount.accountId, _currentDateSource);

			for (var administrationPerDay:int = 1; administrationPerDay <= hivMedicationChoice.frequency;
				 administrationPerDay++)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
				medicationScheduleItem.meta.id = UIDUtil.createUID();
				medicationScheduleItem.name = medicationOrder.name;
				scheduleCreator.initializeDefaultSchedule(medicationScheduleItem);

				medicationScheduleItem.dose = new CollaboRhythmValueAndUnit(hivMedicationChoice.dose.toString(),
						medicationOrder.amountOrdered.unit);
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

		private function createMedicationFill(medicationOrder:MedicationOrder,
											  hivMedicationChoice:HIVMedicationChoice):void
		{
			var medicationFill:MedicationFill = new MedicationFill();
			medicationFill.name = medicationOrder.name;
			medicationFill.ndc = new CollaboRhythmCodedValue(null, null, null, hivMedicationChoice.ndc);

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
