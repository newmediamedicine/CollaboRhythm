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
	import Box2D.Dynamics.b2World;

	public interface IBenchmark
	{
		/// Return a string name for the benchmark
		function Name():String;
		/// Return any further details, as XML with root element
		/// benchmarkParameters
		/// This should include a version tag with the revision details.
		function Details():XML;
		/// Initialize the world
		function Init(world:b2World):void;
		/// This is run every tick
		function Update():void;
	}
}