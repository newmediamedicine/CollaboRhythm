package collaboRhythm.core.controller
{
	import com.daveoncode.logging.LogFileTarget;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class LogFileReader
	{
		public function LogFileReader()
		{
		}

		public static function getLogFileText():String
		{
			var file:File = getLogFile();
			if (!file.exists)
				return "";

			var fileStream:FileStream = new FileStream();

			try
			{
				fileStream.open(file, FileMode.READ);
			}
			catch (error:Error)
			{
				trace("File exists but could not be read: ", file.nativePath);
				return "";
			}

			// TODO: read the last 20 lines of text
			// grab a reasonable chunk of text from the end of the log file
			fileStream.position = Math.max(0, fileStream.bytesAvailable - 1024 * 8);
			var logText:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			logText = logText.substring(logText.indexOf("\n"));
			fileStream.close();

			return logText;
		}

		public static function getLogFile():File
		{
			var logTarget:LogFileTarget = LogFileTarget.getInstance();
			var file:File = logTarget.file;
			return file;
		}
	}
}
