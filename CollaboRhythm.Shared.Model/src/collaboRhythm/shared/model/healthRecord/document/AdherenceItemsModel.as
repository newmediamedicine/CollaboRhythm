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
package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import com.adobe.utils.StringUtil;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class AdherenceItemsModel extends DocumentCollectionBase
	{
        private var _adherenceItems:HashMap = new HashMap();
        private var _adherenceItemsCollectionsByCode:HashMap = new HashMap();

		public function AdherenceItemsModel()
		{
			super(AdherenceItem.DOCUMENT_TYPE);
		}

        public function get adherenceItems():HashMap
        {
            return _adherenceItems;
        }

        public function set adherenceItems(value:HashMap):void
        {
            _adherenceItems = value;
        }

		public function get adherenceItemsCollectionsByCode():HashMap
		{
			return _adherenceItemsCollectionsByCode;
		}

		override public function addDocument(document:IDocument):void
		{
			validateDocumentType(document);
			addAdherenceItem(document as AdherenceItem)
		}

		public function addAdherenceItem(adherenceItem:AdherenceItem):void
		{
			adherenceItems.put(adherenceItem.meta.id, adherenceItem);
			documents.addItem(adherenceItem);
			addToAdherenceItemsCollectionsByCode(adherenceItem);
		}

		protected function addToAdherenceItemsCollectionsByCode(adherenceItem:AdherenceItem):void
		{
			var code:String = adherenceItem.name.value;
			if (!StringUtil.stringHasValue(code))
			{
				// fall back to using the text as the code if there is no value attribute
				code = adherenceItem.name.text;
			}

			var collection:ArrayCollection = _adherenceItemsCollectionsByCode[code];
			if (collection == null)
			{
				collection = new ArrayCollection();
				_adherenceItemsCollectionsByCode.put(code, collection);
			}
			collection.addItem(adherenceItem);
		}

		override public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			super.removeDocument(document);
			adherenceItems.remove(oldId);
			removeFromAdherenceItemsCollectionsByCode(document as AdherenceItem);

			addDocument(document);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);
			adherenceItems.remove(document.meta.id);
			removeFromAdherenceItemsCollectionsByCode(document as AdherenceItem);
		}

		protected function removeFromAdherenceItemsCollectionsByCode(adherenceItem:AdherenceItem):void
		{
			var collection:ArrayCollection = _adherenceItemsCollectionsByCode[adherenceItem.name.value];
			if (collection != null)
			{
				if (collection.contains(adherenceItem))
				{
					collection.removeItemAt(collection.getItemIndex(adherenceItem));
				}
			}
		}
	}
}