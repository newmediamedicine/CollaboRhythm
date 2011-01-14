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
			for each (var problemXml:XML in rawData.Report.Item.Problem)
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