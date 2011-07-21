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

	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import mx.collections.ArrayCollection;

	[Bindable]
    public class VideoMessagesModel extends DocumentCollectionBase
    {
        // TODO: Determine the best way to get a picture for a video message
        // There are flaws with using sharing relationships from the active account
		// TODO: rename this to nextFileId or eliminate and use a UUID instead
        private var _videoMessageCount:int = 0;

        public function VideoMessagesModel()
        {
			super(VideoMessage.DOCUMENT_TYPE);
        }

		override public function addDocument(document:IDocument):void
		{
			super.addDocument(document);
			var videoMessage:VideoMessage = document as VideoMessage;
			if (videoMessage.fileId > videoMessageCount)
			{
				videoMessageCount = videoMessage.fileId;
			}
		}

		/**
		 * Creates a new instance of VideoMessage. Does NOT add the new instance to the record.
		 * @param activeAccount
		 */
		public function createVideoMessage(activeAccount:Account, currentDateSource:ICurrentDateSource):VideoMessage
        {
            var videoMessage:VideoMessage = new VideoMessage();
            videoMessage.init((_videoMessageCount+1).toString(), "FlashMediaServer", "test", activeAccount, currentDateSource.now(), currentDateSource.now());
			videoMessage.pendingAction = DocumentBase.ACTION_CREATE;
            _videoMessageCount += 1;
			return videoMessage;
        }

        public function get videoMessagesCollection():ArrayCollection
        {
            return documents;
        }

        public function get videoMessageCount():int
        {
            return _videoMessageCount;
        }

        public function set videoMessageCount(value:int):void
        {
            _videoMessageCount = value;
        }
	}
}
