package collaboRhythm.shared.pluginsDeployment
{
	import collaboRhythm.ane.applicationMessaging.actionScript.ApplicationMessaging;

	public class CollaboRhythmLauncher
	{
		public static const COLLABORHYTHM_TABLET_ANDROID_PACKAGE:String = "air.CollaboRhythm.Tablet.debug";

		public function CollaboRhythmLauncher()
		{
		}

		public static function launch():void
		{
			var messaging:ApplicationMessaging = new ApplicationMessaging();
			messaging.intent(COLLABORHYTHM_TABLET_ANDROID_PACKAGE);
		}
	}
}
