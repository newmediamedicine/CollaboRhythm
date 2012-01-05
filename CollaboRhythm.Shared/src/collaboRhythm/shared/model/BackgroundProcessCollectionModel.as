package collaboRhythm.shared.model
{

    import com.theory9.data.types.OrderedMap;

    public class BackgroundProcessCollectionModel
	{
		private var _processes:OrderedMap = new OrderedMap();
		private var _isRunning:Boolean;
		private var _summary:String;
		public function BackgroundProcessCollectionModel()
		{
		}

		public function updateProcess(processKey:String, message:String, isRunning:Boolean):void
		{
			var process:BackgroundProcessModel = getProcessByKey(processKey);
			if (isRunning)
			{
				if (!process)
				{
					process = new BackgroundProcessModel(processKey, message);
					_processes.addKeyValue(processKey, process);
				}
				process.message = message;
			}
			else
			{
				if (process)
					_processes.removeByKey(processKey);
			}

			updateState();
		}

		private function updateState():void
		{
			isRunning = _processes.length > 0;
			if (isRunning)
			{
				if (_processes.length == 1)
				{
					var singleProcess:BackgroundProcessModel = _processes.getValueByIndex(0) as BackgroundProcessModel;
					summary = singleProcess.message;
				}
				else
				{
					summary = _processes.length.toString() + " processes running...";
				}
			}
		}

		private function getProcessByKey(processKey:String):BackgroundProcessModel
		{
			return _processes.getValueByKey(processKey) as BackgroundProcessModel;
		}

		[Bindable]
		public function get summary():String
		{
			return _summary;
		}

		public function set summary(value:String):void
		{
			_summary = value;
		}

		[Bindable]
		public function get isRunning():Boolean
		{
			return _isRunning;
		}

		public function set isRunning(value:Boolean):void
		{
			_isRunning = value;
		}
	}
}
