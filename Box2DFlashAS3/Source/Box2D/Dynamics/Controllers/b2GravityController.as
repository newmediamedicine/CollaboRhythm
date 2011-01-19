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
* Copyright (c) 2006-2007 Adam Newgas
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

package Box2D.Dynamics.Controllers{

import Box2D.Common.Math.*;
import Box2D.Common.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.*;


/**
 * Applies simplified gravity between every pair of bodies 
 */
public class b2GravityController extends b2Controller
{	
	/**
	 * Specifies the strength of the gravitiation force
	 */
	public var G:Number = 1;
	/**
	 * If true, gravity is proportional to r^-2, otherwise r^-1
	 */
	public var invSqr:Boolean = true;
	
	public override function Step(step:b2TimeStep):void{
		//Inlined
		var i:b2ControllerEdge = null;
		var body1:b2Body = null;
		var p1:b2Vec2 = null;
		var mass1:Number = 0;
		var j:b2ControllerEdge = null;
		var body2:b2Body = null;
		var p2:b2Vec2 = null;
		var dx:Number = 0;
		var dy:Number = 0;
		var r2:Number = 0;
		var f:b2Vec2 = null;
		if(invSqr){
			for(i=m_bodyList;i;i=i.nextBody){
				body1 = i.body;
				p1 = body1.GetWorldCenter();
				mass1 = body1.GetMass();
				for(j=m_bodyList;j!=i;j=j.nextBody){
					body2 = j.body;
					p2 = body2.GetWorldCenter()
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if(r2<Number.MIN_VALUE)
						continue;
					f = new b2Vec2(dx,dy);
					f.Multiply(G / r2 / Math.sqrt(r2) * mass1* body2.GetMass());
					if(body1.IsAwake())
						body1.ApplyForce(f,p1);
					f.Multiply(-1);
					if(body2.IsAwake())
						body2.ApplyForce(f,p2);
				}
			}
		}else{
			for(i=m_bodyList;i;i=i.nextBody){
				body1 = i.body;
				p1 = body1.GetWorldCenter();
				mass1 = body1.GetMass();
				for(j=m_bodyList;j!=i;j=j.nextBody){
					body2 = j.body;
					p2 = body2.GetWorldCenter()
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if(r2<Number.MIN_VALUE)
						continue;
					f = new b2Vec2(dx,dy);
					f.Multiply(G / r2 * mass1 * body2.GetMass());
					if(body1.IsAwake())
						body1.ApplyForce(f,p1);
					f.Multiply(-1);
					if(body2.IsAwake())
						body2.ApplyForce(f,p2);
				}
			}
		}
	}
}

}