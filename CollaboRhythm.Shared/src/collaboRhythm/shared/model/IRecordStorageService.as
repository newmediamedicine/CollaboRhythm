package collaboRhythm.shared.model
{

	import mx.collections.ArrayCollection;

	public interface IRecordStorageService
	{
		function saveChanges(record:Record, documents:ArrayCollection):void;

		function saveAllChanges(record:Record):void;
	}
}
