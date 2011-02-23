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
	import flash.media.Microphone;

	public class InputDeviceSelectorModel
	{
		private var _defaultMic:Microphone;
		private var _micSelectedIndex:int = -1;
		private var _micName:String;
		
		private var _names:Array;

		public function InputDeviceSelectorModel()
		{
		}

		public function get defaultMic():Microphone
		{
			return _defaultMic;
		}

		[Bindable]
		public function get micSelectedIndex():int
		{
			return _micSelectedIndex;
		}

		public function set micSelectedIndex(value:int):void
		{
			_micSelectedIndex = value;
		}

		[Bindable]
		public function get micName():String
		{
			return _micName;
		}

		public function set micName(value:String):void
		{
			_micName = value;
		}

		public function get names():Array
		{
			return _names;
		}

		public function set names(value:Array):void
		{
			_names = value;
		}

		public function initialize():void
		{
			_defaultMic = Microphone.getMicrophone();
			micName = _defaultMic.name;
			names = Microphone.names;
		}
	}
}