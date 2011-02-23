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
package collaboRhythm.plugins.examples.microphoneExamples.model
{
	import com.adobe.audio.effects.EffectDriver;
	import com.adobe.audio.format.WAVWriter;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	[Event(name="soundComplete", type="flash.events.Event")]
	
	public class SoundRecorderModel extends EventDispatcher
	{
		private var _recordedData:ByteArray = new ByteArray();
		private var _currentBufferingData:ByteArray = new ByteArray();
		
		private var _isPlaying:Boolean = false;
		private var _isLocked:Boolean = false;
		private var _bufferIndex:int = 0;
		private var _startRecording:Number = 0;
		
		private var _mic:Microphone;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _effectDriver:EffectDriver;
		
		private var _micStats:String = " 0s";
		private var _micTimer:String = " 0s";
		
		private var _quality:int = 8192;
		private var _volume:Number = 60;
		private var _speed:Number = 0;

		private var playbackLatency:Number = 0;

		public function SoundRecorderModel()
		{
			effectDriver = new EffectDriver();
		}

		public function get speed():Number
		{
			return _speed;
		}

		public function set speed(value:Number):void
		{
			_speed = value;
		}

		public function get volume():Number
		{
			return _volume;
		}

		public function set volume(value:Number):void
		{
			_volume = value;
		}

		/**
		 * The quality used for playing back the sound. Normal values: between 2048 and 8192. Default is 8192. 
		 * @return 
		 * 
		 */
		public function get quality():int
		{
			return _quality;
		}

		public function set quality(value:int):void
		{
			_quality = value;
		}

		public function get isRecording():Boolean
		{
			return mic && mic.hasEventListener(SampleDataEvent.SAMPLE_DATA);
		}

		public function get recordedData():ByteArray
		{
			return _recordedData;
		}

		public function set recordedData(value:ByteArray):void
		{
			_recordedData = value;
		}

		public function get currentBufferingData():ByteArray
		{
			return _currentBufferingData;
		}

		public function set currentBufferingData(value:ByteArray):void
		{
			_currentBufferingData = value;
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		public function set isPlaying(value:Boolean):void
		{
			_isPlaying = value;
		}

		public function get isLocked():Boolean
		{
			return _isLocked;
		}

		public function set isLocked(value:Boolean):void
		{
			_isLocked = value;
		}

		public function get bufferIndex():int
		{
			return _bufferIndex;
		}

		public function set bufferIndex(value:int):void
		{
			_bufferIndex = value;
		}

		public function get recordingStartTime():Number
		{
			return _startRecording;
		}

		public function set recordingStartTime(value:Number):void
		{
			_startRecording = value;
		}

		public function get mic():Microphone
		{
			return _mic;
		}

		public function set mic(value:Microphone):void
		{
			_mic = value;
		}

		public function get sound():Sound
		{
			return _sound;
		}

		public function set sound(value:Sound):void
		{
			_sound = value;
		}

		public function get channel():SoundChannel
		{
			return _channel;
		}

		public function set channel(value:SoundChannel):void
		{
			_channel = value;
		}

		public function get effectDriver():EffectDriver
		{
			return _effectDriver;
		}

		public function set effectDriver(value:EffectDriver):void
		{
			_effectDriver = value;
		}

		[Bindable]
		public function get micStats():String
		{
			return _micStats;
		}

		public function set micStats(value:String):void
		{
			_micStats = value;
		}

		[Bindable]
		public function get micTimer():String
		{
			return _micTimer;
		}

		public function set micTimer(value:String):void
		{
			_micTimer = value;
		}
		
		public function recordData():void
		{
			if (mic == null)
				mic = Microphone.getMicrophone();
			
			bufferIndex = 0;
			recordingStartTime = getTimer() + 500;
			currentBufferingData = new ByteArray();
			recordedData = new ByteArray();
			mic.rate = 44;
			mic.setSilenceLevel(0, 500);
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, mic_sampleDataHandler);
		}

		private function mic_sampleDataHandler(event:SampleDataEvent):void
		{
//			trace("mic_sampleDataHandler", getTimer(), mic.name);
			
			var isWritten:Boolean = false;
			// Lock ByteArray to not read/write over eachother
			while (!isWritten)
			{
				if (!isLocked)
				{
					if (event.position*4 != currentBufferingData.position)
					{
						var wlen:int = ((event.position*4) - currentBufferingData.position)/4;
						for (var i:int = 0;i<wlen;i++)
							currentBufferingData.writeFloat(0);
					}
					currentBufferingData.writeBytes(event.data);
					isWritten = true;
					micStats = " " + (event.position/44100).toFixed(1) + "s";
				}
			}
		}
		
		public function stopRecording():void
		{
			if (channel)
				channel.stop();
			if (!mic)
				return;
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, mic_sampleDataHandler);
		}
		
		public function get isSaveEnabled():Boolean
		{
			return currentBufferingData.length > 0;
		}
		
		public function get isPlayEnabled():Boolean
		{
			return isSaveEnabled;
		}
		
		public function get isRecordEnabled():Boolean
		{
//			return !isPlayingFlag;
			return true;
		}
		
		public function computeRecordingSpectrum(bytes:ByteArray):void
		{
			var currentTime:Number = getTimer() - recordingStartTime;
			if (currentTime <= 0)
			{
				while (bytes.length < 256*4)
					bytes.writeFloat(0);
				bytes.position = 0;
			}
			else
			{
				micTimer = " " + ((currentTime-450)/1000).toFixed(1) + "s";
				
				isLocked = true;
				var curPos:int = currentBufferingData.position;
				bufferIndex = int((currentTime * 44.1) * 4); // Sample position * float size
				bufferIndex = (bufferIndex-(bufferIndex%4)); // Make it even so it reads Floats in the right place
				currentBufferingData.position = bufferIndex;
				var chunkMin:Number = Math.min(256*4, currentBufferingData.bytesAvailable);
				currentBufferingData.readBytes(bytes, 0, chunkMin);
				while (bytes.length < 256*4)
					bytes.writeFloat(0);
				bytes.position = 0;
				currentBufferingData.position = curPos;
				isLocked = false;
			}
		}
		
		public function saveToFile(file:File):void
		{
			// Process File with any affects First
			currentBufferingData.position = 0;
			recordedData.clear();
			effectDriver.effectInit();
			effectDriver.volume = volume;
			effectDriver.speed = speed;
			while (currentBufferingData.bytesAvailable > 0)
			{
				recordedData.writeFloat(effectDriver.processEffect(currentBufferingData));
			}
			
			try
			{
				var ww:WAVWriter = new WAVWriter();
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				ww.numOfChannels = 1;
				recordedData.position = 0;
				ww.processSamples(fileStream, recordedData, 44100, 1);
				recordedData.position = 0; // Reset for playhead
				fileStream.close();
				file.openWithDefaultApplication();
			}
			catch (error:Error)
			{
				//trace("error: " + error.message);
			}
		}
		
		public function startPlaying():void
		{
			isPlaying = true;
			currentBufferingData.position = 0;
			recordedData.clear();
			currentBufferingData.readBytes(recordedData, 0, currentBufferingData.length);
			
			recordedData.position = 0;
			effectDriver.effectInit();
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sound_sampleDataHandler);
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
		}

		public function stopPlaying():void
		{
			if (channel)
				channel.stop();
			channel_soundCompleteHandler(null);
		}
		
		private function channel_soundCompleteHandler(event:Event):void 
		{
			if (event)
				dispatchEvent(event);
			else
				dispatchEvent(new Event(Event.SOUND_COMPLETE));
			
			if (channel && channel.hasEventListener(Event.SOUND_COMPLETE))
				channel.removeEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
			
			if (sound)
				sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sound_sampleDataHandler);
			sound = null;
			channel = null;
			isPlaying = false;
			recordedData.position = 0;
		}
		
		private function sound_sampleDataHandler(event:SampleDataEvent):void
		{
			if (recordedData.bytesAvailable <= 0)
				return;
			if (channel)
				playbackLatency = ((event.position/44.1) - channel.position);
			
			var length:int = int(quality);			
			for (var i:int = 0; i < length; i++)
			{
				effectDriver.volume = volume;
				effectDriver.speed = speed;
				effectDriver.range = 20;
				var sample:Number = effectDriver.processEffect(recordedData);
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}
	}
}
