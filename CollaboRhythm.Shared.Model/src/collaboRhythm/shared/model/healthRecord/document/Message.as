package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	[Bindable]
	public class
	Message extends DocumentBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#Message";

		public static const INBOX:String = "Inbox";
		public static const SENT:String = "Sent";

		private var _id:String;
		private var _sender:String;
		private var _recipient:String;
		private var _received_at:Date;
		private var _read_at:Date;
		private var _subject:String;
		private var _body:String;
		private var _severity:String;
		private var _record_id:String;
		private var _attachment:Attachment;
		private var _type:String;
		private var _localStatus:String;

		public function Message()
		{
			meta.type = DOCUMENT_TYPE;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get sender():String
		{
			return _sender;
		}

		public function set sender(value:String):void
		{
			_sender = value;
		}

		public function get received_at():Date
		{
			return _received_at;
		}

		public function set received_at(value:Date):void
		{
			_received_at = value;
		}

		public function get read_at():Date
		{
			return _read_at;
		}

		public function set read_at(value:Date):void
		{
			_read_at = value;
		}

		public function get subject():String
		{
			return _subject;
		}

		public function set subject(value:String):void
		{
			_subject = value;
		}

		public function get severity():String
		{
			return _severity;
		}

		public function set severity(value:String):void
		{
			_severity = value;
		}

		public function get record_id():String
		{
			return _record_id;
		}

		public function set record_id(value:String):void
		{
			_record_id = value;
		}

		public function get attachment():Attachment
		{
			return _attachment;
		}

		public function set attachment(value:Attachment):void
		{
			_attachment = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get body():String
		{
			return _body;
		}

		public function set body(value:String):void
		{
			_body = value;
		}

		public function get recipient():String
		{
			return _recipient;
		}

		public function set recipient(value:String):void
		{
			_recipient = value;
		}

		public function get localStatus():String
		{
			return _localStatus;
		}

		public function set localStatus(value:String):void
		{
			_localStatus = value;
		}
	}
}
