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
	import library.ASTUce.framework.TestCase;
    
    import com.google.analytics.data.UTMZ;
    
    public class CampaignTrackerTest extends TestCase
    {
        public function CampaignTrackerTest(name:String="")
        {
            super(name);
        }
        
        public function testIsValid():void
        {
            var ct0:CampaignTracker = new CampaignTracker();
            
            var ct1:CampaignTracker = new CampaignTracker();
                ct1.id = "123";
            
            var ct2:CampaignTracker = new CampaignTracker();
                ct2.source = "www.domain.com";
            
            var ct3:CampaignTracker = new CampaignTracker();
                ct3.clickId = "000000";
            
            assertFalse( ct0.isValid() );
            assertTrue(  ct1.isValid() );
            assertTrue(  ct2.isValid() );
            assertTrue(  ct3.isValid() );
        }
        
        public function testFromTrackerString():void
        {
            var z:UTMZ = new UTMZ();
            var ct0:CampaignTracker = new CampaignTracker();
                ct0.id = "123";
                ct0.clickId = "0123456789";
                ct0.source  = "www.domain.com";
                ct0.content = "hello world";
                ct0.name    = "foobar";
                ct0.medium  = "organic";
                ct0.term    = "test";
                
                z.campaignTracking = ct0.toTrackerString();
            
            assertEquals( "utmcid=123|utmcsr=www.domain.com|utmgclid=0123456789|utmccn=foobar|utmcmd=organic|utmctr=test|utmcct=hello%20world", z.campaignTracking );
            
            
            var ct1:CampaignTracker = new CampaignTracker();
            ct1.fromTrackerString( z.campaignTracking );
            
            assertEquals( ct0.id,      ct1.id );
            assertEquals( ct0.clickId, ct1.clickId );
            assertEquals( ct0.source,  ct1.source );
            assertEquals( ct0.content, ct1.content );
            assertEquals( ct0.name,    ct1.name );
            assertEquals( ct0.medium,  ct1.medium );
            assertEquals( ct0.term,    ct1.term );
        }
        
    }
}