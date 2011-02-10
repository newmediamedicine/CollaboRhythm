/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.shared.bloodSolutesSimulation.view
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	
	import flash.display.Sprite;

	public class BodyInfo
	{
		private var _sprite:Sprite;
		private var _pumpAffinity:int;
		private var _isSolute:Boolean;
		private var _isPlug:Boolean;
		private var _isAntibody:Boolean;
		private var _hasBeenBlocked:Boolean;
		private var _index:int;
		private var _shouldBeDestroyed:Boolean;
		private var _plugJoint:b2Joint;
		private var _stuckTime:Number = 0;
		private var _stuckPosition:b2Vec2;
		private var _body:b2Body;
		
		public function BodyInfo()
		{
		}

		public function get body():b2Body
		{
			return _body;
		}

		public function set body(value:b2Body):void
		{
			_body = value;
		}

		public function get stuckPosition():b2Vec2
		{
			return _stuckPosition;
		}

		public function set stuckPosition(value:b2Vec2):void
		{
			_stuckPosition = value;
		}

		public function get stuckTime():Number
		{
			return _stuckTime;
		}

		public function set stuckTime(value:Number):void
		{
			_stuckTime = value;
		}

		/**
		 * The joint for this body (for attaching an antibody to a solute, or a plug to a pump location). 
		 * @return the joint or null if there is no joint
		 * 
		 */
		public function get plugJoint():b2Joint
		{
			return _plugJoint;
		}

		public function set plugJoint(value:b2Joint):void
		{
			_plugJoint = value;
		}

		public function get shouldBeDestroyed():Boolean
		{
			return _shouldBeDestroyed;
		}

		public function set shouldBeDestroyed(value:Boolean):void
		{
			_shouldBeDestroyed = value;
		}

		public function get index():int
		{
			return _index;
		}

		public function set index(value:int):void
		{
			_index = value;
		}

		public function get hasBeenBlocked():Boolean
		{
			return _hasBeenBlocked;
		}

		public function set hasBeenBlocked(value:Boolean):void
		{
			_hasBeenBlocked = value;
		}

		public function get sprite():Sprite
		{
			return _sprite;
		}

		public function set sprite(value:Sprite):void
		{
			_sprite = value;
		}

		public function get pumpAffinity():int
		{
			return _pumpAffinity;
		}

		public function set pumpAffinity(value:int):void
		{
			_pumpAffinity = value;
		}

		public function get isSolute():Boolean
		{
			return _isSolute;
		}

		public function set isSolute(value:Boolean):void
		{
			_isSolute = value;
		}

		public function get isPlug():Boolean
		{
			return _isPlug;
		}

		public function set isPlug(value:Boolean):void
		{
			_isPlug = value;
		}

		public function get isAntibody():Boolean
		{
			return _isAntibody;
		}

		public function set isAntibody(value:Boolean):void
		{
			_isAntibody = value;
		}

	}
}