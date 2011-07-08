package collaboRhythm.shared.model
{

    import castle.flexbridge.common.NotSupportedError;

    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    import mx.events.PropertyChangeEvent;

    [Bindable]
    public class Demographics
    {
        private var _dateOfBirth:Date;
		private var _dateOfDeath:Date;
		private var _gender:String;
		private var _ethnicity:String;
		private var _language:String;
		private var _maritalStatus:String;
		private var _employmentStatus:String;
		private var _employmentIndustry:String;
		private var _occupation:String;
		private var _religion:String;
		private var _income:String;
		private var _highestEducation:String;
		private var _organDonor:Boolean;

		private var _currentDateSource:ICurrentDateSource;

        public function Demographics(demographicsXml:XML)
        {
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
            initFromXml(demographicsXml);
        }

        public function initFromXml(demographicsXml:XML):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            if (demographicsXml.hasOwnProperty("dateOfBirth"))
				dateOfBirth = DateUtil.parseW3CDTF(demographicsXml.dateOfBirth);
			if (demographicsXml.hasOwnProperty("dateOfDeath"))
				dateOfDeath = DateUtil.parseW3CDTF(demographicsXml.dateOfDeath);
			if (demographicsXml.hasOwnProperty("gender"))
				gender = demographicsXml.gender;
            if (demographicsXml.hasOwnProperty("ethnicity"))
				ethnicity = demographicsXml.ethnicity;
            if (demographicsXml.hasOwnProperty("language"))
				language = demographicsXml.language;
            if (demographicsXml.hasOwnProperty("maritalStatus"))
				maritalStatus = demographicsXml.maritalStatus;
            if (demographicsXml.hasOwnProperty("employmentStatus"))
				employmentStatus = demographicsXml.employmentStatus;
            if (demographicsXml.hasOwnProperty("employmentIndustry"))
				employmentIndustry = demographicsXml.employmentIndustry;
            if (demographicsXml.hasOwnProperty("occupation"))
				occupation = demographicsXml.occupation;
            if (demographicsXml.hasOwnProperty("religion"))
				religion = demographicsXml.religion;
            if (demographicsXml.hasOwnProperty("income"))
				income = demographicsXml.income;
            if (demographicsXml.hasOwnProperty("highestEducation"))
				highestEducation = demographicsXml.highestEducation;
            if (demographicsXml.hasOwnProperty("organDonor"))
				organDonor = demographicsXml.organDonor;
        }

        public function get dateOfBirth():Date
		{
			return _dateOfBirth;
		}

		public function set dateOfBirth(value:Date):void
		{
			_dateOfBirth = value;
			dispatchAgeChangeEvent();
		}

		public function dispatchAgeChangeEvent():void
		{
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "age", NaN, this.age));
		}

		public function get dateOfDeath():Date
		{
			return _dateOfDeath;
		}

		public function set dateOfDeath(value:Date):void
		{
			_dateOfDeath = value;
		}

		public function get gender():String
		{
			return _gender;
		}

		public function set gender(value:String):void
		{
			_gender = value;
		}

		public function get ethnicity():String
		{
			return _ethnicity;
		}

		public function set ethnicity(value:String):void
		{
			_ethnicity = value;
		}

		public function get language():String
		{
			return _language;
		}

		public function set language(value:String):void
		{
			_language = value;
		}

		public function get maritalStatus():String
		{
			return _maritalStatus;
		}

		public function set maritalStatus(value:String):void
		{
			_maritalStatus = value;
		}

		public function get employmentStatus():String
		{
			return _employmentStatus;
		}

		public function set employmentStatus(value:String):void
		{
			_employmentStatus = value;
		}

		public function get employmentIndustry():String
		{
			return _employmentIndustry;
		}

		public function set employmentIndustry(value:String):void
		{
			_employmentIndustry = value;
		}

		public function get occupation():String
		{
			return _occupation;
		}

		public function set occupation(value:String):void
		{
			_occupation = value;
		}

		public function get religion():String
		{
			return _religion;
		}

		public function set religion(value:String):void
		{
			_religion = value;
		}

		public function get income():String
		{
			return _income;
		}

		public function set income(value:String):void
		{
			_income = value;
		}

		public function get highestEducation():String
		{
			return _highestEducation;
		}

		public function set highestEducation(value:String):void
		{
			_highestEducation = value;
		}

		public function get organDonor():Boolean
		{
			return _organDonor;
		}

		public function set organDonor(value:Boolean):void
		{
			_organDonor = value;
		}

		public function get age():Number
		{
			return dateToAge(this.dateOfBirth);
		}

		public function set age(value:Number):void
		{
			throw new NotSupportedError("age is read-only");
		}

		private function dateToAge(start:Date):Number
		{
			var now:Date = _currentDateSource.now();
			var nowMs:Number = now.getTime();
			var startMs:Number = start.getTime();
			var difference:Date = new Date(nowMs - startMs);
			return (difference.getFullYear() - 1970);
		}
    }
}
