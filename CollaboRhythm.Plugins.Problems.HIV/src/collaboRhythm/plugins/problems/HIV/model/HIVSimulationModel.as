package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;

	import flash.display.MovieClip;

	public class HIVSimulationModel
	{
		private var tcells:Array;
		private var freeTcells:Array;
		private var viruses:Array;
		private var attachedViruses:Array;
		private var looseViruses:Array;

		private var _cd4Count:Number = 438;
		private var _viralLoad:Number = 6400;

		private var _numTCells:Number;
		private var _numViruses:Number;
		private var _medConcentrations:Array = [1.5, 1.5, 0.75];
		private var _medGoalConcentrations:Array = [1, 1, 1];
		private var _medColors:Array = [0x000000, 0x333333, 0x666666];

		private var _openLooseVirusPos:Array = [];

		private var opentcellPos:Array;
		private var _usedtcellPos:Array;
		private var _activeRecord:Record;

		public function HIVSimulationModel(activeRecordAccount:Account)
		{
			_activeRecord = activeRecordAccount.primaryRecord;
		}

		public function updateSimulationData():void
		{
			tcells = [];
			freeTcells = [];
			viruses = [];
			attachedViruses = [];
			looseViruses = [];
			_openLooseVirusPos = [];
			opentcellPos = [
				[54, 74],
				[125, 34],
				[195, 100],
				[266, 54],
				[54, 146],
				[125, 187],
				[195, 184],
				[266, 174]
			];
			_usedtcellPos = [];



			_numTCells = Math.ceil(_cd4Count / 100);
			_numViruses = Math.ceil(_viralLoad / 100);

			for (var looseposition:int = 0; looseposition < 176; looseposition++)
			{
				_openLooseVirusPos[looseposition] = [(looseposition % 16) * 20 + 10, (Math.floor(looseposition / 16)) *
						20 + 10];
			}

			for (var tcellnum:int = 1; tcellnum <= _numTCells; tcellnum++)
			{
				var placenum:Number = Math.floor(Math.random() * opentcellPos.length);
				var tcellPos:Array = opentcellPos[placenum];
				var removepositions:Array = [];

				opentcellPos.splice(placenum, 1);
				_usedtcellPos.push(tcellPos);

				if (tcellPos[0] == 54 && tcellPos[1] == 74)
				{
					removepositions = [33, 34, 35, 36, 49, 50, 51, 52, 65, 66, 67, 68, 81, 82, 83, 84];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 125 && tcellPos[1] == 34)
				{
					removepositions = [4, 5, 6, 7, 20, 21, 22, 23, 36, 37, 38, 39, 52, 53, 54, 55];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 195 && tcellPos[1] == 100)
				{
					removepositions = [56, 57, 58, 59, 72, 73, 74, 75, 88, 89, 90, 91, 104, 105, 106, 107];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 266 && tcellPos[1] == 54)
				{
					removepositions = [27, 28, 29, 30, 43, 44, 45, 46, 59, 60, 61, 62, 75, 76, 77, 78];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 54 && tcellPos[1] == 146)
				{
					removepositions = [81, 82, 83, 84, 97, 98, 99, 100, 113, 114, 115, 116, 129, 130, 131, 132];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 125 && tcellPos[1] == 187)
				{
					removepositions = [116, 117, 118, 119, 132, 133, 134, 135, 148, 149, 150, 151, 164, 165, 166, 167];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 195 && tcellPos[1] == 184)
				{
					removepositions = [120, 121, 122, 123, 136, 137, 138, 139, 152, 153, 154, 155, 168, 169, 170, 171];
					removeLooseVirusPositions(removepositions);
				}
				else if (tcellPos[0] == 266 && tcellPos[1] == 174)
				{
					removepositions = [123, 124, 125, 126, 139, 140, 141, 142, 155, 156, 157, 158, 171, 172, 173, 174];
					removeLooseVirusPositions(removepositions);
				}

				tcells.push(tcellPos);
				freeTcells.push(tcellPos);
			}

			for (looseposition = 175; looseposition >= 0; looseposition--)
			{
				if (_openLooseVirusPos[looseposition] == 0)
				{
					_openLooseVirusPos.splice(looseposition, 1)
				}
			}
		}

		private function removeLooseVirusPositions(removepositions:Array)
		{
			for (var positiontoremove = 0; positiontoremove < removepositions.length; positiontoremove++)
			{
				_openLooseVirusPos[removepositions[positiontoremove]] = 0;
			}
		}

		public function get numTCells():Number
		{
			return _numTCells;
		}

		public function get numViruses():Number
		{
			return _numViruses;
		}

		public function get usedtcellPos():Array
		{
			return _usedtcellPos;
		}

		public function get openLooseVirusPos():Array
		{
			return _openLooseVirusPos;
		}

		public function get medConcentrations():Array
		{
			return _medConcentrations;
		}

		public function get medColors():Array
		{
			return _medColors;
		}

		public function get medGoalConcentrations():Array
		{
			return _medGoalConcentrations;
		}

		public function get activeRecord():Record
		{
			return _activeRecord;
		}
	}
}
