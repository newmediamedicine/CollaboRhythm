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

package com.google.analytics.utils
{
	import com.google.analytics.external.HTMLDOM;
	
	import library.ASTUce.framework.TestCase;
    
    //import com.google.analytics.external.FakeHTMLDOM;
    //import com.google.analytics.external.HTMLDOM;
    
    public class EnvironmentTest extends TestCase
    {
        private var _dom:HTMLDOM;
        
        public function EnvironmentTest( name:String="" )
        {
            super(name);
        }
        
        public function setUp():void
        {
            _dom = new HTMLDOM();
        }
        
        public function testBasicEmpty():void
        {
            var env_empty:Environment = new Environment("","","",_dom);
            
            assertEquals( "", env_empty.protocol );
            assertEquals( "", env_empty.domainName );
        }
        
        public function testBasicLocal():void
        {
            var env_local:Environment = new Environment( "file://someFolder/someFile.swf","","",_dom);
            
            assertEquals( "file", env_local.protocol );
            assertEquals( "localhost", env_local.domainName );
        }
        
        public function testBasicHTTP():void
        {
            var env_http:Environment = new Environment( "http://www.domain.com/file.swf","","",_dom);
            
            assertEquals( "http", env_http.protocol );
            assertEquals( "www.domain.com", env_http.domainName );
        }
        
        public function testBasicHTTPS():void
        {
            var env_https:Environment = new Environment( "https://www.domain.com/secure/file.swf","","",_dom);
            
            assertEquals( "https", env_https.protocol );
            assertEquals( "www.domain.com", env_https.domainName );
        }
        
        public function testLanguageUpgrade():void
        {
            // THIS TEST WILL NOT WORK ON A NON-UK MACHINE
            
              //var set1:HTMLDOM = new FakeHTMLDOM("","en-GB"); //downcast trick
              //var set2:HTMLDOM = new FakeHTMLDOM("","fr-FR"); //downcast trick
            
            
              //var env1:Environment = new Environment( "" , "", "", set1 ); //en-GB
              //var env2:Environment = new Environment( "" , "", "", set2 ); //fr-FR
            
            //assertEquals( "en-GB" , li1.language , "The LocalInfo language attribute failed" ) ; //match, upgrade
            //assertEquals( "fr-FR" , li2.language , "The LocalInfo language attribute failed" ) ; //no match, no upgrade
            
        }
        
    }
}