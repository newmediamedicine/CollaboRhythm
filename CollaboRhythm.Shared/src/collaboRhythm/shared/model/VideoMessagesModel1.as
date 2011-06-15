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
package collaboRhythm.shared.model
{

    import collaboRhythm.shared.model.healthRecord.VideoMessagesHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.collections.ArrayCollection;

    [Bindable]
    public class VideoMessagesModel1
    {
        // TODO: Determine the best way to get a picture for a video message
        // There are flaws with using sharing relationships from the active account
        private var _activeAccount:Account;
        private var _record:Record;
        private var _videoMessagesHealthRecordService:VideoMessagesHealthRecordService;
        private var _videoMessagesCollection:ArrayCollection = new ArrayCollection();
        private var _videoMessageCount:int = 0;
        private var _currentDateSource:ICurrentDateSource;

        public function VideoMessagesModel1(settings:Settings, activeAccount:Account, record:Record)
        {
            _activeAccount = activeAccount;
            _record = record;
            _videoMessagesHealthRecordService = new VideoMessagesHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function getVideoMessages():void
        {
            _videoMessagesHealthRecordService.getVideoMessages(_record);
        }

		public function set videoMessagesReportXml(value:XML):void
		{
            for each (var videoMessageXml:XML in value.Report)
			{
				var videoMessage:VideoMessage = new VideoMessage(_activeAccount);
                videoMessage.initFromReportXML(videoMessageXml);
                if (videoMessage.fileId > videoMessageCount)
                {
                    videoMessageCount = videoMessage.fileId;
                }
                _videoMessagesCollection.addItem(videoMessage);
			}
		}

        public function createVideoMessage():void
        {
            var videoMessage:VideoMessage = new VideoMessage(_activeAccount);
            videoMessage.init((_videoMessageCount+1).toString(), "FlashMediaServer", "test", _activeAccount, currentDateSource.now(), currentDateSource.now());
            _videoMessageCount += 1;
            _videoMessagesCollection.addItem(videoMessage);
            _videoMessagesHealthRecordService.postVideoMessage(_record, videoMessage);
        }

        public function get videoMessagesCollection():ArrayCollection
        {
            return _videoMessagesCollection;
        }

        public function set videoMessagesCollection(value:ArrayCollection):void
        {
            _videoMessagesCollection = value;
        }

        public function get videoMessageCount():int
        {
            return _videoMessageCount;
        }

        public function set videoMessageCount(value:int):void
        {
            _videoMessageCount = value;
        }

        public function get currentDateSource():ICurrentDateSource
        {
            return _currentDateSource;
        }

        public function deleteVideoMessage(videoMessage:VideoMessage):void
        {
            var videoMessageIndex:int = videoMessagesCollection.getItemIndex(videoMessage);
            videoMessagesCollection.removeItemAt(videoMessageIndex);
            _videoMessagesHealthRecordService.deleteVideoMessage(_record, videoMessage);
        }
    }
}
