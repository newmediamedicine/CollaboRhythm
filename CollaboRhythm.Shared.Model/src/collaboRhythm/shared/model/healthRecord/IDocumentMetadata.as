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

	/**
	 * Metadata for a health record document, such as a Problem or Medication.
	 */
	public interface IDocumentMetadata
	{
		/**
		 * The unique id of the document. This should uniquely identify the document in the context of the
		 * backend health record service and in CollaboRhythm.
		 */
		function get id():String;
		function set id(value:String):void;

		/**
		 * The fully qualified schema type of the document, such as "http://indivo.org/vocab/xml/documents#Problem".
		 */
		function get type():String;
		function set type(value:String):void;

		/**
		 * Short type name of the document, such as "Problem".
		 */
		function get shortType():String;

		/**
		 * Date when the document was created.
		 */
		function get createdAt():Date;
		function set createdAt(value:Date):void;

		function get replacesId():String;
		function set replacesId(value:String):void;

		function get replacedById():String;
		function set replacedById(value:String):void;

		function get replacedBy():IDocument;
		function set replacedBy(replacedBy:IDocument):void;

		function get originalId():String;
		function set originalId(value:String):void;
	}
}
