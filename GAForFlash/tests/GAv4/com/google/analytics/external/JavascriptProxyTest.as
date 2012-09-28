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

package com.google.analytics.external
{
	import library.ASTUce.framework.TestCase;
    
    /**
    * those tests requires
    * - to be run with a SWF embedded in HTML
    * - the flash param allowscriptaccess = always
    */
    public class JavascriptProxyTest extends TestCase
    {
        private var _proxy:JavascriptProxy;
        
        public function JavascriptProxyTest(name:String="")
        {
            super( name );
        }
        
        public function setUp():void
        {
            _proxy = new JavascriptProxy();
        }
        
        public function testCall():void
        {
            if( !_proxy.isAvailable() )
            {
                return;
            }
            
            var data:XML =
                <script>
                    <![CDATA[
                        function(a, b, c, d, e)
                        {
                            return a + b + c + d + e;
                        }
                    ]]>
                </script>;
                
            assertEquals(15, _proxy.call(data, 1,2,3,4,5));
        }
        
        public function testCall2():void
        {
            if( !_proxy.isAvailable() )
            {
                return;
            }
            
            var data:XML = 
                <script>
                    <![CDATA[
                        function(a)
                        {
                            return a;
                        }
                    ]]>
                </script>;
            
            assertEquals( 5, _proxy.call(data, 5) );
            assertEquals( "correct", _proxy.call(data, "correct") );
        }
        
        public function testCall3():void
        {
            if( !_proxy.isAvailable() )
            {
                return;
            }
            
            var data:XML =
                <script>
                    <![CDATA[
                        function( bool )
                        {
                            if( bool )
                            {
                                return "pass";
                            }
                            else
                            {
                                return "fail";
                            }
                        }
                    ]]>
                </script>;
                
            assertEquals( "pass" , _proxy.call(data, true));
            assertEquals( "fail" , _proxy.call(data, false));
        }
        
        public function testGetSetProperty():void
        {
            if( !_proxy.isAvailable() )
            {
                return;
            }
            
            _proxy.setProperty( "a", {} );
            _proxy.setProperty( "a.b", {} );
            _proxy.setProperty( "a.b.c", 123 );
            _proxy.setProperty( "a.b.d", true );
            _proxy.setProperty( "a.b.e", "hello world" );
            
            assertEquals( 123, _proxy.getProperty( "a.b.c" ) );
            assertEquals( true, _proxy.getProperty( "a.b.d" ) );
            assertEquals( "hello world", _proxy.getProperty( "a.b.e" ) );
            assertTrue( _proxy.getProperty( "a" ) is Object );
            assertTrue( _proxy.getProperty( "a.b" ) is Object );
            assertTrue( _proxy.getProperty( "a.b.c" ) is Number );
            assertTrue( _proxy.getProperty( "a.b.d" ) is Boolean );
            assertTrue( _proxy.getProperty( "a.b.e" ) is String );
        }
        
    }

}