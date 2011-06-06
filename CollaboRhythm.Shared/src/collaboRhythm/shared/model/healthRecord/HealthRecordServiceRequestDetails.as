package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;

    public class HealthRecordServiceRequestDetails
    {
        private var _indivoApiCall:String;
        private var _account:Account;
        private var _record:Record;

		public function HealthRecordServiceRequestDetails(indivoApiCall:String=null, account:Account=null, record:Record=null)
		{
            _indivoApiCall = indivoApiCall;
            _account = account;
            _record = record;
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
    }
}
