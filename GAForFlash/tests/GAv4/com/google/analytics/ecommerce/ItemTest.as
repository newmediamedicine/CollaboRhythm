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
	import com.google.analytics.utils.Variables;
	import library.ASTUce.framework.TestCase;
	
	public class ItemTest extends TestCase
	{
		public function ItemTest( name:String="" )
		{
			super( name );
		}
		
		public function testToGifParameters():void
		{	
			var myItem:Item = new Item( "111", "sku", "name", "category", "price", "quantity two" );
				
			var output:Variables = myItem.toGifParams();
			output.URIencode = true;
			
			var expectedOutput:String = "utmt=item&utmtid=111&utmipc=sku&utmipn=name&utmiva=category&utmipr=price&utmiqt=quantity%20two";
			
			assertEquals( expectedOutput, output.toString() );
		}

	}
}