/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model
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
    [Bindable]
	public class AudioVideoOutput
	{
		private var _camera:Camera;
		private var _microphone:Microphone;
		
		public function AudioVideoOutput()
		{
			setCamera();
			setMicrophone();
		}
		
		private function setCamera():void
		{
			if (Camera.isSupported)
			{
                _camera = Camera.getCamera();
                var cameraIndex:int;
                for each (var cameraName:String in Camera.names)
                {
                    if (cameraName == "HP High Definition Webcam")
                    {
                        _camera = Camera.getCamera(cameraIndex.toString());
                    }
                    cameraIndex += 1;
                }
                if (_camera != null)
                {
                    _camera.setKeyFrameInterval(15);
                    _camera.setMode(320,240,15);
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

        public function set camera(value:Camera):void
        {
            _camera = value;
        }
		
		public function get microphone():Microphone
		{
			return _microphone;
		}

        public function set microphone(value:Microphone):void
        {
            _microphone = value;
        }
    }
}