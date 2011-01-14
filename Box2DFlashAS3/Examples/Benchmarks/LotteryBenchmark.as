/*
* Copyright (c) 2009 Adam Newgas http://www.boristhebrave.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Benchmarks{
import Box2D.Common.*;
import Box2D.Dynamics.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Common.Math.*;

	public class LotteryBenchmark implements IBenchmark
	{
		private var angularVelocity:Number = 1;
		public function Name():String
		{
			return "Lottery";
		}
		
		public function Details():XML
		{
			return 	<benchmarkParameters>
						<version>$Rev: 71 $</version>
						<angularVelocity>{angularVelocity}</angularVelocity>
					</benchmarkParameters>;	
		}
		
		public function Init(world:b2World):void
		{
			world.SetGravity(new b2Vec2(0, 10));
			
			var groundDef:b2BodyDef = new b2BodyDef();
			groundDef.type = b2Body.b2_kinematicBody;
			groundDef.angularVelocity = angularVelocity;
			groundDef.position.Set(5, 5);
			var ground:b2PolygonShape = new b2PolygonShape();
			var body:b2Body;
			body = world.CreateBody(groundDef);
			ground.SetAsOrientedBox(.5, 5, new b2Vec2(-4.5, 0));
			body.CreateFixture2(ground);
			ground.SetAsOrientedBox(5, .5, new b2Vec2(0, -4.5));
			body.CreateFixture2(ground);
			ground.SetAsOrientedBox(5, .5, new b2Vec2(0, 4.5));
			body.CreateFixture2(ground);
			ground.SetAsOrientedBox(.5, 5, new b2Vec2(4.5, 0));
			body.CreateFixture2(ground);
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			var circle:b2CircleShape = new b2CircleShape(.5);
			for (var i:int = 0; i < 5; i++)
			{
				for (var j:int = 0; j < 5; j++)
				{
					bodyDef.position.Set(i + 1, j + 1);
					bodyDef.userData = i * 5 + j + 1;
					body = world.CreateBody(bodyDef);
					body.CreateFixture2(circle, 1);
				}
			}
			
			world.SetContactFilter(new LotteryContactFilter());
			world.SetContactListener(new LotteryContactListener());
		}
		
		public function Update():void
		{
			
		}
	}
}

import Box2D.Common.*;
import Box2D.Dynamics.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Common.Math.*;

internal class LotteryContactFilter extends b2ContactFilter
{
	override public function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture):Boolean 
	{
		var udA:* = fixtureA.GetBody().GetUserData();
		var udB:* = fixtureB.GetBody().GetUserData();
		if (udA && udB)
		{
			return ((udA - udB) % 3 != 0);
		}
			
		return true;
	}
}

internal class LotteryContactListener extends b2ContactListener
{
	override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
	{
		
		var udA:* = contact.GetFixtureA().GetBody().GetUserData();
		var udB:* = contact.GetFixtureB().GetBody().GetUserData();
		if(udA && udB && ((udA - udB) % 2 == 0))
			contact.SetEnabled(false);
	}
}