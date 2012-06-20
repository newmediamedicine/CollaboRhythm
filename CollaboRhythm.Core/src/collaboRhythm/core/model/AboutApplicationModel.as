package collaboRhythm.core.model
{

	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import collaboRhythm.shared.model.settings.Settings;

	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;

	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.getQualifiedClassName;

	import mx.core.FlexGlobals;

	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class AboutApplicationModel
	{
		private var _appName:String;
		private var _appVersion:String;
		private var _appCopyright:String;
		private var _appModificationDate:Date;
		private static const dateFormatter:DateFormatter = new DateFormatter();
		private var _appModificationDateString:String;
		private var _updater:NativeApplicationUpdater;
		private var _settings:Settings;
		private var _isUpdateAvailable:Boolean;
		private var _appUpdateVersion:String;
		private var _updaterState:String;
		private var _appUpdateStatus:String;
		private var _updaterCheckedDate:Date;
		protected var _logger:ILogger;
		private var _downloading:Boolean;
		private var _isUpdateDescriptorAvailable:Boolean;

		public function AboutApplicationModel()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
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
			initializeUpdater();
		}

		private function initializeUpdater():void
		{
			if (_updater == null)
			{
				if (settings && settings.applicationUpdateDescriptorURL)
				{
					updater = new NativeApplicationUpdater();
					_updater.updateURL = settings.applicationUpdateDescriptorURL;
					updaterState = _updater.currentState;
					_updater.initialize();
					updaterState = _updater.currentState;
					if (_updater.currentState == NativeApplicationUpdater.READY)
					{
						_updater.addEventListener(UpdateEvent.CHECK_FOR_UPDATE, updater_checkForUpdateHandler);
						_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, updater_updateStatus);
						_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, updater_updateError);
						_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
						_updater.checkNow();
						updaterState = _updater.currentState;
					}
					isUpdateDescriptorAvailable = true;
				}
				else
				{
					updateAppUpdateStatus();
					isUpdateDescriptorAvailable = false;
				}
			}
		}

		private function updater_updateStatus(event:StatusUpdateEvent):void
		{
			// Don't download yet; just check and then let the user decide what to do
			event.preventDefault();
			_updaterCheckedDate = new Date();
			appUpdateVersion = _updater == null ? null : _updater.updateVersion;
			isUpdateAvailable = _updater != null && _updater.isNewerVersion;
			updaterState = _updater.currentState;
			updateAppUpdateStatus();
		}

		private function updater_updateError(event:StatusUpdateErrorEvent):void
		{
			_logger.error(event.toString());
			_updaterCheckedDate = new Date();
			_updater.currentState = NativeApplicationUpdater.READY;
			updaterState = _updater.currentState;
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

		public function get settings():Settings
		{
			return _settings;
		}

		public function set settings(value:Settings):void
		{
			_settings = value;
			initializeUpdater();
		}

		[Bindable]
		public function get appUpdateVersion():String
		{
			return _appUpdateVersion;
		}

		public function set appUpdateVersion(value:String):void
		{
			_appUpdateVersion = value;
			updateAppUpdateStatus();
		}

		private function updateAppUpdateStatus():void
		{
			if (_updater)
			{
				var checkedDateClause:String = '(' +
						(_updaterCheckedDate == null ? 'check failed' : dateFormatter.format(_updaterCheckedDate)) +
						')';
				appUpdateStatus =
						updaterState == NativeApplicationUpdater.CHECKING ?
								'Checking for update...' :
								(isUpdateAvailable ? ('New version available ' + checkedDateClause + ': ' +
										appUpdateVersion) : ('No updates available ' + checkedDateClause));
			}
			else
			{
				appUpdateStatus = "Update server not set. Cannot check for updates.";
			}
		}

		[Bindable]
		public function get updaterState():String
		{
			return _updaterState;
		}

		public function set updaterState(value:String):void
		{
			_updaterState = value;
			updateAppUpdateStatus();
		}

		[Bindable]
		public function get appUpdateStatus():String
		{
			return _appUpdateStatus;
		}

		public function set appUpdateStatus(value:String):void
		{
			_appUpdateStatus = value;
		}

		private function updater_checkForUpdateHandler(event:UpdateEvent):void
		{
		}

		public function checkForUpdate():void
		{
			if (_updater)
			{
				if (_updater.currentState == NativeApplicationUpdater.AVAILABLE)
					_updater.currentState = NativeApplicationUpdater.READY;

				if (_updater.currentState == NativeApplicationUpdater.READY)
				{
					_updater.checkNow();
					updaterState = _updater.currentState;
				}
			}
		}

		public function updateNow():void
		{
			if (_updater && _updater.currentState == NativeApplicationUpdater.AVAILABLE)
			{
				downloading = true;
				_updater.downloadUpdate();
			}
		}

		[Bindable]
		public function get downloading():Boolean
		{
			return _downloading;
		}

		public function set downloading(value:Boolean):void
		{
			_downloading = value;
		}

		[Bindable]
		public function get updater():NativeApplicationUpdater
		{
			return _updater;
		}

		public function set updater(value:NativeApplicationUpdater):void
		{
			_updater = value;
		}

		private function updater_downloadCompleteHandler(event:UpdateEvent):void
		{
			_logger.info("Application update " + _updater.updateVersion + " downloaded from " + _updater.updatePackageURL + " and saved to " + _updater.downloadedFile.nativePath);
		}

		[Bindable]
		public function get isUpdateAvailable():Boolean
		{
			return _isUpdateAvailable;
		}

		public function set isUpdateAvailable(value:Boolean):void
		{
			_isUpdateAvailable = value;
		}

		[Bindable]
		public function get isUpdateDescriptorAvailable():Boolean
		{
			return _isUpdateDescriptorAvailable;
		}

		public function set isUpdateDescriptorAvailable(value:Boolean):void
		{
			_isUpdateDescriptorAvailable = value;
		}
	}
}
