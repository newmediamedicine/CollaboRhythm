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
    import com.google.analytics.v4.Configuration;
    
    import library.ASTUce.framework.TestCase;

    public class ConfigurationTest extends TestCase
    {
        private var _conf:Configuration;
        
        public function ConfigurationTest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _conf = new Configuration();
        }
        
        public function testAddOrganicSource():void
        {
            var len:int = _conf.organic.count;
            _conf.addOrganicSource("google", "q");
            assertEquals(len, _conf.organic.count);
            
            //_conf.addOrganicSource("mydomain", "q");
            //assertEquals(len+1, _conf.organic.count);
        }
        
        public function testClearOrganicSources():void
        {
            _conf.organic.clear();
            assertEquals(0, _conf.organic.count);
        }
        
        public function testSampleRate():void
        {
            _conf.sampleRate = -3;
            assertEquals( 0.1, _conf.sampleRate );
            
            _conf.sampleRate = 5;
            assertEquals( 1, _conf.sampleRate );
            
            _conf.sampleRate = 0.99;
            assertEquals( 0.99, _conf.sampleRate );
            
            _conf.sampleRate = 0.599;
            assertEquals( 0.60, _conf.sampleRate );
            
            _conf.sampleRate = 0.3489;
            assertEquals( 0.35, _conf.sampleRate );
        }
        
    }
}