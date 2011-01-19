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

package Box2D.Collision{
	
import Box2D.Collision.*;
import Box2D.Common.Math.*;

import Box2D.Common.b2internal;
use namespace b2internal;

/**
 * A manifold point is a contact point belonging to a contact
 * manifold. It holds details related to the geometry and dynamics
 * of the contact points.
 * The local point usage depends on the manifold type:
 * -e_circles: the local center of circleB
 * -e_faceA: the local center of cirlceB or the clip point of polygonB
 * -e_faceB: the clip point of polygonA
 * This structure is stored across time steps, so we keep it small.
 * Note: the impulses are used for internal caching and may not
 * provide reliable contact forces, especially for high speed collisions.
 */
public class b2ManifoldPoint
{
	public function b2ManifoldPoint()
	{
		Reset();
	}
	public function Reset() : void{
		m_localPoint.SetZero();
		m_normalImpulse = 0.0;
		m_tangentImpulse = 0.0;
		m_id.key = 0;
	}
	public function Set(m:b2ManifoldPoint) : void{
		m_localPoint.SetV(m.m_localPoint);
		m_normalImpulse = m.m_normalImpulse;
		m_tangentImpulse = m.m_tangentImpulse;
		m_id.Set(m.m_id);
	}
	public var m_localPoint:b2Vec2 = new b2Vec2();
	public var m_normalImpulse:Number;
	public var m_tangentImpulse:Number;
	public var m_id:b2ContactID = new b2ContactID();
};


}