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
﻿/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
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


package TestBed{
	
	
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	public class TestOneSidedPlatform extends Test {
		

		
		public function TestOneSidedPlatform(){
			
			// Set Text field
			Main.m_aboutText.text = "One Sided Platform\n" +
				"Press: (c) create a shape, (d) destroy a shape.";
				
			var bd:b2BodyDef;
			var body:b2Body
			
			// Platform
			{
				bd = new b2BodyDef();
				bd.position.Set(10.0, 10.0);
				body = m_world.CreateBody(bd);
				
				var polygon:b2PolygonShape = b2PolygonShape.AsBox(3.0, 0.5);
				m_platform = body.CreateFixture2(polygon);
				
				m_bottom = bd.position.y + 0.5;
				m_top = bd.position.y - 0.5;
				
			}
			
			// Actor
			{
				bd = new b2BodyDef();
				bd.type = b2Body.b2_dynamicBody;
				bd.position.Set(10.0, 12.0);
				body = m_world.CreateBody(bd);
				
				m_radius = 0.5;
				var circle:b2CircleShape = new b2CircleShape(m_radius);
				m_character = body.CreateFixture2(circle, 1.0);
				
				m_state = e_unknown;
			}
			
			m_world.SetContactListener(new ContactListener(this));
		}
		
		//======================
		// Member Data 
		//======================
		
		static private var e_unknown:int = 0;
		static private var e_above:int = 1;
		static private var e_below:int = 2;
		
		public var m_radius:Number;
		public var m_top:Number;
		public var m_bottom:Number;
		public var m_state:int;
		public var m_platform:b2Fixture;
		public var m_character:b2Fixture;
		
	}
}
import Box2D.Dynamics.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Common.*;
import Box2D.Common.Math.*;
import TestBed.TestOneSidedPlatform;

class ContactListener extends b2ContactListener
{
	private var test:TestOneSidedPlatform;
	public function ContactListener(test:TestOneSidedPlatform)
	{
		this.test = test;
	}
	override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
	{
		var fixtureA:b2Fixture = contact.GetFixtureA();
		var fixtureB:b2Fixture = contact.GetFixtureB();
		if (fixtureA != test.m_platform && fixtureA != test.m_character)
			return;
		if (fixtureB != test.m_platform && fixtureB != test.m_character)
			return;
			
		var position:b2Vec2 = test.m_character.GetBody().GetPosition();
		if (position.y > test.m_top)
			contact.SetEnabled(false);
	}
}