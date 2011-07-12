package collaboRhythm.shared.model.healthRecord
{

	import com.theory9.data.types.OrderedMap;

	public class HttpStatusCodeUtil
	{
		private var shortDescriptions:OrderedMap = new OrderedMap();

		public function HttpStatusCodeUtil()
		{
			shortDescriptions.addKeyValue(100, "Continue");
			shortDescriptions.addKeyValue(101, "Switching Protocols");
			shortDescriptions.addKeyValue(102, "Processing");
			shortDescriptions.addKeyValue(200, "OK");
			shortDescriptions.addKeyValue(201, "Created");
			shortDescriptions.addKeyValue(202, "Accepted");
			shortDescriptions.addKeyValue(203, "Non-Authoritative Information");
			shortDescriptions.addKeyValue(204, "No Content");
			shortDescriptions.addKeyValue(205, "Reset Content");
			shortDescriptions.addKeyValue(206, "Partial Content");
			shortDescriptions.addKeyValue(207, "Multi-Status");
			shortDescriptions.addKeyValue(208, "Already Reported");
//209-225   Unassigned
			shortDescriptions.addKeyValue(226, "IM Used");
//227-299   Unassigned
			shortDescriptions.addKeyValue(300, "Multiple Choices");
			shortDescriptions.addKeyValue(301, "Moved Permanently");
			shortDescriptions.addKeyValue(302, "Found");
			shortDescriptions.addKeyValue(303, "See Other");
			shortDescriptions.addKeyValue(304, "Not Modified");
			shortDescriptions.addKeyValue(305, "Use Proxy");
			shortDescriptions.addKeyValue(306, "Reserved");
			shortDescriptions.addKeyValue(307, "Temporary Redirect");
//308-399   Unassigned
			shortDescriptions.addKeyValue(400, "Bad Request");
			shortDescriptions.addKeyValue(401, "Unauthorized");
			shortDescriptions.addKeyValue(402, "Payment Required");
			shortDescriptions.addKeyValue(403, "Forbidden");
			shortDescriptions.addKeyValue(404, "Not Found");
			shortDescriptions.addKeyValue(405, "Method Not Allowed");
			shortDescriptions.addKeyValue(406, "Not Acceptable");
			shortDescriptions.addKeyValue(407, "Proxy Authentication Required");
			shortDescriptions.addKeyValue(408, "Request Timeout");
			shortDescriptions.addKeyValue(409, "Conflict");
			shortDescriptions.addKeyValue(410, "Gone");
			shortDescriptions.addKeyValue(411, "Length Required");
			shortDescriptions.addKeyValue(412, "Precondition Failed");
			shortDescriptions.addKeyValue(413, "Request Entity Too Large");
			shortDescriptions.addKeyValue(414, "Request-URI Too Long");
			shortDescriptions.addKeyValue(415, "Unsupported Media Type");
			shortDescriptions.addKeyValue(416, "Requested Range Not Satisfiable");
			shortDescriptions.addKeyValue(417, "Expectation Failed");
			shortDescriptions.addKeyValue(422, "Unprocessable Entity");
			shortDescriptions.addKeyValue(423, "Locked");
			shortDescriptions.addKeyValue(424, "Failed Dependency");
//425       Reserved for WebDAV advanced             [RFC2817]
//          collections expired proposal
			shortDescriptions.addKeyValue(426, "Upgrade Required");
//427-499   Unassigned
			shortDescriptions.addKeyValue(500, "Internal Server Error");
			shortDescriptions.addKeyValue(501, "Not Implemented");
			shortDescriptions.addKeyValue(502, "Bad Gateway");
			shortDescriptions.addKeyValue(503, "Service Unavailable");
			shortDescriptions.addKeyValue(504, "Gateway Timeout");
			shortDescriptions.addKeyValue(505, "HTTP Version Not Supported");
			shortDescriptions.addKeyValue(506, "Variant Also Negotiates (Experimental)");
			shortDescriptions.addKeyValue(507, "Insufficient Storage");
			shortDescriptions.addKeyValue(508, "Loop Detected");
//509       Unassigned
			shortDescriptions.addKeyValue(510, "Not Extended");
		}

		public function getShortDescription(code:int):String
		{
			if (shortDescriptions.arrayOfKeys.indexOf(code) != -1)
				return shortDescriptions.getValueByKey(code);
			else
				return null;
		}
	}
}
