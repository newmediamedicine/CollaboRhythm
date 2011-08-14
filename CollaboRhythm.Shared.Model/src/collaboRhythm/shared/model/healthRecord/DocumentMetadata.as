/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model.healthRecord
{

	import com.adobe.utils.DateUtil;

	/**
	 * Basic implementation of document metadata for a health record document, such as a Problem or Medication.
	 */
	[Bindable]
	public class DocumentMetadata implements IDocumentMetadata
	{
		private var _id:String;
		private var _type:String;
		private var _createdAt:Date;

		public static const INDIVO_DOCUMENTS_NAMESPACE:String = "http://indivo.org/vocab/xml/documents#";

		public function DocumentMetadata(id:String=null, type:String=null)
		{
			_id = id;
			_type = type;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get shortType():String
		{
			if (!type) return null;

			var parts:Array = type.split("#");
			return parts[parts.length - 1];
		}

		/**
		 * Factory method parses the metadata from the document XML and returns a new DocumentMetadata.
		 * @param documentXml The document XML. The root node of the XML should be Document, and it should have metadata
		 * attributes: id and type.
		 * @return The new metadata object with values parsed from the XML.
		 */
		public static function createDocumentMetadata(documentXml:XML):DocumentMetadata
		{
			var documentMetadata:DocumentMetadata = new DocumentMetadata();
			parseDocumentMetadata(documentXml, documentMetadata);
			
			return documentMetadata;
		}

		public static function validateDocumentMetadata(documentXml:XML):Boolean
		{
			return documentXml.attribute("id").length() == 1;
		}

		public static function parseDocumentMetadata(documentXml:XML, documentMetadata:IDocumentMetadata):void
		{
			if (documentXml.attribute("id").length() != 1)
				throw new Error("Document does not have expected id attribute");
			
			documentMetadata.id = documentXml.@id.toString();
			documentMetadata.type = (documentXml.attribute("type").length() == 1) ? documentXml.@type.toString() : null;
			documentMetadata.createdAt = DateUtil.parseW3CDTF(documentXml.createdAt.toString());
		}

		public function get createdAt():Date
		{
			return _createdAt;
		}

		public function set createdAt(value:Date):void
		{
			_createdAt = value;
		}
	}
}
