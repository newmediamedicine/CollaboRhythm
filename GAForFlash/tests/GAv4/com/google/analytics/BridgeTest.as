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

package com.google.analytics
{
    import com.google.analytics.external.JavascriptProxy;
    import com.google.analytics.v4.Bridge;
    
    import library.ASTUce.framework.TestCase;
    
    /**
    * those tests requires
    * - to be run with a SWF embedded in HTML
    * - the HTML to include the ga.js code
    *   <script src="http://www.google-analytics.com/ga.js"></script>
    * - the flash param allowscriptaccess = always
    */
    public class BridgeTest extends TestCase
    {
        private var _js:JavascriptProxy;
        private var _bridge:Bridge;
        
        public function BridgeTest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _js = new JavascriptProxy();
            
            if( !_js.isAvailable() )
            {
                return;
            }
            
            var data:XML =
            <script>
                <![CDATA[
                    function()
                    {
                        pT = _gat._getTracker("UA-332-1");
                        x = {};
                        x.y = {};
                        x.y.z = _gat._getTracker("UA-321-0");
                        _GATracker = {};
                        //alert( "pT="+pT );
                    }
                ]]>
            </script>;
            
            _js.executeBlock( data );
            
        }
        
        public function testAlreadyExistingValidTracker():void
        {
            if( !_js.isAvailable() )
            {
                return;
            }
            
            _bridge = new Bridge( "pT", _js );
            
            assertTrue( _bridge.hasTrackingAccount( "pT" ) );
            assertEquals( "UA-332-1", _bridge.getAccount() );
        }
        
        public function testAlreadyExistingValidTracker2():void
        {
            if( !_js.isAvailable() )
            {
                return;
            }
            
            _bridge = new Bridge( "x.y.z", _js );
            
            assertTrue( _bridge.hasTrackingAccount( "x.y.z" ) );
            assertEquals( "UA-321-0", _bridge.getAccount() );
        }
        
        public function testAlreadyExistingInvalidTracker():void
        {
            if( !_js.isAvailable() )
            {
                return;
            }
            
            try
            {
                _bridge = new Bridge( "foobar", _js );
            }
            catch( e:Error )
            {
                return;
            }
            
            fail();
        }
        
        public function testCreateTrackingObject():void
        {
            if( !_js.isAvailable() )
            {
                return;
            }
            _bridge = new Bridge( "UA-332-1", _js );
            
            assertTrue( _bridge.hasTrackingAccount( "UA-332-1" ) );
            assertEquals( "UA-332-1", _bridge.getAccount() );
        }
        
//        public function testJSObjExists():void
//        {
//            if( !_js.isAvailable() )
//            {
//                return;
//            }
//            
//            var o1:Boolean = _bridge.jsTrackingObjExists("pT");
//            var o2:Boolean = _bridge.jsTrackingObjExists("_GATracker['test']");
//            var o3:Boolean = _bridge.jsTrackingObjExists("_GATracker.test");
//            var o4:Boolean = _bridge.jsTrackingObjExists("document");		
//            var o5:Boolean = _bridge.jsTrackingObjExists("_GATracker['testBig']");
//            
//            assertEquals(true, o1);
//            assertEquals(true, o2);
//            assertEquals(true, o3);
//            assertEquals(false, o4);	
//            assertEquals(false, o5);
//        }
        
//        public function testCreateTrackingObject():void
//        {
//            if( !_js.isAvailable() )
//            {
//                return;
//            }
//            
//            var acctID:String = "UA-8-3";
//            var oName1:String = _bridge.createJSTrackingObject(acctID);
//            
//            assertEquals("_GATracker['"+acctID+"']", oName1);
//        }
        
        
    }
}