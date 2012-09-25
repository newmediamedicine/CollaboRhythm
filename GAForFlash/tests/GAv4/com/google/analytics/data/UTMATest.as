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
    
    import com.google.analytics.core.generateHash;
    
    public class UTMATest extends TestCase
    {
        private var _emptyUTMA:UTMA;
        private var _utma0:UTMA;
        private var _sessionId0:Number;
        private var _time0:Number;
        
        public function UTMATest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _emptyUTMA = new UTMA();
            _sessionId0 = 3125648113755156500;
            _time0 = 1223210053;
            
            _utma0 = new UTMA();
            _utma0.domainHash = generateHash( "http://www.domain.com" );
            _utma0.sessionId  = _sessionId0;
            _utma0.currentTime = _time0;
            _utma0.lastTime = _time0;
            _utma0.firstTime = _time0;
            _utma0.sessionCount = 0;
        }
        
        public function tearDown():void
        {
            _emptyUTMA = null;
            _sessionId0 = 0;
            _time0 = 0;
            _utma0 = null;
        }
        
        public function testIsEmpty():void
        {
            assertTrue( _emptyUTMA.isEmpty() );
            assertFalse( _utma0.isEmpty() );
        }
        
        public function testDomainHash():void
        {
            var domainHash:Number = generateHash( "http://www.domain.com" );
            _emptyUTMA.domainHash = domainHash;
            
            assertEquals( domainHash, _emptyUTMA.domainHash );
        }
        
        public function testSessionId():void
        {
            _emptyUTMA.sessionId = _sessionId0;
            
            assertEquals( _sessionId0, _emptyUTMA.sessionId );
        }
        
        public function testValueOf():void
        {
            assertTrue( _emptyUTMA.isEmpty() );
            assertEquals( _emptyUTMA.valueOf(), "-" );
            
            assertFalse( _utma0.isEmpty() );
            assertEquals( _utma0.valueOf(), "189673714.3125648113755156500.1223210053.1223210053.1223210053.0" ); 
        }
        
        public function testToURLString():void
        {
            assertEquals( _emptyUTMA.toURLString(), "__utma=-" );
            assertEquals( _utma0.toURLString(), "__utma=189673714.3125648113755156500.1223210053.1223210053.1223210053.0" );
        }
        
        public function testToString():void
        {
            assertEquals( _emptyUTMA.toString(), "UTMA {}" );
            assertEquals( _utma0.toString(), "UTMA {domainHash: 189673714, sessionId: 3125648113755156500, firstTime: 1223210053, lastTime: 1223210053, currentTime: 1223210053, sessionCount: 0}" );
        }
        
        public function testToSharedObject():void
        {
            var o0:Object = _emptyUTMA.toSharedObject();
            var o1:Object = _utma0.toSharedObject();
            
            assertEquals( undefined, o0.domainHash );
            assertEquals( undefined, o0.sessionId );
            assertEquals( undefined, o0.firstTime );
            assertEquals( undefined, o0.lastTime );
            assertEquals( undefined, o0.currentTime );
            assertEquals( undefined, o0.sessionCount );
            
            assertEquals( _utma0.domainHash, o1.domainHash );
            assertEquals( _utma0.sessionId, o1.sessionId );
            assertEquals( _utma0.firstTime, o1.firstTime );
            assertEquals( _utma0.lastTime, o1.lastTime );
            assertEquals( _utma0.currentTime, o1.currentTime );
            assertEquals( _utma0.sessionCount, o1.sessionCount );
        }
        
        public function testFromSharedObject():void
        {
            var o0:Object = {};
            var o1:Object = { domainHash: 1 };
            
            
            _emptyUTMA.fromSharedObject( o0 );
            assertEquals( NaN, _emptyUTMA.domainHash );
            assertEquals( NaN, _emptyUTMA.sessionId );
            assertEquals( NaN, _emptyUTMA.firstTime );
            assertEquals( NaN, _emptyUTMA.lastTime );
            assertEquals( NaN, _emptyUTMA.currentTime );
            assertEquals( NaN, _emptyUTMA.sessionCount );
            
            _emptyUTMA.fromSharedObject( o1 );
            assertEquals(   1, _emptyUTMA.domainHash );
            assertEquals( NaN, _emptyUTMA.sessionId );
            assertEquals( NaN, _emptyUTMA.firstTime );
            assertEquals( NaN, _emptyUTMA.lastTime );
            assertEquals( NaN, _emptyUTMA.currentTime );
            assertEquals( NaN, _emptyUTMA.sessionCount );
            
            _utma0.fromSharedObject( o1 );
            assertEquals(   1, _utma0.domainHash );
            
        }
        
        public function testFromSharedObject2():void
        {
            var o0:Object = { domainHash: undefined };
            var o1:Object = { domainHash: null };
            
            _emptyUTMA.fromSharedObject( o0 );
            assertEquals( NaN, _emptyUTMA.domainHash );
            assertEquals( NaN, _emptyUTMA.sessionId );
            assertEquals( NaN, _emptyUTMA.firstTime );
            assertEquals( NaN, _emptyUTMA.lastTime );
            assertEquals( NaN, _emptyUTMA.currentTime );
            assertEquals( NaN, _emptyUTMA.sessionCount );
            
            _emptyUTMA.fromSharedObject( o1 );
            assertEquals( NaN, _emptyUTMA.domainHash );
            assertEquals( NaN, _emptyUTMA.sessionId );
            assertEquals( NaN, _emptyUTMA.firstTime );
            assertEquals( NaN, _emptyUTMA.lastTime );
            assertEquals( NaN, _emptyUTMA.currentTime );
            assertEquals( NaN, _emptyUTMA.sessionCount );
        }
        
    }
}