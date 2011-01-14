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

	public class NullBenchmark implements IBenchmark
	{
		public function Name():String
		{
			return "Null";
		}
		
		public function Details():XML
		{
			return 	<benchmarkParameters>
					<version>$Rev: 53 $</version>
				</benchmarkParameters>;	
		}
		
		public function Init(world:b2World):void
		{
		}
		
		public function Update():void
		{
		}
	}
}