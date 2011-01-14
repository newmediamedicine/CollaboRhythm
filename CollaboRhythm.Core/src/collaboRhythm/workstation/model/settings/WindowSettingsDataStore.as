package collaboRhythm.workstation.model.settings
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;

	/**
	 * Persists WindowSettings data by reading/writing XML.
	 * 
	 */
	public class WindowSettingsDataStore
	{
		private var _xml:XML;
		private var prefsXML:XML;

		public var prefsFile:File; // The preferences prefsFile
		public var stream:FileStream; // The FileStream object used to read and write prefsFile data.
		
		
		public function WindowSettingsDataStore()
		{
		}
		
		/**
		 * The method points the prefsFile File object 
		 * to the "windowSettings.xml prefsFile in the application store directory, which is uniquely 
		 * defined for the application. It then calls the readXML() method, which reads the XML data.
		 */
		private function initPreferences():void
		{ 
			prefsFile = File.applicationStorageDirectory;
			prefsFile = prefsFile.resolvePath("windowSettings.xml"); 
		}
		
		/**
		 * Called when the application is first rendered, and when the user clicks the Save button.
		 * If the preferences file *does* exist (the application has been run previously), the method 
		 * sets up a FileStream object and reads the XML data, and once the data is read it is processed. 
		 * If the file does not exist, the method calls the saveData() method which creates the file. 
		 */
		private function readXML():void 
		{
			stream = new FileStream();
			if (prefsFile.exists) {
				stream.open(prefsFile, FileMode.READ);
				processXMLData();
			}
			else
			{
				saveData();
			}
		}
		
		/**
		 * Called when the user clicks the Save button or when the window
		 * is closing.
		 */
		private function saveData():void
		{
			createXMLData(); 
			writeXMLData();
		}
		
		/**
		 * Called after the data from the prefs file has been read. The readUTFBytes() reads
		 * the data as UTF-8 text, and the XML() function converts the text to XML. The x, y,
		 * width, and height properties of the main window are then updated based on the XML data.
		 */
		private function processXMLData():void 
		{
			prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
		}
		
		/**
		 * Creates the XML object with data based on the window state 
		 * and the current time.
		 */
		private function createXMLData():void 
		{
			prefsXML = <windowSettings/>;
			prefsXML.saveDate = new Date().toString();
		}
		
		/**
		 * Called when the NativeWindow closing event is dispatched. The method 
		 * converts the XML data to a string, adds the XML declaration to the beginning 
		 * of the string, and replaces line ending characters with the platform-
		 * specific line ending character. Then sets up and uses the stream object to
		 * write the data.
		 */
		private function writeXMLData():void 
		{
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			outputString += prefsXML.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);
			stream = new FileStream();
			stream.open(prefsFile, FileMode.WRITE);
			stream.writeUTFBytes(outputString);
			stream.close();
		}
		
		public function readWindowSettings():WindowSettings
		{
			initPreferences();
			readXML();
			
			var windowSettings:WindowSettings = new WindowSettings();
			
			if (prefsXML.fullScreen.length() == 1)
				windowSettings.fullScreen = prefsXML.fullScreen == Boolean(true).toString();
			
			if (prefsXML.zoom.length() == 1)
				windowSettings.zoom = Number(prefsXML.zoom);
			
			if (isNaN(windowSettings.zoom))
				windowSettings.zoom = 0;
			
			for each (var windowStateXml:XML in prefsXML.windowStates.windowState)
			{
				var windowState:WindowState = new WindowState();
				windowState.displayState = windowStateXml.displayState.toString();
				windowState.bounds = new Rectangle(
					Number(windowStateXml.bounds.@x) ,
					Number(windowStateXml.bounds.@y),
					Number(windowStateXml.bounds.@width),
					Number(windowStateXml.bounds.@height));
				
				for each (var spaceIdXml:XML in windowStateXml.spaces.spaceId)
				{
					windowState.spaces.push(spaceIdXml.toString());
				}
					
				for each (var componentLayoutXml:XML in windowStateXml.componentLayouts.componentLayout)
				{
					var id:String = componentLayoutXml.@id.toString();
					var percentWidth:Number = Number(componentLayoutXml.@percentWidth);
					var percentHeight:Number = Number(componentLayoutXml.@percentHeight);
					
					if (id != null && !isNaN(percentWidth) && !isNaN(percentHeight))
						windowState.componentLayouts.push(new ComponentLayout(id, percentWidth, percentHeight));
				}
					
				windowSettings.windowStates.push(windowState);
			}
			
			return windowSettings;
		}
		
		public function saveWindowSettings(windowSettings:WindowSettings):void
		{
			initPreferences();
			createXMLData();
			prefsXML.fullScreen = windowSettings.fullScreen;
			prefsXML.zoom = windowSettings.zoom;
			
			prefsXML.appendChild(<windowStates/>);
				
			for each (var windowState:WindowState in windowSettings.windowStates)
			{
				var windowStateXml:XML =
					<windowState>
						<displayState>{windowState.displayState}</displayState>
						<bounds x={windowState.bounds.x} y={windowState.bounds.y} width={windowState.bounds.width} height={windowState.bounds.height}/>
					</windowState>;
				
				windowStateXml.appendChild(<spaces/>);
				
				for each (var spaceId:String in windowState.spaces)
				{
					windowStateXml.spaces.appendChild(<spaceId>{spaceId}</spaceId>);
				}
				
				windowStateXml.appendChild(<componentLayouts/>);
				
				for each (var componentLayout:ComponentLayout in windowState.componentLayouts)
				{
					windowStateXml.componentLayouts.appendChild(<componentLayout id={componentLayout.id} percentWidth={componentLayout.percentWidth} percentHeight={componentLayout.percentHeight}/>);
				}
				
				prefsXML.windowStates.appendChild(windowStateXml);
			}
			
			writeXMLData();
		}
	}
}