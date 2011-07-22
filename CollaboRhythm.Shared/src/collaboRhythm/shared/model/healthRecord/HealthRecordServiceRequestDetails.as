package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;

    public class HealthRecordServiceRequestDetails
    {
        private var _indivoApiCall:String;
        private var _account:Account;
        private var _record:Record;
		private var _report:String;
		private var _category:String;
		private var _failedAttempts:int = 0;
		private var _document:IDocument;
		private var _customData:Object;

		public function HealthRecordServiceRequestDetails(indivoApiCall:String=null, account:Account=null, record:Record=null, report:String=null, category:String=null)
		{
            _indivoApiCall = indivoApiCall;
            _account = account;
            _record = record;
			_report = report;
			_category = category;
		}

        public function get indivoApiCall():String
        {
            return _indivoApiCall;
        }

        public function get account():Account
        {
            return _account;
        }

        public function get record():Record
        {
            return _record;
        }

		/**
		 * Optionally specifies the report that was requested.
		 */
		public function get report():String
		{
			return _report;
		}

		/**
		 * Optionally specifies the category of report that was requested.
		 */
		public function get category():String
		{
			return _category;
		}

		public function get failedAttempts():int
		{
			return _failedAttempts;
		}

		public function set failedAttempts(value:int):void
		{
			_failedAttempts = value;
		}

		public function get document():IDocument
		{
			return _document;
		}

		public function set document(value:IDocument):void
		{
			_document = value;
		}

		public function get customData():Object
		{
			return _customData;
		}

		public function set customData(value:Object):void
		{
			_customData = value;
		}
	}
}
