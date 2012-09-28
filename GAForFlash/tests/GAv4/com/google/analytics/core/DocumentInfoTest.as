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

package com.google.analytics.core
{
	import library.ASTUce.framework.TestCase;
    
    import com.google.analytics.external.AdSenseGlobals;
    import com.google.analytics.external.FakeAdSenseGlobals;
    import com.google.analytics.utils.Environment;
    import com.google.analytics.utils.FakeEnvironment;
    import com.google.analytics.utils.Variables;
    import com.google.analytics.v4.Configuration;
    
    public class DocumentInfoTest extends TestCase
    {
        private var _config:Configuration;
        private var _emptyDocInfo0:DocumentInfo;
        private var _emptyDocInfo1:DocumentInfo;
        private var _env0:Environment;
        private var _env1:Environment;
        private var _env2:Environment;
        private var _adSense0:AdSenseGlobals;
        private var _adSense1:AdSenseGlobals;
        
        public function DocumentInfoTest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _config = new Configuration();
            _env0 = new Environment( "http://www.domain.com" );
            _env1 = new FakeEnvironment("",null,"","","a simple title","","/some/path/page.html","?a=1&b=2");
            _env2 = new FakeEnvironment();
            _adSense0 = new FakeAdSenseGlobals();
            _adSense1 = new FakeAdSenseGlobals( null, "", "12345" );
            _emptyDocInfo0 = new DocumentInfo( _config, _env0, "", null, _adSense0 );
            _emptyDocInfo1 = new DocumentInfo( _config, _env0, "", null, _adSense1 );
            
        }
         
        public function testHitId():void
        {
            //hitId updated from docInfo
            assertEquals( "", _adSense0.hid );
            var hid:String = _emptyDocInfo0.utmhid;
            assertEquals( hid, _adSense0.hid );
            
            //HitId updated from gaGlobal
            assertEquals( "12345", _adSense1.hid );
            assertEquals( _adSense1.hid, _emptyDocInfo1.utmhid );
        }
       
        public function testPageTitle():void
        {
            var docInfo:DocumentInfo = new DocumentInfo( _config, _env1, "", null, _adSense0 );
            
            assertEquals( "a simple title", docInfo.utmdt );
            
            if( _config.detectTitle )
            {
                var vars:Variables = docInfo.toVariables();
                var vars2:Variables = new Variables();
                    vars2.URIencode = true;
                    vars2.utmdt = vars.utmdt;
                    
                assertEquals( "a simple title", vars.utmdt );
                assertEquals( "utmdt=a%20simple%20title", vars2.toString() );
          }
            
        }
        
        public function testPageURL():void
        {
            var docInfo0:DocumentInfo = new DocumentInfo( _config, _env1, "", null, _adSense0 );
            var docInfo1:DocumentInfo = new DocumentInfo( _config, _env1, "", "/some/other/path/index.html", _adSense0 );
            var docInfo2:DocumentInfo = new DocumentInfo( _config, _env2, "", null, _adSense0 );
            
            assertEquals( "/some/path/page.html?a=1&b=2", docInfo0.utmp );
            assertEquals( "/some/other/path/index.html", docInfo1.utmp );
            assertEquals( "/", docInfo2.utmp );
        }
        
    }
}