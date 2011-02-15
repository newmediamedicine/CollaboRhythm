package collaboRhythm.shared.controller.apps
{
	public class AppControllerInfo
	{
		private var _appControllerClass:Class;
		public function AppControllerInfo(appControllerClass:Class)
		{
			_appControllerClass = appControllerClass
		}

		public function get appControllerClass():Class
		{
			return _appControllerClass;
		}

		public function set appControllerClass(value:Class):void
		{
			_appControllerClass = value;
		}

	}
}