package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CodedValueFactory;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	[Bindable]
	public class MedicationHealthActionCreationModel implements IHealthActionCreationModel
	{
		private static const RXCUI_CODED_VALUE_TYPE:String = "http://rxnav.nlm.nih.gov/REST/rxcui/";
		private static const PRESCRIBED_ORDER_TYPE:String = "prescribed";

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;
		private var _rxNormService:RxNormService;
		private var _rxNormConceptsArrayCollection:ArrayCollection = new ArrayCollection();
		private var _areRxNormConceptsAvailable:Boolean = true;
		private var _areNdcCodesAvailable:Boolean;
		private var _currentDateSource:ICurrentDateSource;

		private var _currentRxNormConcept:RxNormConcept;
		private var _currentNdcCode:String;

		public function MedicationHealthActionCreationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_rxNormService = new RxNormService(this);

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

		public function createMedication(medicationOrderInstructions:String, dose:String,
										 doseUnit:CodedValue,
										 frequency:int):void
		{
			var now:Date = _currentDateSource.now();
			var codedValueFactory:CodedValueFactory = new CodedValueFactory();

			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.name = new CodedValue(RXCUI_CODED_VALUE_TYPE, currentRxNormConcept.rxcui, null,
					currentRxNormConcept.name);
			medicationOrder.orderType = PRESCRIBED_ORDER_TYPE;
			medicationOrder.orderedBy = _activeAccount.accountId;
			medicationOrder.dateOrdered = now;
			medicationOrder.indication = "Diabetes";
			if (doseUnit.text == "tablet")
			{
				medicationOrder.amountOrdered = new ValueAndUnit("120", doseUnit);
			}
			else if (doseUnit.text == "Unit")
			{
				medicationOrder.amountOrdered = new ValueAndUnit("1", codedValueFactory.createPrefilledSyringeCodedValue());
			}
			medicationOrder.instructions = medicationOrderInstructions;

			medicationOrder.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationOrder);

			for (var administrationPerDay:int = 0; administrationPerDay <= frequency; administrationPerDay++)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
				medicationScheduleItem.meta.id = UIDUtil.createUID();
				medicationScheduleItem.name = medicationOrder.name;
				medicationScheduleItem.scheduledBy = _activeAccount.accountId;
				medicationScheduleItem.dateScheduled = now;
				medicationScheduleItem.dateStart = new Date(now.fullYear, now.month, now.date, 8, 0, 0);
				medicationScheduleItem.dateEnd = new Date(now.fullYear, now.month, now.date, 12, 0, 0);
				var recurrenceRule:RecurrenceRule = new RecurrenceRule();
				recurrenceRule.frequency = new CodedValue(null, null, null, ScheduleItemBase.DAILY);
				recurrenceRule.count = 120;
				medicationScheduleItem.recurrenceRule = recurrenceRule;
				if (!dose)
				{
					dose = "1";
				}
				medicationScheduleItem.dose = new ValueAndUnit(dose, doseUnit);
				medicationScheduleItem.instructions = medicationOrderInstructions;

				medicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationScheduleItem);

				medicationOrder.scheduleItems[medicationScheduleItem.meta.id] = medicationScheduleItem;
				medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
				_activeRecordAccount.primaryRecord.addNewRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM, medicationOrder, medicationScheduleItem);

			}

			if (currentNdcCode)
			{
				var medicationFill:MedicationFill = new MedicationFill();
				medicationFill.name = medicationOrder.name;
				medicationFill.filledBy = _activeAccount.accountId;
				medicationFill.dateFilled = _currentDateSource.now();
				medicationFill.amountFilled = medicationOrder.amountOrdered;
				medicationFill.ndc = new CodedValue(null, null, null, currentNdcCode);

				medicationFill.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationFill);

				medicationOrder.medicationFill = medicationFill;
				_activeRecordAccount.primaryRecord.addNewRelationship(MedicationOrder.RELATION_TYPE_MEDICATION_FILL, medicationOrder, medicationFill);
			}

			_activeRecordAccount.primaryRecord.saveAllChanges();

			reset();
		}

		public function reset():void
		{
			_rxNormConceptsArrayCollection.removeAll();
			currentNdcCode = null;
			currentRxNormConcept = null;
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
	}
}
