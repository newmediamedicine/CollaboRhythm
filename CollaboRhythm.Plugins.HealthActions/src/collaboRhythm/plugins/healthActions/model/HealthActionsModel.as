package collaboRhythm.plugins.healthActions.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;

	import mx.collections.ArrayCollection;

	public class HealthActionsModel implements IHealthActionModelDetailsProvider
	{
		private var _record:Record;
		private var _accountId:String;
		private var _healthActionListViewAdapters:ArrayCollection;
		private var _healthActionInputControllerFactory:MasterHealthActionInputControllerFactory;
		private var _documentCollectionDependenciesArray:Array;
		private var _changeWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
		private var _componentContainer:IComponentContainer;

		public function HealthActionsModel(componentContainer:IComponentContainer, record:Record, accountId:String)
		{
			_componentContainer = componentContainer;
			_record = record;
			_accountId = accountId;

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

			var healthActionListViewAdapterFactory:MasterHealthActionListViewAdapterFactory = new MasterHealthActionListViewAdapterFactory(_componentContainer);
			_healthActionListViewAdapters = healthActionListViewAdapterFactory.createUnscheduledHealthActionViewAdapters(this);
			_healthActionInputControllerFactory = new MasterHealthActionInputControllerFactory(_componentContainer);
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get healthActionListViewAdapters():ArrayCollection
		{
			return _healthActionListViewAdapters;
		}

		public function get healthActionInputControllerFactory():MasterHealthActionInputControllerFactory
		{
			return _healthActionInputControllerFactory;
		}
	}
}
