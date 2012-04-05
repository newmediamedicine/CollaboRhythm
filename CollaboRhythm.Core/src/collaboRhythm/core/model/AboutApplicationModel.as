package collaboRhythm.core.model
{

	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.system.Capabilities;

	import mx.core.FlexGlobals;

	import mx.formatters.DateFormatter;

	public class AboutApplicationModel
	{
		private var _appName:String;
		private var _appVersion:String;
		private var _appCopyright:String;
		private var _appModificationDate:Date;
		private static const dateFormatter:DateFormatter = new DateFormatter();
		private var _appModificationDateString:String;

		public function AboutApplicationModel()
		{
			dateFormatter.formatString = "YYYY-MM-DD L:NN A";
		}

		public function initialize():void
		{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appDescriptor.namespace();
			appName = appDescriptor.ns::name.toString();
			appCopyright = appDescriptor.ns::copyright.toString();
			appVersion = appDescriptor.ns::versionLabel.toString();
			if (appVersion == null || appVersion.length == 0)
				appVersion = appDescriptor.ns::versionNumber.toString();

			var appFile:File = File.applicationDirectory.resolvePath(appDescriptor.ns::initialWindow.ns::content.toString());
			if (appFile.exists)
			{
				// convert the Date from local to UTC by subtracting the time zone offset
//				var offsetMilliseconds:Number = appFile.modificationDate.getTimezoneOffset() * 60 * 1000;
//				appModificationDate = new Date();
//				appModificationDate.setTime(appFile.modificationDate.getTime() - offsetMilliseconds);
				appModificationDate = appFile.modificationDate;
				appModificationDateString = dateFormatter.format(appModificationDate);
			}
		}

		[Bindable]
		public function get appName():String
		{
			return _appName;
		}

		public function set appName(value:String):void
		{
			_appName = value;
		}

		[Bindable]
		public function get appVersion():String
		{
			return _appVersion;
		}

		public function set appVersion(value:String):void
		{
			_appVersion = value;
		}

		[Bindable]
		public function get appCopyright():String
		{
			return _appCopyright;
		}

		public function set appCopyright(value:String):void
		{
			_appCopyright = value;
		}

		[Bindable]
		public function get appModificationDate():Date
		{
			return _appModificationDate;
		}

		public function set appModificationDate(value:Date):void
		{
			_appModificationDate = value;
		}

		[Bindable]
		public function get appModificationDateString():String
		{
			return _appModificationDateString;
		}

		public function set appModificationDateString(value:String):void
		{
			_appModificationDateString = value;
		}

		public function get deviceDetails():String
		{
			var nativeDpiClause:String = Capabilities.screenDPI != FlexGlobals.topLevelApplication.applicationDPI ? " (native " + Capabilities.screenDPI + " DPI)" : "";
			return "Screen " + Capabilities.screenResolutionX + " x " + Capabilities.screenResolutionY + " at " +
					FlexGlobals.topLevelApplication.applicationDPI + " DPI" + nativeDpiClause;
		}
	}
}
