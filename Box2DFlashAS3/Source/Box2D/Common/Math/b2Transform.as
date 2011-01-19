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

package Box2D.Common.Math{

	
import Box2D.Common.*;
	
	
/**
* A transform contains translation and rotation. It is used to represent
* the position and orientation of rigid frames.
*/
public class b2Transform
{
	/**
	* The default constructor does nothing (for performance).
	*/
	public function b2Transform(pos:b2Vec2=null, r:b2Mat22=null) : void 
	{
		if (pos){
			position.SetV(pos);
			R.SetM(r);

		}
	}

	/**
	* Initialize using a position vector and a rotation matrix.
	*/
	public function Initialize(pos:b2Vec2, r:b2Mat22) : void 
	{
		position.SetV(pos);
		R.SetM(r);
	}

	/**
	* Set this to the identity transform.
	*/
	public function SetIdentity() : void
	{
		position.SetZero();
		R.SetIdentity();
	}

	public function Set(x:b2Transform) : void{

		position.SetV(x.position);

		R.SetM(x.R);

	}
	
	/** 
	 * Calculate the angle that the rotation matrix represents.
	 */
	public function GetAngle():Number
	{
		return Math.atan2(R.col1.y, R.col1.x);
	}
	 

	public var position:b2Vec2 = new b2Vec2;
	public var R:b2Mat22 = new b2Mat22();
};

}