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
package collaboRhythm.shared.collaboration.model
{
	import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

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
		private var _logger:ILogger;

		public function AudioVideoOutput()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			setCamera();
			setMicrophone();
		}

		private function setCamera():void
		{
			if (Camera.isSupported)
			{
				_logger.info("Initializing camera...");
                _camera = Camera.getCamera("0");
                var cameraIndex:int;
                for each (var cameraName:String in Camera.names)
                {
					var camera:Camera = Camera.getCamera(cameraIndex.toString());
					if (camera.position == CameraPosition.FRONT || cameraName == "HP High Definition Webcam")
					{
						_camera = camera
					}
                    cameraIndex += 1;
                }
                if (_camera != null)
                {
                    _camera.setMode(320,240,15);
                    _camera.setQuality(0,50);
					_logger.info("Camera initialized: " + _camera.name);
                }
				else
				{
					_logger.info("No camera found. Camera NOT initialized.");
				}
            }
		}

		private function setMicrophone():void
		{
			if (Microphone.isSupported)
			{
				_logger.info("Initializing microphone...");
				_microphone = Microphone.getMicrophone(0);
				if (_microphone != null)
				{
					_microphone.codec = SoundCodec.SPEEX;
					_microphone.setSilenceLevel(0);
					_microphone.framesPerPacket = 1;
					_logger.info("Microphone initialized: " + _microphone.name);
				}
				else
				{
					_logger.info("No microphone found. Microphone NOT initialized.");
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