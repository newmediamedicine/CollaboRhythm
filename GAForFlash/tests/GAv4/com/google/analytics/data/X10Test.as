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
    
    public class X10Test extends TestCase
    {
        private var xmod1:X10;
        
        public function X10Test(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            xmod1 = new X10();
        }
        
        public function tearDown():void
        {
            xmod1 = null;
        }
        
        public function testHasProject():void
        {
            xmod1.setKey( 1, 1, "test" );
            xmod1.setKey( 2, 1, "test" );
            xmod1.setKey( 3, 1, "test" );
            
            assertTrue( xmod1.hasProject(1) );
            assertTrue( xmod1.hasProject(2) );
            assertTrue( xmod1.hasProject(3) );
            
            assertFalse( xmod1.hasProject(0) );
            assertFalse( xmod1.hasProject(4) );
            
        }
        
        public function testSetGetKey():void
        {
            var r1:String;
            var r2:String;
            
            xmod1.setKey( 1, 10, "test" );
            r1 = xmod1.getKey( 1, 10 );
            assertEquals( "test", r1 );
            
            xmod1.setKey( 1, 10, "hello world" );
            r2 = xmod1.getKey( 1, 10 );
            assertEquals( "hello world", r2 );
            
        }
        
        public function testClearKey():void
        {
            xmod1.setKey( 1, 1, "test" );
            xmod1.setValue( 1, 1, 123 );
            
            xmod1.clearKey( 1 );
            
            assertEquals( undefined, xmod1.getKey(1,1) );
            assertEquals( null, xmod1.getKey(1,1) );
            assertEquals( 123, xmod1.getValue(1,1) );
        }
        
        public function testSetGetValue():void
        {
            var r1:Number;
            var r2:Number;
            
            xmod1.setValue( 1, 10, 123 );
            r1 = xmod1.getValue( 1, 10 );
            assertEquals( 123, r1 );
            
            xmod1.setValue( 1, 10, 0 );
            r2 = xmod1.getValue( 1, 10 );
            assertEquals( 0, r2 );
            
        }
        
        public function testClearValue():void
        {
            xmod1.setKey( 1, 1, "test" );
            xmod1.setValue( 1, 1, 123 );
            
            xmod1.clearValue( 1 );
            
            assertEquals( undefined, xmod1.getValue(1,1) );
            assertEquals( null, xmod1.getValue(1,1) );
            assertEquals( "test", xmod1.getKey(1,1) );
        }
        
        public function testRenderUrlString0():void
        {
            xmod1.setKey( 1, 1, "test" );
            //trace( xmod1.renderUrlString() );
            assertEquals( "1(test)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString1():void
        {
            xmod1.setKey(   1, 1, "test" );
            xmod1.setValue( 1, 1, 123 );
            
            assertEquals( "1(test)(123)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString2():void
        {
            xmod1.setKey(   1, 1, "hello" );
            xmod1.setValue( 1, 1, 123 );
            xmod1.setKey(   1, 2, "world" );
            xmod1.setValue( 1, 2, 456 );
            
            assertEquals( "1(hello*world)(123*456)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString3():void
        {
            xmod1.setKey(   1, 1, "hello" );
            xmod1.setValue( 1, 1, 123 );
            xmod1.setKey(   2, 1, "world" );
            xmod1.setValue( 2, 1, 456 );
            
            assertEquals( "1(hello)(123)2(world)(456)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString4():void
        {
            xmod1.setKey(   1, 1, "hello" );
            xmod1.setValue( 1, 1, 123 );
            xmod1.setKey(   1, 2, "the big" );
            xmod1.setValue( 1, 2, 456 );
            xmod1.setKey(   1, 3, "world" );
            xmod1.setValue( 1, 3, 789 );
            
            assertEquals( "1(hello*the big*world)(123*456*789)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString5():void
        {
            xmod1.setKey(   1, 2, "hello" );
            xmod1.setValue( 1, 2, 123 );
            xmod1.setKey(   1, 4, "the big" );
            xmod1.setValue( 1, 4, 456 );
            xmod1.setKey(   1, 6, "world" );
            xmod1.setValue( 1, 6, 789 );
            
            assertEquals( "1(2!hello*4!the big*6!world)(2!123*4!456*6!789)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString6():void
        {
            xmod1.setKey(   1, 1, "hello" );
            xmod1.setValue( 1, 1, 123 );
            xmod1.setKey(   2, 1, "the big" );
            xmod1.setValue( 2, 1, 456 );
            xmod1.setKey(   3, 1, "world" );
            xmod1.setValue( 3, 1, 789 );
            
            assertEquals( "1(hello)(123)2(the big)(456)3(world)(789)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderUrlString7():void
        {
            xmod1.setKey(   2, 1, "hello" );
            xmod1.setValue( 2, 1, 123 );
            xmod1.setKey(   4, 1, "the big" );
            xmod1.setValue( 4, 1, 456 );
            xmod1.setKey(   6, 1, "world" );
            xmod1.setValue( 6, 1, 789 );
            
            /* TODO:
               ask if data need to be sorted by index
               this
               2(hello)(123)4(the big)(456)6(world)(789)
               instead of
               4(the big)(456)2(hello)(123)6(world)(789)
               
               note: the data is not sorted because of the for...in in renderUrlString()
            */
            assertEquals( "4(the big)(456)2(hello)(123)6(world)(789)", xmod1.renderUrlString() ); 
        }
        
        public function testRenderMergedUrlString():void
        {
            xmod1.setKey(   2, 1, "hello" );
            xmod1.setValue( 2, 1, 123 );
            xmod1.setKey(   4, 1, "the big" );
            xmod1.setValue( 4, 1, 456 );
            xmod1.setKey(   6, 1, "world" );
            xmod1.setValue( 6, 1, 789 );
            
            //different project id
            var xmod2:X10 = new X10();
                xmod2.setKey(   3, 1, "bonjour" );
                xmod2.setValue( 3, 1, 321 );
                xmod2.setKey(   5, 1, "le grand" );
                xmod2.setValue( 5, 1, 654 );
                xmod2.setKey(   7, 1, "monde" );
                xmod2.setValue( 7, 1, 987 );
            
            assertEquals( "7(monde)(987)5(le grand)(654)3(bonjour)(321)4(the big)(456)2(hello)(123)6(world)(789)", xmod1.renderMergedUrlString( xmod2 ) );
            
        }
        
        public function testRenderMergedUrlString2():void
        {
            xmod1.setKey(   2, 1, "hello" );
            xmod1.setValue( 2, 1, 123 );
            xmod1.setKey(   4, 1, "the big" );
            xmod1.setValue( 4, 1, 456 );
            xmod1.setKey(   6, 1, "world" );
            xmod1.setValue( 6, 1, 789 );
            
            //same project id
            var xmod2:X10 = new X10();
                xmod2.setKey(   2, 1, "bonjour" );
                xmod2.setValue( 2, 1, 321 );
                xmod2.setKey(   4, 1, "le grand" );
                xmod2.setValue( 4, 1, 654 );
                xmod2.setKey(   6, 1, "monde" );
                xmod2.setValue( 6, 1, 987 );
            
            assertEquals( "4(le grand)(654)2(bonjour)(321)6(monde)(987)", xmod1.renderMergedUrlString( xmod2 ) );
        }
        
        public function testRenderMergedUrlString3():void
        {
            xmod1.setKey(   2, 1, "hello" );
            xmod1.setValue( 2, 1, 123 );
            xmod1.setKey(   4, 1, "the big" );
            xmod1.setValue( 4, 1, 456 );
            xmod1.setKey(   6, 1, "world" );
            xmod1.setValue( 6, 1, 789 );
            
            //diff project id, "the big" will be ignored
            var xmod2:X10 = new X10();
                xmod2.setKey(   3, 1, "bonjour" );
                xmod2.setValue( 3, 1, 321 );
                xmod2.setKey(   4, 1, "le grand" );
                xmod2.setValue( 4, 1, 654 );
                xmod2.setKey(   7, 1, "monde" );
                xmod2.setValue( 7, 1, 987 );
            
            assertEquals( "4(le grand)(654)7(monde)(987)3(bonjour)(321)2(hello)(123)6(world)(789)", xmod1.renderMergedUrlString( xmod2 ) );
            assertEquals( -1, xmod1.renderMergedUrlString( xmod2 ).indexOf( "(the big)" ) );
        }
        
    }
}

