/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.shared.view
{
	import spark.components.Button;
	import spark.primitives.BitmapImage;
	
	public class IconButton extends Button
	{
		//--------------------------------------------------------------------------
		//
		//    Constructor
		//
		//--------------------------------------------------------------------------
		
		public function IconButton()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//    Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  icon
		//----------------------------------
		
//		/**
//		 *  @private
//		 *  Internal storage for the icon property.
//		 */
//		private var _icon:Class;
//		
//		[Bindable]
//		
//		/**
//		 *  
//		 */
//		public function get icon():Class
//		{
//			return _icon;
//		}
//		
//		/**
//		 *  @private
//		 */
//		public function set icon(val:Class):void
//		{
//			_icon = val;
//			
//			if (iconElement != null)
//				iconElement.source = _icon;
//		}
		
//		//--------------------------------------------------------------------------
//		//
//		//  Skin Parts
//		//
//		//--------------------------------------------------------------------------
//		
//		[SkinPart("false")]
//		public var iconElement:BitmapImage;
		
		
//		//--------------------------------------------------------------------------
//		//
//		//  Overridden methods
//		//
//		//--------------------------------------------------------------------------
//		
//		/**
//		 *  @private
//		 */
//		override protected function partAdded(partName:String, instance:Object):void
//		{
//			super.partAdded(partName, instance);
//			
//			if (icon !== null && instance == iconElement)
//			{
//				iconElement.source = icon;
//				iconElement.smooth = true;
//			}
//		}
	}
}