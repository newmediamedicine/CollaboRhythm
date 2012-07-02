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
		static private var _logger:ILogger;

		public function AudioVideoOutput()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		static public function getVideoConferencingCamera():Camera
		{
			var camera:Camera = getCamera();
			if (camera != null)
			{
				camera.setMode(320, 240, 15);
			}

			return camera;
		}

		static public function getVideoRecordingCamera():Camera
		{
			var camera:Camera = getCamera();
			if (camera != null)
			{
				camera.setMode(640, 480, 15);
				camera.setQuality(0,80);
			}

			return camera;
		}

		static public function getCamera():Camera
		{
			var camera:Camera;
			if (Camera.isSupported)
			{
				_logger.info("Initializing camera...");
				camera = Camera.getCamera("0");
				var cameraIndex:int;
				for each (var cameraName:String in Camera.names)
				{
					var currentCamera:Camera = Camera.getCamera(cameraIndex.toString());
					if (currentCamera.position == CameraPosition.FRONT || cameraName == "HP High Definition Webcam")
					{
						camera = currentCamera
					}
					cameraIndex += 1;
				}
				if (camera != null)
				{
					_logger.info("Camera initialized: " + camera.name);
				}
				else
				{
					_logger.info("No camera found. Camera NOT initialized.");
				}
			}
			else
			{
				_logger.info("Camera not supported.");
			}

			return camera;
		}

		static public function getMicrophone():Microphone
		{
			var microphone:Microphone;
			if (Microphone.isSupported)
			{
				_logger.info("Initializing microphone...");
				microphone = Microphone.getMicrophone(0);
				if (microphone != null)
				{
					//					_microphone.codec = SoundCodec.SPEEX;
					microphone.setSilenceLevel(0);
					//					_microphone.framesPerPacket = 1;
					_logger.info("Microphone initialized: " + microphone.name);
				}
				else
				{
					_logger.info("No microphone found. Microphone NOT initialized.");
				}
			}
			else
			{
				_logger.info("Microphone not supported.");
			}

			return microphone;
		}
	}
}