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

    public class OrganicTest extends TestCase
    {
        private var _org0:Organic;
        
        public function OrganicTest(name:String="")
        {
            super(name);
        }
        
        public function setUp():void
        {
            _org0 = new Organic();
        }
        
        public function tearDown():void
        {
            _org0 = null;
        }
        
        public function testAddSource():void
        {
            _org0.addSource( "google", "q" );
            assertTrue( _org0.match("google") );
        }
        
        public function testAddSameSource():void
        {
            var original:Boolean = Organic.throwErrors;
            Organic.throwErrors = true;
            
            _org0.addSource( "google", "q" );
            
            try
            {
                _org0.addSource( "google", "q" );
            }
            catch( e:Error )
            {
                Organic.throwErrors = original;
                return;
            }
            
            fail();
        }
        
        public function testAddSource2():void
        {
            _org0.addSource( "aol", "query" );
            _org0.addSource( "aol", "encquery" );
        }
        
        public function testMatch():void
        {
            _org0.addSource( "google", "q" );
            assertTrue( _org0.match("google") );
        }
        
        public function testMatch2():void
        {
            _org0.addSource( "aol", "query" );
            _org0.addSource( "aol", "encquery" );
            
            assertTrue( _org0.match( "aol" ) );
        }
        
        public function testGetReferrerByName():void
        {
            _org0.addSource( "aol", "query" );
            _org0.addSource( "aol", "encquery" );
            
            var or:OrganicReferrer = _org0.getReferrerByName( "aol" );
            
            assertEquals( "aol", or.engine );
            assertEquals( "query", or.keyword );
            
            var notfound:OrganicReferrer = _org0.getReferrerByName( "foobar" );
            
            assertEquals( null, notfound );
        }
        
        public function testGetKeywordValueFromPath():void
        {
            var path0:String = "?q=hello+world";
            var path1:String = "query=a+b+c";
            var path2:String = "?q=bonjour+le+monde&foo=123&bar=456";
            
            assertEquals( "hello world", Organic.getKeywordValueFromPath( "q", path0 ) );
            assertEquals( "a b c", Organic.getKeywordValueFromPath( "query", path1 ) );
            assertEquals( "bonjour le monde", Organic.getKeywordValueFromPath( "q", path2 ) );
        }
        
        public function testAddIgnoredReferral():void
        {
            _org0.addIgnoredReferral( "www.domain.com" );
            _org0.addIgnoredReferral( "sister.site.com" );
            
            assertEquals( 2, _org0.ignoredReferralsCount );
            assertTrue( _org0.isIgnoredReferral( "www.domain.com" ) );
            assertTrue( _org0.isIgnoredReferral( "sister.site.com" ) );
            assertFalse( _org0.isIgnoredReferral( "www.test.com" ) );
        }
        
        public function testClearIgnoredReferrals():void
        {
            _org0.addIgnoredReferral( "www.domain.com" );
            _org0.addIgnoredReferral( "sister.site.com" );
            _org0.clearIgnoredReferrals();
            
            assertEquals( 0, _org0.ignoredReferralsCount );
            assertFalse( _org0.isIgnoredReferral( "www.domain.com" ) );
            assertFalse( _org0.isIgnoredReferral( "sister.site.com" ) );
        }
        
        public function testAddIgnoredKeyword():void
        {
            _org0.addIgnoredKeyword( "foobar" );
            _org0.addIgnoredKeyword( "hello" );
            
            assertEquals( 2, _org0.ignoredKeywordsCount );
            assertTrue( _org0.isIgnoredKeyword( "foobar" ) );
            assertFalse( _org0.isIgnoredKeyword( "FooBar" ) );
            assertTrue( _org0.isIgnoredKeyword( "hello" ) );
            assertFalse( _org0.isIgnoredKeyword( "none" ) );
        }
        
        public function testClearIgnoredKeywords():void
        {
            _org0.addIgnoredKeyword( "foobar" );
            _org0.addIgnoredKeyword( "hello" );
            _org0.clearIgnoredKeywords();
            
            assertEquals( 0, _org0.ignoredKeywordsCount );
            assertFalse( _org0.isIgnoredKeyword( "foobar" ) );
            assertFalse( _org0.isIgnoredKeyword( "hello" ) );
        }
        
    }
}