package collaboRhythm.workstation.apps.problems.model
{
	import collaboRhythm.workstation.model.HealthRecordServiceBase;
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;

	[Bindable]
	public class Problem
	{
		private var _name:String;
		private var _commonName:String;
		private var _dateOnset:Date;
		private var _dateResolution:Date;
		private var _currentDateSource:ICurrentDateSource;
		
		public function Problem(problemXml:XML)
		{
			_name = problemXml.name;
			_commonName = problemXml.comments;
			_dateOnset = HealthRecordServiceBase.parseDate(problemXml.dateOnset.toString());
			_dateResolution = HealthRecordServiceBase.parseDate(problemXml.dateResolution.toString());
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}
		
		public function get commonNameLabel():String
		{
			if (_commonName != null && _commonName.length > 0)
				return "(" + _commonName + ")";
			
			return null;
		}
		
		public function get commonName():String
		{
			return _commonName;
		}

		public function set commonName(value:String):void
		{
			_commonName = value;
		}

		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get isInactive():Boolean
		{
			if (_dateResolution != null)
			{
				return _dateResolution < _currentDateSource.now();
			}
			return false;
		}
	}
}