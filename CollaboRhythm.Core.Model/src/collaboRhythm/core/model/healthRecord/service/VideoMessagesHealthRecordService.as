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
package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.*;
	import collaboRhythm.shared.model.healthRecord.document.VideoMessage;

	public class VideoMessagesHealthRecordService extends DocumentStorageSingleReportServiceBase
	{
		public function VideoMessagesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													 account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account,
				  VideoMessage.DOCUMENT_TYPE, VideoMessage, Schemas.VideoMessageSchema, "videomessages");
		}

		override protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			var videoMessage:VideoMessage = document as VideoMessage;
			return videoMessage.dateRecorded == null || videoMessage.dateRecorded.valueOf() <= nowTime;
		}

		override public function unmarshallXml(reportXml:XML):IDocument
		{
			var document:IDocument = super.unmarshallXml(reportXml);
			var videoMessage:VideoMessage = document as VideoMessage;
			if (videoMessage.from)
				videoMessage.fromAccount = _activeAccount.allSharingAccounts[videoMessage.from];

			return document;
		}
	}
}