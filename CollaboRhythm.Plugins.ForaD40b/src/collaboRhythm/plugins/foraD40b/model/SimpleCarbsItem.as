package collaboRhythm.plugins.foraD40b.model
{
	public class SimpleCarbsItem
	{
		private var _imageClass:Class;
		private var _text:String;

		public function SimpleCarbsItem(imageClass:Class, text:String)
		{
			_imageClass = imageClass;
			_text = text;
		}

		public function get imageClass():Class
		{
			return _imageClass;
		}

		public function set imageClass(value:Class):void
		{
			_imageClass = value;
		}

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
		}
	}
}
