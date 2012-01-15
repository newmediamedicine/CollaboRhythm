package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;

	public interface IDataInputView
    {
        function get dataInputModel():DataInputModelBase;
		function get dataInputController():DataInputControllerBase;
    }
}
