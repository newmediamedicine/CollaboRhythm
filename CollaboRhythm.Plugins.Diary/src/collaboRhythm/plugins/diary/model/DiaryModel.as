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
package collaboRhythm.plugins.diary.model
{

	public class DiaryModel{

        public var _diaryEntries:Vector.<DiaryEntry> = new Vector.<DiaryEntry>;
        public var _urineEntries:Vector.<UrineEntry> = new Vector.<UrineEntry>;
        public var _painEntry:Vector.<PainEntry> = new Vector.<PainEntry>;
        private var _otherEntry:Vector.<OtherEntry> = new Vector.<OtherEntry>;
        private var _photoEntry:Vector.<PhotoEntry> = new Vector.<PhotoEntry>;

        public function DiaryModel() {
    }

        public function addNewDiaryEntry(diaryEntry:DiaryEntry):void
    {
            _diaryEntries.push(diaryEntry);
    }

        public function addNewUrineEntry(urineEntry:UrineEntry):void{
            _urineEntries.push(urineEntry);
    }
        public function addNewPainEntry(painEntry:PainEntry):void{
            _painEntry.push(painEntry)
        }
        public function addNewOtherEntry(otherEntry:OtherEntry):void{
            _otherEntry.push(otherEntry);
        }
        public function addNewPhotoEntry (photoEntry:PhotoEntry):void{
            _photoEntry.push(photoEntry)
        }


        public function get diaryEntries():Vector.<DiaryEntry> {
        return _diaryEntries;
    }
}
}
