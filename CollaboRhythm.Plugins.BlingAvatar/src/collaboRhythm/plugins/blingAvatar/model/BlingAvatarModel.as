package collaboRhythm.plugins.blingAvatar.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;

	[Bindable]
	public class BlingAvatarModel
	{
		private var _record:Record;
		private var _documentCollectionDependenciesArray:Array;
		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
		private var _medicationAdministrationsCollection:ArrayCollection;
		private var _currency:Number;
		private var _areGlassesPurchased:Boolean = false;

		public function BlingAvatarModel(record:Record)
		{
			_record = record;

			_documentCollectionDependenciesArray = [_record.medicationOrdersModel, _record.medicationScheduleItemsModel, _record.equipmentModel, _record.equipmentScheduleItemsModel, _record.adherenceItemsModel];

			for each (var documentCollection:DocumentCollectionBase in _documentCollectionDependenciesArray)
			{
				_changeWatchers.push(BindingUtils.bindSetter(init, documentCollection, "isStitched"));
			}
		}

		private function init(isStitched:Boolean):void
		{
			if (isStitched)
			{
				for each (var documentCollection:DocumentCollectionBase in _documentCollectionDependenciesArray)
				{
					if (!documentCollection.isStitched)
					{
						return;
					}
				}
			}
			else
			{
				return;
			}
			
			bindMedicationAdministrations();
		}

		private function bindMedicationAdministrations():void
		{
			_medicationAdministrationsCollection = _record.medicationAdministrationsModel.medicationAdministrationsCollection;
			_medicationAdministrationsCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, medicationAdministrationsCollection_changeEventHandler);
			updateCurrency();
		}

		private function medicationAdministrationsCollection_changeEventHandler(event:CollectionEvent):void
		{
			updateCurrency();
		}

		private function updateCurrency():void
		{
			currency = _medicationAdministrationsCollection.length + 7;
			if (currency < 20)
			{
				areGlassesPurchased = false;
			}
		}
		

		public function get record():Record
		{
			return _record;
		}

		public function get currency():Number
		{
			return _currency;
		}

		public function set currency(value:Number):void
		{
			_currency = value;
		}

		public function get areGlassesPurchased():Boolean
		{
			return _areGlassesPurchased;
		}

		public function set areGlassesPurchased(value:Boolean):void
		{
			_areGlassesPurchased = value;
		}

		public function buyGlasses():void
		{
			if (currency >= 20 && !areGlassesPurchased)
			{
				areGlassesPurchased = true;
				currency = currency - 20;
			}
			else if (areGlassesPurchased)
			{
				areGlassesPurchased = false;
				currency = currency + 20;
			}
		}
	}
}
