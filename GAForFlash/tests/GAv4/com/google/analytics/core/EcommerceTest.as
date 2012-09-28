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
 */

package com.google.analytics.core
{
	import com.google.analytics.ecommerce.Transaction;
	import library.ASTUce.framework.TestCase;
	
	public class EcommerceTest extends TestCase 
	{
		
		private var _ecom:Ecommerce;
		
		public function EcommerceTest(name:String="")
		{
			super( name );
		}
		
		public function setUp():void
		{
			_ecom = new Ecommerce();
		}
		
		public function testAddTransaction():void
		{
			var myTrans:Transaction;
			
			_ecom.addTransaction( "111", "affiliation", "total", "tax", "shipping", "city", "state", "country");							               
			_ecom.addTransaction( "222", "company", "150", "10.51", "30.00", "Berkeley", "CA", "USA");					               
			
			assertEquals( 2, _ecom.getTransLength() )	
			
			_ecom.addTransaction( "111", "test", "50", "10", "5", "Los Altos", "CA", "USA" );
			
			assertEquals( 2, _ecom.getTransLength() );	
			
			myTrans = _ecom.getTransaction( "111" );
			
			assertEquals( "111", myTrans.id );
			assertEquals( "test", myTrans.affiliation );					 
			assertEquals( "50", myTrans.total );
			assertEquals( "10", myTrans.tax );
			assertEquals( "5", myTrans.shipping );
			assertEquals( "Los Altos", myTrans.city );
			assertEquals( "CA", myTrans.state );
			assertEquals( "USA", myTrans.country );

		}
		
		public function testGetTransaction():void
		{
			var myTrans:Transaction;
			
			_ecom.addTransaction( "222", "company", "150", "10.51", "30.00", "Berkeley", "CA", "94707");
			_ecom.addTransaction( "111", "affiliation", "total", "tax", "shipping", "city", "state", "USA");							               
			
			myTrans = _ecom.getTransaction("111");
			
			assertEquals( "111", myTrans.id );
			assertEquals( "affiliation", myTrans.affiliation );					 
			assertEquals( "total", myTrans.total );
			assertEquals( "tax", myTrans.tax );
			assertEquals( "shipping", myTrans.shipping );
			assertEquals( "city", myTrans.city );	
			assertEquals( "state", myTrans.state );	
			assertEquals( "USA", myTrans.country );	
			
			myTrans = _ecom.getTransaction("333");
			
			assertEquals( null, myTrans); 		
		}
		
								 
					 
								 
								 
		

	}
}