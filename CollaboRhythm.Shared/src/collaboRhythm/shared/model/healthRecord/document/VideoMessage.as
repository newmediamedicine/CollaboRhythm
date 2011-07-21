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
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

    import collaboRhythm.shared.model.DateUtil;
    import com.adobe.utils.DateUtil;

    [Bindable]
    public class VideoMessage extends DocumentBase
    {
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#VideoMessage";

        private var _fileId:int;
        private var _storageType:String;
        private var _subject:String;
		private var _from:String;
        private var _fromAccount:Account;
        private var _dateRecorded:Date;
        private var _dateSent:Date;

        public function VideoMessage()
        {
        }

        public function init(fileId:String, storageType:String, subject:String, from:Account, dateRecorded:Date, dateSent:Date):void
		{
			meta.type = DOCUMENT_TYPE;
			_fileId = int(fileId);
            _storageType = storageType;
            _subject = subject;
            // TODO: Add checking here for null and potentially return null from the init
            // This might occur if there was previously a sharing relationship, a video was sent, but then the sharing relationship was removed
            if (from)
				_from = from.accountId;
			_fromAccount = from;
            _dateRecorded = dateRecorded;
            _dateSent = dateSent;
		}

		public function initFromReportXML(videoMessageReportXml:XML, activeAccount:Account):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			DocumentMetadata.parseDocumentMetadata(videoMessageReportXml.Meta.Document[0], this.meta);
			var videoMessageXml:XML = videoMessageReportXml.Item.VideoMessage[0];
			_fileId = int(videoMessageXml.fileId);
			_storageType = videoMessageXml.storageType;
			_subject = videoMessageXml.subject;
			_from = videoMessageXml.from;
			_fromAccount = activeAccount.allSharingAccounts[videoMessageXml.from];
            _dateRecorded = collaboRhythm.shared.model.DateUtil.parseW3CDTF(videoMessageXml.dateRecorded);
            _dateSent = collaboRhythm.shared.model.DateUtil.parseW3CDTF(videoMessageXml.dateSent);
		}

        public function convertToXML():XML
		{
			var videoMessageXml:XML = <VideoMessage/>;
			videoMessageXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
			videoMessageXml.fileId = fileId;
            videoMessageXml.storageType = storageType;
            videoMessageXml.subject = subject;
            videoMessageXml.from = fromAccount.accountId;
            videoMessageXml.dateRecorded = com.adobe.utils.DateUtil.toW3CDTF(dateRecorded);
            videoMessageXml.dateSent = com.adobe.utils.DateUtil.toW3CDTF(dateSent);
			
			return videoMessageXml;
		}

        public function get fileId():int
        {
            return _fileId;
        }

        public function set fileId(value:int):void
        {
            _fileId = value;
        }

        public function get storageType():String
        {
            return _storageType;
        }

        public function set storageType(value:String):void
        {
            _storageType = value;
        }

        public function get subject():String
        {
            return _subject;
        }

        public function set subject(value:String):void
        {
            _subject = value;
        }

        public function get fromAccount():Account
        {
            return _fromAccount;
        }

        public function set fromAccount(value:Account):void
        {
            _fromAccount = value;
        }

        public function get dateRecorded():Date
        {
            return _dateRecorded;
        }

        public function set dateRecorded(value:Date):void
        {
            _dateRecorded = value;
        }

        public function get dateSent():Date
        {
            return _dateSent;
        }

        public function set dateSent(value:Date):void
        {
            _dateSent = value;
        }

		public function get from():String
		{
			return _from;
		}

		public function set from(value:String):void
		{
			_from = value;
		}
	}
}
