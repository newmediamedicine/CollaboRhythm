package collaboRhythm.workstation.model.settings
{
	public class ComponentLayout
	{
		private var _id:String;
		private var _percentWidth:Number;
		private var _percentHeight:Number;

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get percentWidth():Number
		{
			return _percentWidth;
		}

		public function set percentWidth(value:Number):void
		{
			_percentWidth = value;
		}

		public function get percentHeight():Number
		{
			return _percentHeight;
		}

		public function set percentHeight(value:Number):void
		{
			_percentHeight = value;
		}
		
		public function ComponentLayout(id:String, percentWidth:Number, percentHeight:Number)
		{
			_id = id;
			_percentWidth = percentWidth;
			_percentHeight = percentHeight;
		}
	}
}