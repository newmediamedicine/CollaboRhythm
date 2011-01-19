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

	public class PyramidBenchmark implements IBenchmark
	{
		private var size:int = 5;
		public function Name():String
		{
			return "Pyramid";
		}
		
		public function Details():XML
		{
			return 	<benchmarkParameters>
						<version>$Rev: 86 $</version>
						<size>{size}</size>
					</benchmarkParameters>;	
		}
		
		public function Init(world:b2World):void
		{
			world.SetGravity(new b2Vec2(0, 10));
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			var groundDef:b2BodyDef = new b2BodyDef();
			groundDef.position.Set(5, 11);
			var body:b2Body = world.CreateBody(groundDef);
			var ground:b2PolygonShape = b2PolygonShape.AsBox(20, .5);
			body.CreateFixture2(ground);
			
			bodyDef.type = b2Body.b2_dynamicBody;
			var box:b2PolygonShape = b2PolygonShape.AsBox(.5, .5);
			for (var row:int = 0; row < size; row++)
			{
				for (var column:int = 0; column <= row; column++)
				{
					bodyDef.position.Set(
						groundDef.position.x + (column - row / 2) * 1,
						groundDef.position.y -(size - row) * 1.1);
					body = world.CreateBody(bodyDef);
					var fd:b2FixtureDef = new b2FixtureDef();
					fd.density = 1;
					fd.shape = box;
					body.CreateFixture(fd);
				}
			}
		}
		
		public function Update():void
		{
			
		}
	}
}