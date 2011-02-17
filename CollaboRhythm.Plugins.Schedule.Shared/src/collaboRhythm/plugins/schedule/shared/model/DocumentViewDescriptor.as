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
package collaboRhythm.plugins.schedule.shared.model
{
	/**
	 * Specifies a view class (which should be a UIComponent) which is applicable to a particular document type
	 * (the type of data) and view type (the context in which the data will be viewed).
	 */
	public class DocumentViewDescriptor
	{
		private var _viewClass:Class;
		private var _documentType:String;
		private var _viewType:String;

		public function DocumentViewDescriptor(documentType:String, viewType:String, viewClass:Class)
		{
			_documentType = documentType;
			_viewType = viewType;
			_viewClass = viewClass;
		}

		public function get viewClass():Class
		{
			return _viewClass;
		}

		public function get documentType():String
		{
			return _documentType;
		}

		public function get viewType():String
		{
			return _viewType;
		}
	}
}
