package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.plugins.schedule.controller.DefaultDataInputController;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IDataInputViewFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.view.DefaultDataInputView;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class MasterDataInputViewFactory implements IDataInputViewFactory
	{
		private var _factoryArray:Array;

		public function MasterDataInputViewFactory(componentContainer:IComponentContainer)
		{
			_factoryArray = componentContainer.resolveAll(IDataInputViewFactory);
		}

		public function isMatchingDataInputViewFactory(name:String):Boolean
		{
			return false;
		}

		public function createDataInputController(name:String, measurements:String,
												  scheduleItemOccurrence:ScheduleItemOccurrence,
												  urlVariables:URLVariables,
												  scheduleModel:IScheduleModel,
												  viewNavigator:ViewNavigator):DataInputControllerBase
		{
			var matchingDataInputViewFactory:IDataInputViewFactory;
			for each (var dataInputViewFactory:IDataInputViewFactory in _factoryArray)
			{
				if (dataInputViewFactory.isMatchingDataInputViewFactory(name))
					matchingDataInputViewFactory = dataInputViewFactory;
			}

			if (matchingDataInputViewFactory)
				return matchingDataInputViewFactory.createDataInputController(name, measurements,
						scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
			else
				return new DataInputControllerBase(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
		}

		public function createDataInputView(name:String, measurements:String,
											scheduleItemOccurrence:ScheduleItemOccurrence):Class
		{
			var matchingDataInputViewFactory:IDataInputViewFactory;
			for each (var dataInputViewFactory:IDataInputViewFactory in _factoryArray)
			{
				if (dataInputViewFactory.isMatchingDataInputViewFactory(name))
					matchingDataInputViewFactory = dataInputViewFactory;
			}

			if (matchingDataInputViewFactory)
				return matchingDataInputViewFactory.createDataInputView(name, measurements, scheduleItemOccurrence);
			else
				return DefaultDataInputView;
		}
	}
}
