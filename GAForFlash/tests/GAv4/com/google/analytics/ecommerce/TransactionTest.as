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

package com.google.analytics.ecommerce
{
	import library.ASTUce.framework.TestCase;
	import com.google.analytics.utils.Variables;
	
	public class TransactionTest extends TestCase 
	{
		private var _myTrans:Transaction;
		
		public function TransactionTest( name:String="" )
		{
			super( name );
		}
		
		public function setUp():void
		{
			_myTrans = new Transaction( "111", "affiliation", "total", "tax", "shipping", "city", "state region", "country" );			
		}
				
		public function testToGifParameters():void
		{		
			var output:Variables = _myTrans.toGifParams();
			output.URIencode = true;
			
			var expectedOutput:String = "utmt=tran&utmtid=111&utmtst=affiliation&utmtto=total&utmttx=tax&utmtsp=shipping&utmtci=city&utmtrg=state%20region&utmtco=country";
			
			assertEquals( expectedOutput, output.toString() );
		}
		
		public function testAddItem():void
		{
			var myItem:Item;
			
			_myTrans.addItem( "sku", "name", "category", "price", "quantity" );
			_myTrans.addItem( "12345", "Bracelet", "Jewelery", "100", "1" );
			
			assertEquals( 2, _myTrans.getItemsLength() );
			
			_myTrans.addItem( "sku", "Camera", "Electronics", "500", "2" );
			
			assertEquals( 2, _myTrans.getItemsLength() );
			
			myItem = _myTrans.getItem( "sku" );
			
			assertEquals( "Camera", myItem.name );
			assertEquals( "Electronics", myItem.category );
			assertEquals( "500", myItem.price );
			assertEquals( "2", myItem.quantity );
			
		}
		
		public function testGetItem():void
		{
			var myItem:Item;
			
			_myTrans.addItem( "sku", "name", "category", "price", "quantity" );
			_myTrans.addItem( "12345", "Bracelet", "Jewelery", "100", "1" );
						
			myItem = _myTrans.getItem( "12345" );
			
			assertEquals( "12345", myItem.sku );
			assertEquals( "Bracelet", myItem.name );
			assertEquals( "Jewelery", myItem.category );
			assertEquals( "100", myItem.price );
			assertEquals( "1", myItem.quantity );
			
			myItem = _myTrans.getItem( "54321" );
			
			assertEquals( null, myItem );
		}

	}
}
		