package collaboRhythm.shared.messages.model
{
	import collaboRhythm.shared.model.healthRecord.document.Message;

	public interface IIndividualMessageHealthRecordService
	{
		function createAndSendMessage(body:String):Message
	}
}
