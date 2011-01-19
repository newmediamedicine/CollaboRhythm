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

package Box2D.Dynamics{


import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Dynamics.*;
import Box2D.Common.Math.*;
import Box2D.Common.*;

import Box2D.Common.b2internal;
use namespace b2internal;


/**
* Implement this class to provide collision filtering. In other words, you can implement
* this class if you want finer control over contact creation.
*/
public class b2ContactFilter
{

	/**
	* Return true if contact calculations should be performed between these two fixtures.
	* @warning for performance reasons this is only called when the AABBs begin to overlap.
	*/
	public virtual function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture) : Boolean{
		var filter1:b2FilterData = fixtureA.GetFilterData();
		var filter2:b2FilterData = fixtureB.GetFilterData();
		
		if (filter1.groupIndex == filter2.groupIndex && filter1.groupIndex != 0)
		{
			return filter1.groupIndex > 0;
		}
		
		var collide:Boolean = (filter1.maskBits & filter2.categoryBits) != 0 && (filter1.categoryBits & filter2.maskBits) != 0;
		return collide;
	}
	
	/**
	* Return true if the given fixture should be considered for ray intersection.
	* By default, userData is cast as a b2Fixture and collision is resolved according to ShouldCollide
	* @see ShouldCollide()
	* @see b2World#Raycast
	* @param userData	arbitrary data passed from Raycast or RaycastOne
	* @param fixture		the fixture that we are testing for filtering
	* @return a Boolean, with a value of false indicating that this fixture should be ignored.
	*/
	public virtual function RayCollide(userData:*, fixture:b2Fixture) : Boolean{
		if(!userData)
			return true;
		return ShouldCollide(userData as b2Fixture,fixture);
	}
	
	static b2internal var b2_defaultFilter:b2ContactFilter = new b2ContactFilter();
	
};

}
