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

package com.google.analytics.campaign
{
	import com.google.analytics.core.Buffer;
	import com.google.analytics.core.generateHash;
	import com.google.analytics.v4.Configuration;
	
	import library.ASTUce.framework.TestCase;
    
    public class CampaignManagerTest extends TestCase
    {
        private var _config:Configuration;
        private var _buffer:Buffer;
        private var _domainHash:Number;
        private var _referrer0:String;
        private var _referrer1:String;
        private var _referrer2:String;
        private var _timestamp:Number;
        
        private var _cm_noref:CampaignManager;
        private var _cm0:CampaignManager;
        private var _cm1:CampaignManager;
        private var _cm2:CampaignManager;
        
        public function CampaignManagerTest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _config = new Configuration();
            _buffer = new Buffer( _config, true );
            _domainHash = generateHash( "www.domain.com" );
            _referrer0  = "http://www.otherdomain.com";
            _referrer1  = "http://www.google.com?q=search+me";
            _referrer2  = "http://www.otherdomain.com/hello/world";
            _timestamp  = Math.round((new Date()).getTime() / 1000);
            
            _cm_noref = new CampaignManager( _config, _buffer, _domainHash, "", _timestamp );
            _cm0 = new CampaignManager( _config, _buffer, _domainHash, _referrer0, _timestamp );
            _cm1 = new CampaignManager( _config, _buffer, _domainHash, _referrer1, _timestamp );
            _cm2 = new CampaignManager( _config, _buffer, _domainHash, _referrer2, _timestamp );
        }
        
        public function testIsInvalidReferrer():void
        {
            assertTrue( CampaignManager.isInvalidReferrer( "" ) );
            assertTrue( CampaignManager.isInvalidReferrer( "0" ) );
            assertTrue( CampaignManager.isInvalidReferrer( "-" ) );
            assertTrue( CampaignManager.isInvalidReferrer( "file://some/local/path" ) );
            assertFalse( CampaignManager.isInvalidReferrer( "http://www.domain.com" ) );
        }
        
        public function testIsFromGoogleCSE():void
        {
            assertTrue( CampaignManager.isFromGoogleCSE( "http://www.google.com/cse?q=keyword", _config ) );
            assertTrue( CampaignManager.isFromGoogleCSE( "https://www.google.org/cse?q=keyword", _config ) );
            assertTrue( CampaignManager.isFromGoogleCSE( "http://google.com/cse?q=keyword", _config ) );
        }
        
        public function testHasNoOverride():void
        {
            var search0:String = "";
            var search1:String = "?a=1&b=2";
            var search2:String = "?a=1&b=2&utm_nooverride=1";
            var search3:String = "?a=1&b=2&utm_nooverride=0";
            // var search4:String = "?a=1&b=2&utm_nooverride";
            
            assertFalse( _cm0.hasNoOverride( search0 ) );
            assertFalse( _cm0.hasNoOverride( search1 ) );
            assertTrue( _cm0.hasNoOverride( search2 ) );
            assertFalse( _cm0.hasNoOverride( search3 ) );
            //assertFalse( _cm0.hasNoOverride( search4 ) );
        }
        
        public function testGetTrackerFromSearchString():void
        {
            var search0:String = "";
            var ct0:CampaignTracker = _cm0.getTrackerFromSearchString( search0 );
            
            assertFalse( ct0.isValid() );
            
            var search1:String = "?utm_id=123&&utm_source=www.domain.com&gclid=0123456789&utm_campaign=test&utm_medium=email&utm_term=webmail&utm_content=hello%20world";
            var ct1:CampaignTracker = _cm0.getTrackerFromSearchString( search1 );
            
            assertEquals( "123", ct1.id );
            assertEquals( "www.domain.com", ct1.source );
            assertEquals( "0123456789", ct1.clickId );
            assertEquals( "test", ct1.name );
            assertEquals( "email", ct1.medium );
            assertEquals( "webmail", ct1.term );
            assertEquals( "hello world", ct1.content );
            
            var search2:String = "?utm_id=123&&utm_source=www.domain.com&gclid=0123456789";
            var ct2:CampaignTracker = _cm0.getTrackerFromSearchString( search2 );
            
            assertEquals( "123", ct2.id );
            assertEquals( "www.domain.com", ct2.source );
            assertEquals( "0123456789", ct2.clickId );
            assertEquals( "(not set)", ct2.name );
            assertEquals( "(not set)", ct2.medium );
            assertEquals( "", ct2.term );
            assertEquals( "", ct2.content );
            
            var search3:String = "?utm_id=123&&utm_source=www.domain.com&gclid=0123456789";
            var ct3:CampaignTracker = _cm1.getTrackerFromSearchString( search3 );
            
            assertEquals( "123", ct3.id );
            assertEquals( "www.domain.com", ct3.source );
            assertEquals( "0123456789", ct3.clickId );
            assertEquals( "(not set)", ct3.name );
            assertEquals( "(not set)", ct3.medium );
            assertEquals( "search me", ct3.term ); //from referrer
            assertEquals( "", ct3.content );
            
        }
        
        public function testGetOrganicCampaign():void
        {
            var ct0:CampaignTracker = _cm_noref.getOrganicCampaign();
            
            assertNull( ct0 ); //no referrer
            
            var ct1:CampaignTracker = _cm1.getOrganicCampaign();
            
            assertNotNull( ct1 );
            assertEquals( "google", ct1.source );
            assertEquals( "(organic)", ct1.name );
            assertEquals( "organic", ct1.medium );
            assertEquals( "search me", ct1.term );
            
        }
        
        public function testGetReferrerCampaign():void
        {
            var ct0:CampaignTracker = _cm_noref.getReferrerCampaign();
            
            assertNull( ct0 ); //no referrer
            
            var ct1:CampaignTracker = _cm0.getReferrerCampaign();
            
            assertEquals( "otherdomain.com", ct1.source );
            assertEquals( "(referral)", ct1.name );
            assertEquals( "referral", ct1.medium );
            assertEquals( "/", ct1.content );
            
            var ct2:CampaignTracker = _cm2.getReferrerCampaign();
            
            assertEquals( "otherdomain.com", ct2.source );
            assertEquals( "(referral)", ct2.name );
            assertEquals( "referral", ct2.medium );
            assertEquals( "/hello/world", ct2.content );
            
        }
        
        public function testGetDirectCampaign():void
        {
            var ct0:CampaignTracker = _cm_noref.getDirectCampaign();
            
            assertEquals( "(direct)", ct0.source );
            assertEquals( "(direct)", ct0.name );
            assertEquals( "(none)", ct0.medium );
            
            var ct1:CampaignTracker = _cm0.getDirectCampaign();
            
            assertEquals( "(direct)", ct1.source );
            assertEquals( "(direct)", ct1.name );
            assertEquals( "(none)", ct1.medium );
            
            var ct2:CampaignTracker = _cm1.getDirectCampaign();
            
            assertEquals( "(direct)", ct2.source );
            assertEquals( "(direct)", ct2.name );
            assertEquals( "(none)", ct2.medium );
            
        }
        
        public function testGetCampaignInformation():void
        {
            var ci0:CampaignInfo = _cm_noref.getCampaignInformation( "", true );
            
            assertEquals( "utmcn=1", ci0.toURLString() );
            assertEquals( "utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)", _buffer.utmz.campaignTracking );
            
            var ci1:CampaignInfo = _cm1.getCampaignInformation( "", true ); //from referrer
            
            assertEquals( "utmcn=1", ci1.toURLString() );
            assertEquals( "utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=search%20me", _buffer.utmz.campaignTracking );
        
        	var ci2:CampaignInfo = _cm_noref.getCampaignInformation( "?gclid=xxx&utm_medium=yyy&utm_source=zzz&utm_campaign=qqq", true );
        	
        	assertEquals( "utmcn=1", ci2.toURLString() );
            assertEquals( "utmcsr=zzz|utmgclid=xxx|utmccn=qqq|utmcmd=yyy", _buffer.utmz.campaignTracking );
  
        
        }
        
        //test gclid and manual tagging works properly
        public function testGetCampaignInformation2():void
        {               
            var search1:String = "gclid=0123456789";
            var ci1:CampaignInfo = _cm_noref.getCampaignInformation( search1, true );
            
            assertEquals( "utmgclid=0123456789|utmccn=(not%20set)|utmcmd=(not%20set)", _buffer.utmz.campaignTracking );
            
            var search2:String = "gclid=xxx&utm_medium=yyy";
            var ci2:CampaignInfo = _cm_noref.getCampaignInformation( search2, true );
            
            assertEquals( "utmgclid=xxx|utmccn=(not%20set)|utmcmd=yyy", _buffer.utmz.campaignTracking );
            
            var search3:String = "gclid=xxx&utm_medium=yyy&utm_source=zzz";
            var ci3:CampaignInfo = _cm_noref.getCampaignInformation( search3, true );
            
            assertEquals( "utmcsr=zzz|utmgclid=xxx|utmccn=(not%20set)|utmcmd=yyy", _buffer.utmz.campaignTracking );
            
            var search4:String = "gclid=xxx&utm_medium=yyy&utm_source=zzz&utm_campaign=qqq";
            var ci4:CampaignInfo = _cm_noref.getCampaignInformation( search4, true );
            
            assertEquals( "utmcsr=zzz|utmgclid=xxx|utmccn=qqq|utmcmd=yyy", _buffer.utmz.campaignTracking );
        }
        
    }
}