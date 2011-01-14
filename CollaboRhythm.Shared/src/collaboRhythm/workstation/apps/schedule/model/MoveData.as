package collaboRhythm.workstation.apps.schedule.model
{
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	
	public class MoveData
	{
		private var _itemIndex:Number;
		private var _documentID:String;
		private var _hour:Number;
		private var _xPosition:Number;
		private var _yBottomPosition:Number;
		private var _adherenceWindow:Number;
		private var _color:uint;
		
		public function MoveData()
		{
		}
		
		public function get hour():Number
		{
			return _hour;
		}

		public function set hour(value:Number):void
		{
			_hour = value;
		}

		public function get yBottomPosition():Number
		{
			return _yBottomPosition;
		}

		public function set yBottomPosition(value:Number):void
		{
			_yBottomPosition = value;
		}

		public function get xPosition():Number
		{
			return _xPosition;
		}

		public function set xPosition(value:Number):void
		{
			_xPosition = value;
		}

		public function get itemIndex():Number
		{
			return _itemIndex;
		}

		public function set itemIndex(value:Number):void
		{
			_itemIndex = value;
		}

		public function get documentID():String
		{
			return _documentID;
		}

		public function set documentID(value:String):void
		{
			_documentID = value;
		}
		
		public function get adherenceWindow():Number
		{
			return _adherenceWindow;
		}
		
		public function set adherenceWindow(value:Number):void
		{
			_adherenceWindow = value;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
	}
}