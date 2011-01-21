package collaboRhythm.plugins.microhponeExamples.model
{
	import flash.media.Microphone;

	public class InputDeviceSelectorModel
	{
		private var _defaultMic:Microphone;
		private var _micSelectedIndex:int = -1;
		private var _micName:String;
		
		private var _names:Array;

		public function InputDeviceSelectorModel()
		{
		}

		public function get defaultMic():Microphone
		{
			return _defaultMic;
		}

		[Bindable]
		public function get micSelectedIndex():int
		{
			return _micSelectedIndex;
		}

		public function set micSelectedIndex(value:int):void
		{
			_micSelectedIndex = value;
		}

		[Bindable]
		public function get micName():String
		{
			return _micName;
		}

		public function set micName(value:String):void
		{
			_micName = value;
		}

		public function get names():Array
		{
			return _names;
		}

		public function set names(value:Array):void
		{
			_names = value;
		}

		public function initialize():void
		{
			_defaultMic = Microphone.getMicrophone();
			micName = _defaultMic.name;
			names = Microphone.names;
		}
	}
}