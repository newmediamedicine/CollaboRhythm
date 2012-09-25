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
//    import com.google.analytics.AllTests;
    import com.google.analytics.log;
    
    import flash.display.Sprite;
    
    import library.ASTUce.Runner;
    
    /* note:
       Run the Google Analytics unit tests
    */
    [SWF(width="400", height="400", backgroundColor='0xffffff', frameRate='24', pageTitle='testrunner', scriptRecursionLimit='1000', scriptTimeLimit='60')]
    [ExcludeClass]
    public class TestRunner extends Sprite
    {
//        public function TestRunner()
//        {
//            //we don;t want any logs when running the unit tests
//            log.level = log.SUPPRESS;
//
//            Runner.main( com.google.analytics.AllTests.suite( ) );
//        }
        
    }
}