package collaboRhythm.plugins.foraD40b.model
{
	public class ComplexCarbsItem
	{
		private var _imageClass:Class;
		private var _text:String;
		private var _example:String;

		public function ComplexCarbsItem(imageClass:Class, text:String, example:String)
		{
			_imageClass = imageClass;
			_text = text;
			_example = example;
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

		public function get example():String
		{
			return _example;
		}

		public function set example(value:String):void
		{
			_example = value;
		}
	}
}
