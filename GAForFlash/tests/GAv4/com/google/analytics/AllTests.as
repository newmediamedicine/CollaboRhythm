
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
	import library.ASTUce.framework.*;
    
    import com.google.analytics.campaign.AllTests;
    import com.google.analytics.core.AllTests;
    import com.google.analytics.data.AllTests;
    import com.google.analytics.external.AllTests;
    import com.google.analytics.utils.AllTests;   
    import com.google.analytics.ecommerce.AllTests; 

    public class AllTests
    {

        public static function suite():Test
        {
            var suite:TestSuite = new TestSuite( "Google Analytics tests" );
            
            suite.addTestSuite( ConfigurationTest );
  //          suite.addTestSuite( BridgeTest );
            
            /* packages */
            suite.addTest( com.google.analytics.core.AllTests.suite( ) );
            suite.addTest( com.google.analytics.data.AllTests.suite( ) );
            suite.addTest( com.google.analytics.utils.AllTests.suite( ) );
            suite.addTest( com.google.analytics.campaign.AllTests.suite( ) );
            suite.addTest( com.google.analytics.external.AllTests.suite( ) );
            suite.addTest( com.google.analytics.ecommerce.AllTests.suite() );
            
            return suite;
        }
    }
}
