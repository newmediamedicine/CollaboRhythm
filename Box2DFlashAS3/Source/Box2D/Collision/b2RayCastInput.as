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
* Copyright (c) 2009 Erin Catto http://www.gphysics.com
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

/**
 * Specifies a segment for use with RayCast functions.
 */
package Box2D.Collision 
{
	import Box2D.Common.Math.b2Vec2;
	
	public class b2RayCastInput 
	{
		function b2RayCastInput(p1:b2Vec2 = null, p2:b2Vec2 = null, maxFraction:Number = 1)
		{
			if (p1)
				this.p1.SetV(p1);
			if (p2)
				this.p2.SetV(p2);
			this.maxFraction = maxFraction;
		}
		/**
		 * The start point of the ray
		 */
		public var p1:b2Vec2 = new b2Vec2();
		/**
		 * The end point of the ray
		 */
		public var p2:b2Vec2 = new b2Vec2();
		/**
		 * Truncate the ray to reach up to this fraction from p1 to p2
		 */
		public var maxFraction:Number;
	}
	
}