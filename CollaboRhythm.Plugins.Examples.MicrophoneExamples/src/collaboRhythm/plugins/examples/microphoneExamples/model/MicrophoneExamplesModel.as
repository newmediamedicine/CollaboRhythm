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
	public class MicrophoneExamplesModel
	{
		private var _viewName:String = "(Record & Playback)";
		private var _lastViewIndex:int = 0;

		private var _currentState:String;
		
		private var _sampleMicPanelModel:SoundRecorderModel = new SoundRecorderModel();
		private var _inputDeviceSelectorModel:InputDeviceSelectorModel = new InputDeviceSelectorModel();
		
		public function MicrophoneExamplesModel()
		{
		}

		[Bindable]
		public function get inputDeviceSelectorModel():InputDeviceSelectorModel
		{
			return _inputDeviceSelectorModel;
		}

		public function set inputDeviceSelectorModel(value:InputDeviceSelectorModel):void
		{
			_inputDeviceSelectorModel = value;
		}

		[Bindable]
		public function get viewName():String
		{
			return _viewName;
		}

		public function set viewName(value:String):void
		{
			_viewName = value;
		}

		public function get lastViewIndex():int
		{
			return _lastViewIndex;
		}

		public function set lastViewIndex(value:int):void
		{
			_lastViewIndex = value;
		}

		public function get currentState():String
		{
			return _currentState;
		}

		public function set currentState(value:String):void
		{
			_currentState = value;
		}

		[Bindable]
		public function get sampleMicPanelModel():SoundRecorderModel
		{
			return _sampleMicPanelModel;
		}

		public function set sampleMicPanelModel(value:SoundRecorderModel):void
		{
			_sampleMicPanelModel = value;
		}

	}
}