package collaboRhythm.tablet.model
{
	import flash.system.Capabilities;

	import mx.core.DPIClassification;

	import mx.core.RuntimeDPIProvider;

	public class EmulatorDpiProvider extends RuntimeDPIProvider
		{
			override public function get runtimeDPI():Number
			{
/*
				var screenX:Number = Capabilities.screenResolutionX;
				var screenY:Number = Capabilities.screenResolutionY;
				var pixelCheck:Number = screenX * screenY;
				var pixelsDiagonal:Number = Math.sqrt((screenX * screenX) + (screenY * screenY));
				var screenSize:Number = pixelsDiagonal / Capabilities.screenDPI;
*/
				var isDebugger:Boolean = Capabilities.isDebugger;
				var playerType:String = Capabilities.playerType;

				if (playerType == "Desktop" && isDebugger)
				{
	/*
					var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
					if (nativeApplication)
					{
						var systemManager:SystemManager = Singleton.getInstance("mx.managers.ISystemManager") as SystemManager;
						if (nativeApplication.activeWindow)
						if (systemManager)
						{
							var windowWidth:Number = systemManager.width;
							var windowHeight:Number = nativeApplication.activeWindow.height;

							pixelCheck = windowWidth * windowHeight;
							pixelsDiagonal = Math.sqrt((windowWidth * windowWidth) + (windowHeight * windowHeight));

							// guess the screen size based on the aspect ratio (assumes that tablets are always landscape and 10 inches, phones are portrait and 3.5 inches)
							screenSize = (windowWidth > windowHeight) ? 10 : 3.5;
							var dpi:Number = pixelsDiagonal / screenSize;
							return classifyDPI(dpi);
						}

						//trace(nativeApplication.applicationDescriptor);
					}
	*/
					// TODO: find a way to detect the window size when running inside of ADL on the desktop and return the appropriate DPI; for now, we must manually modify the code and rebuild to get a different DPI
					// default of 160 is fine for Galaxy Tab 10.1
//					return DPIClassification.DPI_240; // Galaxy Vibrant
//					return DPIClassification.DPI_320; // Galaxy Nexus, iPhone 4
				}
				return super.runtimeDPI;
			}
		}
	}