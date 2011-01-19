package collaboRhythm.workstation.model
{
	import flash.media.Camera;
	import flash.media.Microphone;

	/**
	 * 
	 * @author jom
	 * 
	 * Models the audio and video output from the local user.
	 * 
	 */
	public class AudioVideoOutput
	{
		private var _camera:Camera;
		private var _microphone:Microphone;
		
		public function AudioVideoOutput()
		{
			setCamera();
//			setMicrophone();	
		}
		
		private function setCamera():void
		{
			if (Camera.isSupported)
			{
				_camera = Camera.getCamera();
				if (_camera != null)
				{
		//			_camera.setKeyFrameInterval(9);
					_camera.setMode(640,480,15);
					_camera.setQuality(0,80);
				}
			}
		}
		
		private function setMicrophone():void
		{
			if (Microphone.isSupported)
			{
				_microphone = Microphone.getMicrophone();
				if (_microphone != null)
				{
					_microphone.gain=85;
					_microphone.rate=11;
					_microphone.setSilenceLevel(15,2000);
				}
			}
		}
		
		public function get camera():Camera
		{
			return _camera;
		}
		
		public function get microphone():Microphone
		{
			return _microphone;
		}
	}
}