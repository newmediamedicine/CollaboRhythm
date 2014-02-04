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
import castle.flexbridge.reflection.Void;

public class DiaryModel{

    public var _diaryEntries:Vector.<DiaryEntry> = new Vector.<DiaryEntry>;
    public var _urineEntries:Vector.<UrineEntry> = new Vector.<UrineEntry>;
    public var _painEntries:Vector.<PainEntry> = new Vector.<PainEntry>;
    private var _otherEntries:Vector.<OtherEntry> = new Vector.<OtherEntry>;
    private var _bowelEntries:Vector.<BowelEntry> = new Vector.<BowelEntry>;
    private var _foodDrinkEntries:Vector.<FoodDrinkEntry> = new Vector.<FoodDrinkEntry>;
    private var _drainEntries:Vector.<DrainEntry> = new Vector.<DrainEntry>;
    private var _prnMedsEntries:Vector.<PRNMedsEntry> = new Vector.<PRNMedsEntry>;
    private var _cleaningEntries:Vector.<CleaningEntry> = new Vector.<CleaningEntry>;
    private var _activityLevelEntries:Vector.<ActivityLevelEntry> = new Vector.<ActivityLevelEntry>;
    private var _dressingEntries:Vector.<DressingEntry> = new Vector.<DressingEntry>;
    private var _vomitingEntries:Vector.<VomitingEntry> = new Vector.<VomitingEntry>;

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
        _painEntries.push(painEntry)
    }
    public function addNewOtherEntry(otherEntry:OtherEntry):void{
        _otherEntries.push(otherEntry);
    }
    public function addNewBowelEntry (bowelEntry:BowelEntry):void{
        _bowelEntries.push(bowelEntry);
    }
    public function addNewFoodDrinkEntry (foodDrinkEntry:FoodDrinkEntry):void{
        _foodDrinkEntries.push(foodDrinkEntry);
    }
    public function addNewDrainEntry (drainEntry:DrainEntry):void{
        _drainEntries.push(drainEntry);
    }
    public function addNewPRNMedsEntry (prnMedsEntry:PRNMedsEntry):void{
        _prnMedsEntries.push(prnMedsEntry);
    }
    public function addNewCleaningEntry (cleaningEntry:CleaningEntry):void{
        _cleaningEntries.push(cleaningEntry);
    }
    public function addNewActivityLevelEntry (activityLevelEntry:ActivityLevelEntry):void{
        _activityLevelEntries.push(activityLevelEntry);
    }
    public function addNewDressingEntry (dressingEntry:DressingEntry):void {
        _dressingEntries.push(dressingEntry);
    }
    public function addNewVomitingEntry (vomitingEntry:VomitingEntry):void {
        _vomitingEntries.push(vomitingEntry);
    }


    public function get diaryEntries():Vector.<DiaryEntry> {
    return _diaryEntries;
}
    public function get urineEntries():Vector.<UrineEntry> {
    return _urineEntries;
}
    public function get painEntries():Vector.<PainEntry> {
    return _painEntries;
}
    public function get otherEntries():Vector.<OtherEntry> {
    return _otherEntries;
}
    public function get bowelEntries():Vector.<BowelEntry> {
    return _bowelEntries;
}
    public function get foodDrinkEntries():Vector.<FoodDrinkEntry> {
    return _foodDrinkEntries;
}
    public function get drainEntries():Vector.<DrainEntry> {
    return _drainEntries;
}
    public function get prnMedsEntries():Vector.<PRNMedsEntry> {
    return _prnMedsEntries;
}
    public function get cleaningEntries():Vector.<CleaningEntry> {
    return _cleaningEntries;
}
    public function get activityLevelEntries():Vector.<ActivityLevelEntry> {
    return _activityLevelEntries;
}
    public function get dressingEntries():Vector.<DressingEntry> {
    return _dressingEntries;
}
    public function get vomitingEntries():Vector.<VomitingEntry> {
    return _vomitingEntries;
}

}
}
