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
package collaboRhythm.workstation.apps.problems.model
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ProblemsModel
	{
		private var _rawData:XML;
		private var _problemsCollection:ArrayCollection;
		private var _problemsShortList:ArrayCollection;
		private var _problemsSummary:String
		private var _initialized:Boolean = false;
		public static const PROBLEMS_KEY:String = "problems";
		
		public function ProblemsModel()
		{
			_problemsCollection = new ArrayCollection();
			_problemsShortList = new ArrayCollection();
		}

		/**
		 * Summarizes (join with separators) the short list of the common names of current problems.
		 * @return 
		 * 
		 */
		public function get problemsSummary():String
		{
			return _problemsSummary;
		}

		private function set problemsSummary(value:String):void
		{
			_problemsSummary = value;
		}

		/**
		 * Short list of the common names of current problems.  
		 * @return 
		 */
		public function get problemsShortList():ArrayCollection
		{
			//			var problemsShortList:ArrayCollection = new ArrayCollection();
			//			for each (var problem:Problem in this.problemsCollection)
			//			{
			//				if (!problem.isInactive)
			//				{
			//					problemsShortList.addItem(problem.commonName);
			//				}
			//			}
			return _problemsShortList;
		}
		
		private function set problemsShortList(value:ArrayCollection):void
		{
			_problemsShortList = value;
		}

		public function get problemsCollection():ArrayCollection
		{
			return _problemsCollection;
		}

		public function set problemsCollection(value:ArrayCollection):void
		{
			_problemsCollection = value;
		}

		public function get rawData():XML
		{
			return _rawData;
		}
		
		public function set rawData(value:XML):void
		{
			_rawData = value;
			if (initialized == false)
			{
				createProblemsCollection();
			}
		}
		
		private function createProblemsCollection():void
		{
			for each (var problemXml:XML in _rawData.Report.Item.Problem)
			{
				var problem:Problem = new Problem(problemXml);
				_problemsCollection.addItem(problem);
				if (!problem.isInactive)
					_problemsShortList.addItem(problem.commonName);
				// TODO: Determine why the problems are being created twice
				initialized = true;
			}
//			addExtraTestProblems();
			this.problemsSummary = this.problemsShortList.toArray().join(" | ")
		}
		
		private function addExtraTestProblems():void
		{
			for (var i:uint = 1; i <= 20; i++)
			{
				var problem:Problem = new Problem(
					<Problem>
						<name>Problem {i} {i.toFixed(i)} Name</name>
						<comments>Problem {i}</comments>
					</Problem>);
				_problemsCollection.addItem(problem);
			}
		}
		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void
		{
			_initialized = value;
		}
	}
}