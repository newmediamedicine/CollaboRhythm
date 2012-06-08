package collaboRhythm.nativeExtensions.playVideo.flex
{
	import flash.external.ExtensionContext;

	public class PlayVideoInterface
	{
		private var _context:ExtensionContext;

		public function PlayVideoInterface()
		{
			if (_context)
				_context = ExtensionContext.createExtensionContext("collaboRhythm.nativeExtensions.playVideo", null);
		}

		public function playVideo(videoName:String):void
		{
			_context.call("playVideo", videoName);
		}
	}
}
