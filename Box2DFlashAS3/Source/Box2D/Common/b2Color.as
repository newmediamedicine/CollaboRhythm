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

package Box2D.Common{

	
import Box2D.Common.*;
import Box2D.Common.Math.*;


/**
* Color for debug drawing. Each value has the range [0,1].
*/

public class b2Color
{

	public function b2Color(rr:Number, gg:Number, bb:Number){
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	public function Set(rr:Number, gg:Number, bb:Number):void{
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	// R
	public function set r(rr:Number) : void{
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
	}
	// G
	public function set g(gg:Number) : void{
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
	}
	// B
	public function set b(bb:Number) : void{
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	// Color
	public function get color() : uint{
		return (_r << 16) | (_g << 8) | (_b);
	}
	
	private var _r:uint = 0;
	private var _g:uint = 0;
	private var _b:uint = 0;

};

}