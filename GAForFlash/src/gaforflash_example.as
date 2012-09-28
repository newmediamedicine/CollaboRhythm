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

package
{
    import com.google.analytics.AnalyticsTracker;
    import com.google.analytics.GATracker;
    import com.google.analytics.core.TrackerMode;
    import com.google.analytics.log;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.system.System;
    
    /* note:
       Basic example
       
    */
    [SWF(width="800", height="600", backgroundColor='0xffffff', frameRate='24', pageTitle='example', scriptRecursionLimit='1000', scriptTimeLimit='60')]
    [ExcludeClass]
    public class gaforflash_example extends Sprite
    {
        /* You need to define a valid GA ID here */
        //private const GA_ID:String = "UA-111-222";
        private const GA_ID:String = "UA-94526-19";
        //private const GA_ID:String = "";
        
        public var tracker:AnalyticsTracker;
        
        public function gaforflash_example()
        {
            super();
            
            /* note:
               here how to override logger configuration
               see: com.google.analytics.log
            */
            var cfg:Object = { sep: " ", //char separator
                               mode: "clean", // "raw", "clean", "data", "short"
                               tag: true, //use tag
                               time: false  //use time
                             };
            log.config( cfg );
            log.level = log.VERBOSE;
            //log.level = log.DEBUG;
            //log.level = log.WARN;
            //log.level = log.ERROR;
            //log.level = log.SUPPRESS;
            
            if( stage )
            {
                onAddedToStage();
            }
            else
            {
                addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
            }
            
        }
        
        private function onAddedToStage( event:Event = null ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
            main();
        }
        
        private function _gasetup():void
        {
            /* we prevent the factory to build automatically */
            GATracker.autobuild = false;
            
            /* instanciation of the Google Analytics tracker */
            tracker = new GATracker( this, GA_ID );
            
            /* note:
               the 'this' reference need to be a DisplayObject
               properly instancied, eg. added to the display list
               so we can access the 'stage' property.
            */
            
            
            /* we configure the tracker */
            tracker.mode = TrackerMode.AS3;
            tracker.config.enableErrorChecking = true;
            tracker.config.sessionTimeout = 60;
            tracker.config.conversionTimeout = 180;
            
            /* we force the factory to build the tracker */
            GATracker(tracker).build();
        }
        
        private function _gatest():void
        {
            //track pageview test
            tracker.trackPageview( "/test" );
            
            //track event test
            tracker.trackEvent( "say", "hello world", "test", 123 );
        }
        
        public function main():void
        {
            /* note:
               any call ot the GA API before its setup
               will be cached temporarily
               
               and once the GATracker build
               the cached functions will run in batch
            */
            //tracker.trackPageview( "/before/setup" );
            
            _gasetup();
            
            /* note:
               from this point the GATracker is initialized
               and will send data to the Google Analytics server
            */
            
            _gatest();
            
        }
        
    }
}