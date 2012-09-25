/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */

package com.google.analytics.data
{
	import library.ASTUce.framework.TestCase;
    
    import flash.utils.getTimer;
    
    public class UTMCookieTest extends TestCase
    {
        public function UTMCookieTest(name:String="")
        {
            super(name);
        }
        
        public function testIsExpired():void
        {
            var c0:UTMCookie = new UTMCookie( "test", "_test", [], 100 );
            var c1:UTMCookie = new UTMCookie( "test", "_test", [] );
            
            assertFalse( c0.isExpired() );
            assertFalse( c1.isExpired() );
        }
        
        public function testIsExpired2():void
        {
            var c:UTMCookie = new UTMCookie( "test", "_test", [], 10 );
            
            assertFalse( c.isExpired() );
            
            //force 1ms to elapse
            var start:int = getTimer();
            var end:int   = 0;
            
            while( (end-start) < 11 ) //wait 11ms
            {
                end = getTimer();
            }
            
            
            assertTrue( c.isExpired() );
        }
        
    }
}