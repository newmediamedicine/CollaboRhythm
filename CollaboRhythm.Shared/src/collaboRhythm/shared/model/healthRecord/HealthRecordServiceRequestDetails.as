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
	}
}
