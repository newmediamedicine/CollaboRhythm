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
	import com.google.analytics.utils.Environment;
	import com.google.analytics.utils.FakeEnvironment;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.v4.Configuration;
	
	import core.version;
	
	import library.ASTUce.framework.TestCase;

    public class BrowserInfoTest extends TestCase
    {
        private var _config:Configuration;
        private var _browserInfo0:BrowserInfo;
        private var _env0:Environment;
        
        public function BrowserInfoTest(name:String="")
        {
            super(name);
        }
        
        public function testHitId():void {
        	assertEquals(1,1);
        
        }
        
         
        public function setUp():void
        {
            _config = new Configuration();
            _env0 = new FakeEnvironment("",null,"","","","","","",new version(9,0,115,0),"en-GB","UTF-8","","","",null,800,600,"24");
            _browserInfo0 = new BrowserInfo( _config, _env0 );
        }
        
        public function testFlashVersion():void
        {
            assertEquals( "9.0 r115", _browserInfo0.utmfl );
        }
        
        public function testScreenInfo():void
        {
            assertEquals( "800x600", _browserInfo0.utmsr );
            assertEquals( "24-bit", _browserInfo0.utmsc );
        }
        
        public function testLangInfo():void
        {
            assertEquals( "en-gb", _browserInfo0.utmul );
            assertEquals( "UTF-8", _browserInfo0.utmcs );
        }
        
        public function testToVariables():void
        {
            var vars:Variables = _browserInfo0.toVariables();
            
            assertEquals( "UTF-8",    vars.utmcs );
            assertEquals( "800x600",  vars.utmsr );
            assertEquals( "24-bit",   vars.utmsc );
            assertEquals( "en-gb",    vars.utmul );
            assertEquals( "0",        vars.utmje );
            assertEquals( "9.0 r115", vars.utmfl );
        }
      
        public function testToURLString():void
        {
            var vars:Variables = _browserInfo0.toVariables();
            
            var varsA:Variables = new Variables();
                varsA.URIencode = true;
                varsA.utmcs = vars.utmcs;
            assertEquals( "utmcs=UTF-8", varsA.toString() );
            
            var varsB:Variables = new Variables();
                varsB.URIencode = true;
                varsB.utmsr = vars.utmsr;
            assertEquals( "utmsr=800x600", varsB.toString() );
            
            var varsC:Variables = new Variables();
                varsC.URIencode = true;
                varsC.utmsc = vars.utmsc;
            assertEquals( "utmsc=24-bit", varsC.toString() );
            
            var varsD:Variables = new Variables();
                varsD.URIencode = true;
                varsD.utmul = vars.utmul;
            assertEquals( "utmul=en-gb", varsD.toString() );
            
            var varsE:Variables = new Variables();
                varsE.URIencode = true;
                varsE.utmje = vars.utmje;
            assertEquals( "utmje=0", varsE.toString() );
            
            var varsF:Variables = new Variables();
                varsF.URIencode = true;
                varsF.utmfl = vars.utmfl;
            assertEquals( "utmfl=9.0%20r115", varsF.toString() );
        }
        
    }
}