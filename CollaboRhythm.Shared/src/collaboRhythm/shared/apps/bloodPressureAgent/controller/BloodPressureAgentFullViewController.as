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
package collaboRhythm.shared.apps.bloodPressureAgent.controller
{
	import collaboRhythm.shared.apps.bloodPressureAgent.view.BloodPressureAgentFullView;
	import collaboRhythm.shared.controller.apps.AppEvent;
	import collaboRhythm.shared.model.CollaborationRoomNetConnectionServiceProxy;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	public class BloodPressureAgentFullViewController extends EventDispatcher
	{
		private var _bloodPressureFullView:BloodPressureAgentFullView;
		
		private var _avatarLoader:Loader = new Loader();
		private var _vHostPlayer:MovieClip;
		private var _currentInstruction:Number = 1;
		
		public function BloodPressureAgentFullViewController(bloodPressureFullView:BloodPressureAgentFullView)
		{
			_bloodPressureFullView = bloodPressureFullView;
			
			var urlRequest:URLRequest = new URLRequest("http://content.oddcast.com/vhss/vhss_v5.swf?doc=http%3A%2F%2Fvhss-d.oddcast.com%2Fphp%2FplayScene%2Facc%3D516572%2Fss%3D1779797%2Fsl%3D2057315&acc=516572&bgcolor=0x&embedid=80ec2b5f44fccfc450f67be31743ba4b");
			_avatarLoader.scaleX = _avatarLoader.scaleY = 3.6;
			_avatarLoader.x = 100;
			_avatarLoader.y = -150;
			_avatarLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler)
			_avatarLoader.load(urlRequest);
		}
		
		public function get currentInstruction():Number
		{
			return _currentInstruction;
		}

		public function set currentInstruction(value:Number):void
		{
			_currentInstruction = value;
		}

		public function get avatarLoader():Loader
		{
			return _avatarLoader;
		}
		
		public function set avatarLoader(value:Loader):void
		{
			_avatarLoader = value;
		}
		
		private function completeHandler(event:Event):void
		{
			_vHostPlayer = MovieClip(_avatarLoader.content);
			//			_vHostPlayer.addEventListener("vh_sceneLoaded", instructBloodPressure);
		}
		
		public function clickHandler():void
		{
			if (_bloodPressureFullView.dialogueMode == "LivingRoom")
			{
				if (_currentInstruction == 1)
				{
					sayText("Good morning Scott. Did I hear my name?");
				}
				else if (_currentInstruction == 2)
				{
					sayText("I see that your blood pressure is elevated. Don't worry, I've been keeping an eye on this. Let me show you.");
				}
				else if (_currentInstruction == 3)
				{
					showResults();
				}
			}
			else if (_bloodPressureFullView.dialogueMode == "CollaborationRoom")
			{
				if (_currentInstruction == 1)
				{
					sayText("Scott has been doing a great job with his diet and exercise, but his medication adherence has not been optimal.");
				}
				else if (_currentInstruction == 2)
				{
					showResults();
				}
			}
			_currentInstruction += 1;
		}
		
		public function restart():void
		{
			_bloodPressureFullView.instructButton.visible = true;
			_bloodPressureFullView.skipButton.visible = true;
			_currentInstruction = 1;
			_bloodPressureFullView.textLabel.text = "";
			_bloodPressureFullView.multipleChoiceButton1.visible = false;
			_bloodPressureFullView.multipleChoiceButton2.visible = false;
			_bloodPressureFullView.multipleChoiceButton4.visible = false;
			_bloodPressureFullView.multipleChoiceButton5.visible = false;
			_bloodPressureFullView.multipleChoiceButton6.visible = false;
			_bloodPressureFullView.whyDoYouAskButton.visible = false;
			_bloodPressureFullView.instructions1Image.visible = false;
			_bloodPressureFullView.instructions2Image.visible = false;
			_bloodPressureFullView.instructions3Image.visible = false;
			_bloodPressureFullView.instructions4Image.visible = false;
		}
		
		public function instructBloodPressure():void
		{
			_bloodPressureFullView.instructButton.visible = false;
			_bloodPressureFullView.skipButton.visible = false;
			_bloodPressureFullView.textLabel.text = "In the past 30 minutes, have you:";
			sayText("Glad to help you Robert. First, have you done any of these in the past 30 minutes?");
			_bloodPressureFullView.multipleChoiceButton1.visible = true;
			_bloodPressureFullView.multipleChoiceButton2.visible = true;
			_bloodPressureFullView.multipleChoiceButton4.visible = true;
			_bloodPressureFullView.multipleChoiceButton5.visible = true;
			_bloodPressureFullView.multipleChoiceButton6.visible = true;
			_bloodPressureFullView.whyDoYouAskButton.visible = true;
		}
		
		public function skip():void
		{
//			sayText("Excellent, Robert. Always glad to help if you have any questions in the future. Go ahead and take your blood pressure now.");
		}
		
		public function noneOfTheAbove():void
		{
			_bloodPressureFullView.textLabel.text = "";
			_bloodPressureFullView.multipleChoiceButton1.visible = false;
			_bloodPressureFullView.multipleChoiceButton2.visible = false;
			_bloodPressureFullView.multipleChoiceButton4.visible = false;
			_bloodPressureFullView.multipleChoiceButton5.visible = false;
			_bloodPressureFullView.multipleChoiceButton6.visible = false;
			_bloodPressureFullView.whyDoYouAskButton.visible = false;
			sayText("Excellent, then this is a good time to take your blood pressure.");
			sayText("First, sit in a comfortable chair with your feet flat on the floor, and relax for a few minutes.");
			_bloodPressureFullView.instructions1Image.visible = true;
			_bloodPressureFullView.okButton.visible = true;
		}
		
		public function multipleChoiceOther(action:String):void
		{
			_bloodPressureFullView.textLabel.text = "";
			_bloodPressureFullView.multipleChoiceButton1.visible = false;
			_bloodPressureFullView.multipleChoiceButton2.visible = false;
			_bloodPressureFullView.multipleChoiceButton4.visible = false;
			_bloodPressureFullView.multipleChoiceButton5.visible = false;
			_bloodPressureFullView.multipleChoiceButton6.visible = false;
			_bloodPressureFullView.whyDoYouAskButton.visible = false;
			
			sayText("OK. I will make a note of that with the measurement that we get.");
			sayText("First, sit in a comfortable chair with your feet flat on the floor, and relax for a few minutes.");
			_bloodPressureFullView.instructions1Image.visible = true;
			_bloodPressureFullView.okButton.visible = true;
		}
		
		public function whyDoYouAskButton():void
		{
			_bloodPressureFullView.textLabel.text = "";
			_bloodPressureFullView.multipleChoiceButton1.visible = false;
			_bloodPressureFullView.multipleChoiceButton2.visible = false;
			_bloodPressureFullView.multipleChoiceButton4.visible = false;
			_bloodPressureFullView.multipleChoiceButton5.visible = false;
			_bloodPressureFullView.multipleChoiceButton6.visible = false;
			_bloodPressureFullView.whyDoYouAskButton.visible = false;
			
			_bloodPressureFullView.hypertensionEducation.visible = true;
			_bloodPressureFullView.okButton.visible = true;
			sayText("Good question Robert.");
			sayText("Let's look at this diagram that Dr. King showed you the other day. You can see that eating, exercising, smoking, and drinking alcohol all affect blood pressure.");
			sayText("We will be able to interpret your results better if we track these behaviors together.");		
//			sayText("Since short term effects and long term effects are different, focusing on the last half hour first is helpful.");
		}
		
		public function OK():void
		{
			_currentInstruction += 1;
			if (_currentInstruction == 2)
			{
				sayText("Now grip the blood pressure cuff on the white plastic handle and slide the cuff onto your upper arm.");
				sayText("Make sure that the blue line and the tubing line up on the inside part of your arm.");
				_bloodPressureFullView.instructions1Image.visible = false;
				_bloodPressureFullView.instructions2Image.visible = true;
			}
			else if (_currentInstruction == 3)
			{
				sayText("Close the cuff, and rest your arm on a table with your palm up.");
				sayText("The cuff should be at the level of your heart.");
				_bloodPressureFullView.instructions2Image.visible = false;
				_bloodPressureFullView.instructions3Image.visible = true;
			}
			else if (_currentInstruction == 4)
			{
				sayText("Once you are in a relaxed position, hit the start button on the right hand side of the blood pressure meter.");
				_bloodPressureFullView.instructions3Image.visible = false;
				_bloodPressureFullView.instructions4Image.visible = true;
			}
			else if (_currentInstruction == 5)
			{
				_bloodPressureFullView.instructions4Image.visible = false;
				sayText("Thanks Robert, I have your blood pressure now.");
				sayText("As you know, your blood pressure has been elevated for the past two weeks that we have been checking it together.");
				sayText("This measurement was elevated as well, let me show you the results.");
				sayText("I am also going to let Dr. King know about your consistently high blood pressure so that he can help you manage it.");
			}
			else if (_currentInstruction == 6)
			{
				_bloodPressureFullView.okButton.visible = false;
				showResults();
				restart();
			}
		}
		
		private function showResults():void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, null, null, "Blood Pressure Review"));
		}
		
		private function sayText(text:String):void
		{
			_vHostPlayer.sayText(text, 1, 1, 2);
		}
	}
}