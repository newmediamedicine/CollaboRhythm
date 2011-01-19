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

import Box2D.Common.Math.*;
import Box2D.Common.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Dynamics.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Dynamics.Joints.*;

import Box2D.Common.b2internal;
use namespace b2internal;


/**
 * A fixture definition is used to create a fixture. This class defines an
 * abstract fixture definition. You can reuse fixture definitions safely.
 */
public class b2FixtureDef
{
	/**
	 * The constructor sets the default fixture definition values.
	 */
	public function b2FixtureDef()
	{
		shape = null;
		userData = null;
		friction = 0.2;
		restitution = 0.0;
		density = 0.0;
		filter.categoryBits = 0x0001;
		filter.maskBits = 0xFFFF;
		filter.groupIndex = 0;
		isSensor = false;
	}
	
	/**
	 * The shape, this must be set. The shape will be cloned, so you
	 * can create the shape on the stack.
	 */
	public var shape:b2Shape;

	/**
	 * Use this to store application specific fixture data.
	 */
	public var userData:*;

	/**
	 * The friction coefficient, usually in the range [0,1].
	 */
	public var friction:Number;

	/**
	 * The restitution (elasticity) usually in the range [0,1].
	 */
	public var restitution:Number;

	/**
	 * The density, usually in kg/m^2.
	 */
	public var density:Number;

	/**
	 * A sensor shape collects contact information but never generates a collision
	 * response.
	 */
	public var isSensor:Boolean;

	/**
	 * Contact filtering data.
	 */
	public var filter:b2FilterData = new b2FilterData();
};



}
