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
﻿package Box2D.Collision 
{
	import Box2D.Common.Math.b2Vec2;
	/**
	 * Interface for objects tracking overlap of many AABBs.
	 */
	public interface IBroadPhase 
	{
		/**
		 * Create a proxy with an initial AABB. Pairs are not reported until
		 * UpdatePairs is called.
		 */
		function CreateProxy(aabb:b2AABB, userData:*):*;
		
		/**
		 * Destroy a proxy. It is up to the client to remove any pairs.
		 */
		function DestroyProxy(proxy:*):void;
		
		/**
		 * Call MoveProxy as many times as you like, then when you are done
		 * call UpdatePairs to finalized the proxy pairs (for your time step).
		 */
		function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2):void;
		
		function TestOverlap(proxyA:*, proxyB:*):Boolean;
		
		/**
		 * Get user data from a proxy. Returns null if the proxy is invalid.
		 */
		function GetUserData(proxy:*):*;
		
		/**
		 * Get the fat AABB for a proxy.
		 */
		function GetFatAABB(proxy:*):b2AABB;
		
		/**
		 * Get the number of proxies.
		 */
		function GetProxyCount():int;
		
		/**
		 * Update the pairs. This results in pair callbacks. This can only add pairs.
		 */
		function UpdatePairs(callback:Function):void;
		
		/**
		 * Query an AABB for overlapping proxies. The callback class
		 * is called with each proxy that overlaps 
		 * the supplied AABB, and return a Boolean indicating if 
		 * the broaphase should proceed to the next match.
		 * @param callback This function should be a function matching signature
		 * <code>function Callback(proxy:*):Boolean</code>
		 */
		function Query(callback:Function, aabb:b2AABB):void;
		
		/**
		 * Ray-cast  agains the proxies in the tree. This relies on the callback
		 * to perform exact ray-cast in the case where the proxy contains a shape
		 * The callback also performs any collision filtering
		 * @param callback This function should be a function matching signature
		 * <code>function Callback(subInput:b2RayCastInput, proxy:*):Number</code>
		 * Where the returned number is the new value for maxFraction
		 */
		function RayCast(callback:Function, input:b2RayCastInput):void;
		
		/**
		 * For debugging, throws in invariants have been broken
		 */
		function Validate():void;
		
		/**
		 * Give the broadphase a chance for structural optimizations
		 */
		function Rebalance(iterations:int):void;
	}
	
}