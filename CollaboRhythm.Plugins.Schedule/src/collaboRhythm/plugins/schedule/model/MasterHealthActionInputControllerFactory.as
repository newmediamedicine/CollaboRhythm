package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.plugins.schedule.controller.DefaultDataInputController;
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IDataInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.view.DefaultDataInputView;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class MasterHealthActionInputControllerFactory implements IDataInputControllerFactory
	{
		private var _factoryArray:Array;

		public function MasterHealthActionInputControllerFactory(componentContainer:IComponentContainer)
		{
			_factoryArray = componentContainer.resolveAll(IDataInputControllerFactory);
		}

		public function isMatchingDataInputControllerFactory(name:String):Boolean
		{
			return false;
		}

		public function createHealthActionInputController(name:String, measurements:String,
												  scheduleItemOccurrence:ScheduleItemOccurrence,
												  urlVariables:URLVariables,
												  scheduleModel:IScheduleModel,
												  viewNavigator:ViewNavigator):DataInputControllerBase
		{
			var matchingDataInputControllerFactory:IDataInputControllerFactory;
			for each (var dataInputControllerFactory:IDataInputControllerFactory in _factoryArray)
			{
				if (dataInputControllerFactory.isMatchingDataInputControllerFactory(name))
					matchingDataInputControllerFactory = dataInputControllerFactory;
			}

			if (matchingDataInputControllerFactory)
				return matchingDataInputControllerFactory.createHealthActionInputController(name, measurements,
						scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
			else
				return new DataInputControllerBase(scheduleItemOccurrence, urlVariables, scheduleModel, viewNavigator);
		}
	}
}
