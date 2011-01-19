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
﻿//===========================================================
//=========================================================//
//						-=ANTHEM=-
//	file: frameLimiter.as
//
//	copyright: Matthew Bush 2007
//
//	notes: limits framerate
//
//=========================================================//
//===========================================================



//===========================================================
// frame limiter
//===========================================================

package General{
	
	
	import flash.utils.getTimer;
	
	
	public class FRateLimiter{
		
		
		//======================
		// limit frame function
		//======================
		static public function limitFrame(maxFPS:uint):void{
			
			var fTime:uint = 1000 / maxFPS;
			
			while(Math.abs(newT - oldT) < fTime){
				newT = getTimer();
			}
			oldT = getTimer();
			
		}
		
		//======================
		// member vars
		//======================
		private static var oldT:uint = getTimer();
		private static var newT:uint = oldT;
	}

}