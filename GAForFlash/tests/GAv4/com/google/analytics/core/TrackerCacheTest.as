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
 *   Marc ALCARAZ <ekameleon@gmail.com>.
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */
 
package com.google.analytics.core 
{
	import library.ASTUce.framework.ArrayAssert;
	import library.ASTUce.framework.TestCase;
    
    import com.google.analytics.v4.GoogleAnalyticsAPI;
    
    import flash.errors.IllegalOperationError;    

    public class TrackerCacheTest extends TestCase 
    {

        public function TrackerCacheTest(name:String = "")
        {
            super( name );
        }
        
        public var cache:TrackerCache ;
        
        public function setUp():void
        {
            cache = new TrackerCache() ;
        }
        
        public function tearDown():void
        {
            cache = null ;
        }
        
        public function testConstructor():void
        {
        	assertNotNull( cache , "The TrackerCache instance not must be null" ) ;
        }
        
        public function testInterface():void
        {
        	assertTrue( cache is GoogleAnalyticsAPI , "The TrackerCache instance must implement the GoogleAnalyticsAPI interface." ) ;
        }
        
        public function testCACHE_THROW_ERROR():void
        {
        	assertFalse( TrackerCache.CACHE_THROW_ERROR  , "01 - The TrackerCache.CACHE_THROW_ERROR static value must be false by default") ;
        	
        	TrackerCache.CACHE_THROW_ERROR = true ;
        	
        	assertTrue( TrackerCache.CACHE_THROW_ERROR  , "02 - The TrackerCache.CACHE_THROW_ERROR static value must be true.") ;
        	
        	TrackerCache.CACHE_THROW_ERROR = false ;
        	
        	assertFalse( TrackerCache.CACHE_THROW_ERROR  , "03 - The TrackerCache.CACHE_THROW_ERROR static value must be false.") ;
        }
        
        public function testTracker():void
        {
            var tc:GoogleAnalyticsAPI = new TrackerCache() ;
            
            cache.tracker = tc ;
            
            assertEquals( cache.tracker , tc  , "01 - The tracker property failed." ) ;
            
            cache.tracker = null ;
            
            assertNull( cache.tracker , "02 - The tracker property failed, must be null." ) ;
            
        }
        
        public function testClear():void
        {
        	cache.enqueue("myMethod", 1, 2, 3 ) ;
        	cache.enqueue("myMethod", 1, 2, 3 ) ;
        	cache.enqueue("myMethod", 1, 2, 3 ) ;
        	var oldSize:int = cache.size() ;
        	cache.clear() ;
        	assertEquals( oldSize  , 3  , "01 - TrackerCache clear method failed." ) ;
        	assertNotSame( cache.size() , oldSize  , "02 - TrackerCache clear method failed." ) ;
            assertEquals( cache.size()  , 0  , "03 - TrackerCache clear method failed." ) ;
        }
        
        public function testElement():void 
        {
            
            cache.enqueue("myMethod", 1, 2, 3 ) ;
            
            var element:Object = cache.element() ;
            
            assertEquals( element.name , "myMethod"  , "01 - TrackerCache element method failed." ) ;
            ArrayAssert.assertEquals( element.args as Array, [1,2,3]  , "02 - TrackerCache element method failed." ) ;
            
            cache.clear() ;
        }        
        
        public function testEnqueue():void 
        {
        	
        	assertFalse( cache.enqueue(null) , "01 - TrackerCache enqueue method failed with a name parameter null." ) ;
        	
            assertTrue( cache.enqueue("myMethod1", 1, 2, 3 ) , "02 - TrackerCache enqueue method failed." );
            
            assertEquals( cache.size() , 1  , "03 - TrackerCache enqueue method failed." ) ;
            
            assertTrue( cache.enqueue("myMethod2" ) , "04 - TrackerCache enqueue method failed." );
            
            assertEquals( cache.size() , 2  , "05 - TrackerCache enqueue method failed." ) ;            
            
            cache.clear() ;
        }
        
        public function testFlush():void
        {
        	var tc:TrackerCache = new TrackerCache() ;
        	
            cache.trackPageview("/hello1") ;
            cache.trackPageview("/hello2") ;
            cache.trackPageview("/hello3") ;
            
            cache.tracker = tc ;
            
            cache.flush() ; // the test fill an other TrackerCache
            
            assertTrue( cache.isEmpty()  , "01 - TrackerCache flush method failed, the cache must be empty." ) ;    
            assertEquals( tc.size() , 3  , "02 - TrackerCache flush method failed." ) ;  

        }
        
        public function testIsEmpty():void
        {
            assertTrue( cache.isEmpty() , "01 - The TrackerCache isEmpty method failed." ) ;
            cache.enqueue("myMethod", 1, 2, 3 ) ;
            assertFalse( cache.isEmpty() , "02 - The TrackerCache isEmpty method failed." ) ;
            cache.clear() ;
            assertTrue( cache.isEmpty() , "03 - The TrackerCache isEmpty method failed." ) ;
        }        
        
        public function testSize():void
        {
            cache.enqueue("myMethod1", 1, 2, 3 ) ;
            cache.enqueue("myMethod2", 1, 2, 3 ) ;
            cache.enqueue("myMethod3", 1, 2, 3 ) ;
            assertEquals( cache.size() , 3  , "01-02 - TrackerCache clear method failed." ) ;
            cache.clear() ;
        }        
        
        //////////////////////////// GoogleAnalyticsAPI implementation
        
        public function testAddIgnoredOrganic():void
        {
            
            cache.addIgnoredOrganic( "keyword" ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache addIgnoredOrganic method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache addIgnoredOrganic method failed." ) ;
            
            assertEquals( e.name , "addIgnoredOrganic"  , "03 - TrackerCache addIgnoredOrganic method failed." ) ;
            ArrayAssert.assertEquals( e.args as Array, ["keyword"]  , "04 - TrackerCache addIgnoredOrganic method failed." ) ;
            
            cache.clear() ;
        }

        public function testAddIgnoredRef():void
        {
            cache.addIgnoredRef( "referrer" ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache addIgnoredRef method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache addIgnoredRef method failed." ) ;
            
            assertEquals( e.name , "addIgnoredRef"  , "03 - TrackerCache addIgnoredRef method failed." ) ;
            ArrayAssert.assertEquals( e.args as Array, ["referrer"]  , "04 - TrackerCache addIgnoredRef method failed." ) ;
            
            cache.clear() ;
        }
        
        public function testAddItem():void
        {
            cache.addItem( "item", "sku", "name", "category" , 999, 1 ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache addItem method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache addItem method failed." ) ;
            
            assertEquals( e.name , "addItem"  , "03 - TrackerCache addItem method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["item", "sku", "name", "category" , 999, 1], 
                "04 - TrackerCache addItem method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testAddOrganic():void
        {
            cache.addOrganic( "engine", "keyword" ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache addOrganic method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache addOrganic method failed." ) ;
            
            assertEquals( e.name , "addOrganic"  , "03 - TrackerCache addOrganic method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["engine", "keyword"], 
                "04 - TrackerCache addOrganic method failed." 
            ) ;
            
            cache.clear() ;
        }        
        
        public function testAddTrans():void
        {
        	       	
        	TrackerCache.CACHE_THROW_ERROR = true ;
        	
            try
            {
            	cache.addTrans("orderId" , "affiliation", 2, 1000, 3, "marseille", "bdr", "france") ;
            	fail( "02-01 - TrackerCache addTrans method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
            	assertTrue( e is IllegalOperationError , "02-02 - TrackerCache addTrans method failed, must throw an IllegalOperationError.") ;
            	assertEquals
            	( 
            	   e.message,
            	   "The tracker is not ready and you can use the 'addTrans' method for the moment." , 
            	   "02-03 - TrackerCache addTrans method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertNull
            (
               cache.addTrans("orderId" , "affiliation", 2, 1000, 3, "marseille", "bdr", "france") ,
                "01 - TrackerCache addTrans method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );            
            
        }
                
        public function testClearIgnoredOrganic():void
        {
            cache.clearIgnoredOrganic() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache clearIgnoredOrganic method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache clearIgnoredOrganic method failed." ) ;
            
            assertEquals( e.name , "clearIgnoredOrganic"  , "03 - TrackerCache clearIgnoredOrganic method failed." ) ;
            assertTrue( e["args"] is Array   , "04 - TrackerCache clearIgnoredOrganic method failed." ) ;
            
            cache.clear() ;
        }
        
        public function testClearIgnoredRef():void
        {
            cache.clearIgnoredRef() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache clearIgnoredRef method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache clearIgnoredRef method failed." ) ;
            
            assertEquals( e.name , "clearIgnoredRef"  , "03 - TrackerCache clearIgnoredRef method failed." ) ;
            assertTrue( e["args"] is Array  , "04 - TrackerCache clearIgnoredRef method failed." ) ;
            
            cache.clear() ;
        }
        
        public function testClearOrganic():void
        {
            cache.clearOrganic() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache clearOrganic method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache clearOrganic method failed." ) ;
            
            assertEquals( e.name , "clearOrganic"  , "03 - TrackerCache clearOrganic method failed." ) ;
            assertTrue( e["args"] is Array   , "04 - TrackerCache clearOrganic method failed." ) ;
            
            cache.clear() ;
        }
        
        public function testCreateEventTracker():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.createEventTracker("name") ;
                fail( "01-01 - TrackerCache createEventTracker method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache createEventTracker method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'createEventTracker' method for the moment." , 
                   "01-03 - TrackerCache createEventTracker method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertNull
            (
               cache.createEventTracker("name")  ,
                "02 - TrackerCache createEventTracker method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );            
            
        }        
        
        public function testCookiePathCopy():void
        {
            cache.cookiePathCopy( "path" ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache cookiePathCopy method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache cookiePathCopy method failed." ) ;
            
            assertEquals( e.name , "cookiePathCopy"  , "03 - TrackerCache cookiePathCopy method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["path"], 
                "04 - TrackerCache cookiePathCopy method failed." 
            ) ;
            
            cache.clear() ;
        }       
        
        public function testGetAccount():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getAccount() ;
                fail( "01-01 - TrackerCache getAccount method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getAccount method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getAccount' method for the moment." , 
                   "01-03 - TrackerCache getAccount method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertEquals
            (
               cache.getAccount()  , "" ,
                "02 - TrackerCache getAccount method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );    
        }
        
        public function testGetClientInfo():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getClientInfo() ;
                fail( "01-01 - TrackerCache getClientInfo method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getClientInfo method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getClientInfo' method for the moment." , 
                   "01-03 - TrackerCache getClientInfo method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertFalse
            (
               cache.getClientInfo()  ,
                "02 - TrackerCache getClientInfo method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );   
        }
        
        public function testGetDetectFlash():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getDetectFlash() ;
                fail( "01-01 - TrackerCache getDetectFlash method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getDetectFlash method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getDetectFlash' method for the moment." , 
                   "01-03 - TrackerCache getDetectFlash method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertFalse
            (
               cache.getDetectFlash()  ,
                "02 - TrackerCache getDetectFlash method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );   
        }
        
        public function testGetDetectTitle():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getDetectTitle() ;
                fail( "01-01 - TrackerCache getDetectTitle method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getDetectTitle method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getDetectTitle' method for the moment." , 
                   "01-03 - TrackerCache getDetectTitle method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertFalse
            (
               cache.getDetectTitle()  ,
                "02 - TrackerCache getDetectTitle method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );  
        }
                
        public function testGetLocalGifPath():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getLocalGifPath() ;
                fail( "01-01 - TrackerCache getLocalGifPath method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getLocalGifPath method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getLocalGifPath' method for the moment." , 
                   "01-03 - TrackerCache getLocalGifPath method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertEquals
            (
               cache.getLocalGifPath()  , "" , 
                "02 - TrackerCache getLocalGifPath method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );  
        }
        
        public function testGetServiceMode():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getServiceMode() ;
                fail( "01-01 - TrackerCache getServiceMode method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getServiceMode method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getServiceMode' method for the moment." , 
                   "01-03 - TrackerCache getServiceMode method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertNull
            (
               cache.getServiceMode() , 
                "02 - TrackerCache getServiceMode method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );  
        }
        
        public function testGetVersion():void
        {
            TrackerCache.CACHE_THROW_ERROR = true ;
            
            try
            {
                cache.getVersion() ;
                fail( "01-01 - TrackerCache getVersion method failed, must throw an error." ) ;
            }
            catch( e:Error )
            {
                assertTrue( e is IllegalOperationError , "01-02 - TrackerCache getVersion method failed, must throw an IllegalOperationError.") ;
                assertEquals
                ( 
                   e.message,
                   "The tracker is not ready and you can use the 'getVersion' method for the moment." , 
                   "01-03 - TrackerCache getVersion method failed, must throw an IllegalOperationError.") ;
            }
            
            TrackerCache.CACHE_THROW_ERROR = false ;
            
            assertEquals
            (
               cache.getVersion()  , "" , 
                "02 - TrackerCache getVersion method failed, must return a null value if the CACHE_THROW_ERROR is true."
            );
        }         
        
        public function testResetSession():void
        {
            cache.resetSession() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache resetSession method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache resetSession method failed." ) ;
            
            assertEquals( e.name , "resetSession"  , "03 - TrackerCache resetSession method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [], 
                "04 - TrackerCache resetSession method failed." 
            ) ;
            cache.clear() ;
        }
        
        public function testLink():void
        {
            cache.link("targetUrl", false) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache link method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache link method failed." ) ;
            
            assertEquals( e.name , "link"  , "03 - TrackerCache link method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["targetUrl", false], 
                "04 - TrackerCache link method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testLinkByPost():void
        {
            cache.linkByPost( "formObject" , false ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache linkByPost method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache linkByPost method failed." ) ;
            
            assertEquals( e.name , "linkByPost"  , "03 - TrackerCache linkByPost method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["formObject" , false], 
                "04 - TrackerCache linkByPost method failed." 
            ) ;
            
            cache.clear() ;
        }        
        
        public function testSetAllowAnchor():void
        {
            cache.setAllowAnchor(false) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setAllowAnchor method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setAllowAnchor method failed." ) ;
            
            assertEquals( e.name , "setAllowAnchor"  , "03 - TrackerCache setAllowAnchor method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [false], 
                "04 - TrackerCache setAllowAnchor method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetAllowHash():void
        {
            cache.setAllowHash(false) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setAllowHash method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setAllowHash method failed." ) ;
            
            assertEquals( e.name , "setAllowHash"  , "03 - TrackerCache setAllowHash method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [false], 
                "04 - TrackerCache setAllowHash method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetAllowLinker():void
        {
            cache.setAllowLinker(false) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setAllowLinker method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setAllowLinker method failed." ) ;
            
            assertEquals( e.name , "setAllowLinker"  , "03 - TrackerCache setAllowLinker method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [false], 
                "04 - TrackerCache setAllowLinker method failed." 
            ) ;
            
            cache.clear() ;
        }
             
        public function testSetCampContentKey():void
        {
            cache.setCampContentKey("key") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampContentKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampContentKey method failed." ) ;
            
            assertEquals( e.name , "setCampContentKey"  , "03 - TrackerCache setCampContentKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["key"], 
                "04 - TrackerCache setCampContentKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampMediumKey():void
        {
            cache.setCampMediumKey("key") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampMediumKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampMediumKey method failed." ) ;
            
            assertEquals( e.name , "setCampMediumKey"  , "03 - TrackerCache setCampMediumKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["key"], 
                "04 - TrackerCache setCampMediumKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampNameKey():void
        {
            cache.setCampNameKey("name") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampNameKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampNameKey method failed." ) ;
            
            assertEquals( e.name , "setCampNameKey"  , "03 - TrackerCache setCampNameKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["name"], 
                "04 - TrackerCache setCampNameKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampNOKey():void
        {
            cache.setCampNOKey("nokey") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampNOKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampNOKey method failed." ) ;
            
            assertEquals( e.name , "setCampNOKey"  , "03 - TrackerCache setCampNOKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["nokey"], 
                "04 - TrackerCache setCampNOKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampSourceKey():void
        {
            cache.setCampSourceKey("key") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampSourceKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampSourceKey method failed." ) ;
            
            assertEquals( e.name , "setCampSourceKey"  , "03 - TrackerCache setCampSourceKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["key"], 
                "04 - TrackerCache setCampSourceKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampTermKey():void
        {
            cache.setCampTermKey("key") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampTermKey method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampTermKey method failed." ) ;
            
            assertEquals( e.name , "setCampTermKey"  , "03 - TrackerCache setCampTermKey method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["key"], 
                "04 - TrackerCache setCampTermKey method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCampaignTrack():void
        {
            cache.setCampaignTrack(true) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCampaignTrack method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCampaignTrack method failed." ) ;
            
            assertEquals( e.name , "setCampaignTrack"  , "03 - TrackerCache setCampaignTrack method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [true], 
                "04 - TrackerCache setCampaignTrack method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetClientInfo():void
        {
            cache.setClientInfo(true) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setClientInfo method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setClientInfo method failed." ) ;
            
            assertEquals( e.name , "setClientInfo"  , "03 - TrackerCache setClientInfo method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [true], 
                "04 - TrackerCache setClientInfo method failed." 
            ) ;
            
            cache.clear() ;
        }        
        
        public function testSetCookieTimeout():void
        {
            cache.setCookieTimeout(2) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCookieTimeout method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCookieTimeout method failed." ) ;
            
            assertEquals( e.name , "setCookieTimeout"  , "03 - TrackerCache setCookieTimeout method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [2], 
                "04 - TrackerCache setCookieTimeout method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetCookiePath():void
        {
            cache.setCookiePath("path") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setCookiePath method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setCookiePath method failed." ) ;
            
            assertEquals( e.name , "setCookiePath"  , "03 - TrackerCache setCookiePath method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["path"], 
                "04 - TrackerCache setCookiePath method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetDetectFlash():void
        {
            cache.setDetectFlash(true) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setDetectFlash method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setDetectFlash method failed." ) ;
            
            assertEquals( e.name , "setDetectFlash"  , "03 - TrackerCache setDetectFlash method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [true], 
                "04 - TrackerCache setDetectFlash method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetDetectTitle():void
        {
            cache.setDetectTitle(true) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setDetectTitle method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setDetectTitle method failed." ) ;
            
            assertEquals( e.name , "setDetectTitle"  , "03 - TrackerCache setDetectTitle method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [true], 
                "04 - TrackerCache setDetectTitle method failed." 
            ) ;
            
            cache.clear() ;
        }        
        
        public function testSetDomainName():void
        {
            cache.setDomainName("name") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setDomainName method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setDomainName method failed." ) ;
            
            assertEquals( e.name , "setDomainName"  , "03 - TrackerCache setDomainName method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["name"], 
                "04 - TrackerCache setDomainName method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetLocalGifPath():void
        {
            cache.setLocalGifPath("path") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setLocalGifPath method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setLocalGifPath method failed." ) ;
            
            assertEquals( e.name , "setLocalGifPath"  , "03 - TrackerCache setLocalGifPath method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["path"], 
                "04 - TrackerCache setLocalGifPath method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetLocalRemoteServerMode():void
        {
            cache.setLocalRemoteServerMode() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setLocalRemoteServerMode method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setLocalRemoteServerMode method failed." ) ;
            
            assertEquals( e.name , "setLocalRemoteServerMode"  , "03 - TrackerCache setLocalRemoteServerMode method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [], 
                "04 - TrackerCache setLocalRemoteServerMode method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetLocalServerMode():void
        {
            cache.setLocalServerMode() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setLocalServerMode method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setLocalServerMode method failed." ) ;
            
            assertEquals( e.name , "setLocalServerMode"  , "03 - TrackerCache setLocalServerMode method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [], 
                "04 - TrackerCache setLocalServerMode method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetRemoteServerMode():void
        {
            cache.setRemoteServerMode() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setRemoteServerMode method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setRemoteServerMode method failed." ) ;
            
            assertEquals( e.name , "setRemoteServerMode"  , "03 - TrackerCache setRemoteServerMode method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [], 
                "04 - TrackerCache setRemoteServerMode method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetSampleRate():void
        {
            cache.setSampleRate(1000) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setSampleRate method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setSampleRate method failed." ) ;
            
            assertEquals( e.name , "setSampleRate"  , "03 - TrackerCache setSampleRate method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [1000], 
                "04 - TrackerCache setSampleRate method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetSessionTimeout():void
        {
            cache.setSessionTimeout(1000) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setSessionTimeout method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setSessionTimeout method failed." ) ;
            
            assertEquals( e.name , "setSessionTimeout"  , "03 - TrackerCache setSessionTimeout method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [1000], 
                "04 - TrackerCache setSessionTimeout method failed." 
            ) ;
            
            cache.clear() ;
        }
        
        public function testSetVar():void
        {
            cache.setVar("value") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache setVar method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache setVar method failed." ) ;
            
            assertEquals( e.name , "setVar"  , "03 - TrackerCache setVar method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["value"], 
                "04 - TrackerCache setVar method failed." 
            ) ;
            
            cache.clear() ;
        }
         
        public function testTrackEvent():void
        {
            assertTrue
            ( 
                cache.trackEvent("category", "action", "label", 1) , 
                "00 - TrackerCache trackEvent method failed."
            ) ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache trackEvent method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache trackEvent method failed." ) ;
            
            assertEquals( e.name , "trackEvent"  , "03 - TrackerCache trackEvent method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["category", "action", "label", 1], 
                "04 - TrackerCache setVar method failed." 
            ) ;
            
            cache.clear() ;
        }           
        
        public function testTrackPageview():void
        {
            cache.trackPageview("pageUrl") ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache trackPageview method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache trackPageview method failed." ) ;
            
            assertEquals( e.name , "trackPageview"  , "03 - TrackerCache trackPageview method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                ["pageUrl"], 
                "04 - TrackerCache trackPageview method failed." 
            ) ;
            
            cache.clear() ;
        }         
        
        public function testTrackTrans():void
        {
            cache.trackTrans() ;
            
            assertEquals( cache.size() , 1  , "01 - TrackerCache trackTrans method failed." ) ;
            
            var e:Object = cache.element() ;
            
            assertNotNull( e , "02 - TrackerCache trackTrans method failed." ) ;
            
            assertEquals( e.name , "trackTrans"  , "03 - TrackerCache trackTrans method failed." ) ;
            ArrayAssert.assertEquals
            ( 
                e.args as Array , 
                [], 
                "04 - TrackerCache trackPageview method failed." 
            ) ;
            
            cache.clear() ;
        }         
        
    }
}
