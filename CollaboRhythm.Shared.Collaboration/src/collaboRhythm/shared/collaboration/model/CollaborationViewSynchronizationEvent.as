package collaboRhythm.shared.collaboration.model
{
	import flash.events.Event;

	public class CollaborationViewSynchronizationEvent extends Event
	{
		private var _synchronizeFunction:String;
		private var _synchronizeData:*;
		private var _initiatedLocally:Boolean;

		public function CollaborationViewSynchronizationEvent(type:String, synchronizeFunction:String,
															  synchronizeData:*, initiatedLocally:Boolean)
		{
			super(type);

			_synchronizeFunction = synchronizeFunction;
			_synchronizeData = synchronizeData;
			_initiatedLocally = initiatedLocally;
		}

		public function get synchronizeFunction():String
		{
			return _synchronizeFunction;
		}

		public function set synchronizeFunction(value:String):void
		{
			_synchronizeFunction = value;
		}

		public function get synchronizeData():*
		{
			return _synchronizeData;
		}

		public function set synchronizeData(value:*):void
		{
			_synchronizeData = value;
		}

		public function get initiatedLocally():Boolean
		{
			return _initiatedLocally;
		}

		public function set initiatedLocally(value:Boolean):void
		{
			_initiatedLocally = value;
		}
	}
}
