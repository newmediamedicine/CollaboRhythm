package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.plugins.schedule.shared.model.IDataInputViewFactory;
	import collaboRhythm.plugins.schedule.view.DefaultDataInputView;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.IComponentContainer;

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
