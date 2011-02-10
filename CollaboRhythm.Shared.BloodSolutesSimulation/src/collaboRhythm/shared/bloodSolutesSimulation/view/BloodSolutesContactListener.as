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
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	
	public class BloodSolutesContactListener extends b2ContactListener
	{
		public function BloodSolutesContactListener()
		{
			super();
		}
		
		public override function BeginContact(contact:b2Contact):void
		{
			var bodyA:b2Body = contact.GetFixtureA().GetBody();
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			
			if (bodyA != null && bodyB != null)
			{
				var bodyInfoA:BodyInfo = bodyA.GetUserData() as BodyInfo;
				var bodyInfoB:BodyInfo = bodyB.GetUserData() as BodyInfo;
				
				if (bodyInfoA != null && bodyInfoB != null)
				{
					updateBodiesOnContact(bodyInfoA, bodyInfoB);
					updateBodiesOnContact(bodyInfoB, bodyInfoA);
				}
			}
		}
		
		private function updateBodiesOnContact(bodyInfoA:BodyInfo, bodyInfoB:BodyInfo):void
		{
			if (bodyInfoA.isPlug && bodyInfoB.isSolute)
				bodyInfoB.hasBeenBlocked = true;
			else if (bodyInfoA.isSolute && bodyInfoB.isSolute && bodyInfoA.hasBeenBlocked)
				bodyInfoB.hasBeenBlocked = true;
			else if (bodyInfoA.isAntibody && bodyInfoA.plugJoint == null && bodyInfoB.isSolute && bodyInfoB.plugJoint == null)
				bindAntibodyToSolute(bodyInfoA, bodyInfoB);
		}
		
		private function bindAntibodyToSolute(antibody:BodyInfo, solute:BodyInfo):void
		{
			var jointDef:b2WeldJointDef = new b2WeldJointDef();
			jointDef.bodyA = antibody.body;
			jointDef.bodyB = solute.body;
			jointDef.collideConnected = false;
			var joint:b2Joint = antibody.body.GetWorld().CreateJoint(jointDef);
			
			antibody.plugJoint = joint;
			solute.plugJoint = joint;
		}
	}
}