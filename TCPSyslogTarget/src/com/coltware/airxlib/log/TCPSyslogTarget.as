/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 *
 */

package com.coltware.airxlib.log
{

	import com.brooksandrus.utils.ISO8601Util;

	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	import mx.core.mx_internal;
	import mx.logging.*;
	import mx.logging.targets.LineFormattedTarget;
	import mx.utils.StringUtil;

	use namespace mx_internal;

	public class TCPSyslogTarget extends LineFormattedTarget
	{
		private static const DEFAULT_SYSLOG_PORT:int = 1468;

		public static var LOG_LOCAL0:int = 16 << 3;
		public static var LOG_LOCAL1:int = 17 << 3;
		public static var LOG_LOCAL2:int = 18 << 3;
		public static var LOG_LOCAL3:int = 19 << 3;
		public static var LOG_LOCAL4:int = 20 << 3;
		public static var LOG_LOCAL5:int = 21 << 3;
		public static var LOG_LOCAL6:int = 22 << 3;
		public static var LOG_LOCAL7:int = 23 << 3;

		public static var LOG_EMERG:int = 0;
		public static var LOG_ALERT:int = 1;
		public static var LOG_CRIT:int = 2;
		public static var LOG_ERR:int = 3;
		public static var LOG_WARNING:int = 4;
		public static var LOG_NOTICE:int = 5;
		public static var LOG_INFO:int = 6;
		public static var LOG_DEBUG:int = 7;

		private var _host:String;
		private var _port:int;

		private var _socket:Socket;

		private var _facility:int = LOG_LOCAL1;
		private var _userName:String;

		private var _messages:Array;

		private var _timer:Timer;

		public function TCPSyslogTarget(host:String, port:int = DEFAULT_SYSLOG_PORT)
		{
			super();
			this._host = host;
			this._port = port;
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, socketConnectHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, socketIoErrorHandler);
			_socket.addEventListener(Event.CLOSE, socketCloseHandler);
			_messages = new Array();
			_timer = new Timer(1000, 0);
			_timer.addEventListener(TimerEvent.TIMER, _writelog);
		}

		private function socketConnectHandler(e:Event):void
		{
			_timer.start();
		}

		private function socketCloseHandler(e:Event):void
		{
			_timer.stop();
		}

		private function socketIoErrorHandler(e:IOErrorEvent):void
		{
			_timer.stop();
		}

		public function set facility(value:int):void
		{
			_facility = value;
		}

		public function set userName(value:String):void
		{
			_userName = value;
		}

		/*
		 *
		 * @private
		 *
		 */
		override public function logEvent(event:LogEvent):void
		{
			var prival:int;
			switch (event.level)
			{
				case LogEventLevel.FATAL:
					prival = _facility + LOG_CRIT;
					break;
				case LogEventLevel.ERROR:
					prival = _facility + LOG_ERR;
					break;
				case LogEventLevel.WARN:
					prival = _facility + LOG_WARNING;
					break;
				case LogEventLevel.INFO:
					prival = _facility + LOG_INFO;
					break;
				case LogEventLevel.DEBUG:
					prival = _facility + LOG_DEBUG;
					break;
			}

			var date:Date = new Date();
			var iso8601Util:ISO8601Util = new ISO8601Util();
			var timeStamp:String = "";
			if (includeDate && includeTime)
			{
				timeStamp = iso8601Util.formatExtendedDateTime(date) + fieldSeparator;
			}
			else if (includeDate)
			{
				timeStamp = iso8601Util.formatExtendedDate(date) + fieldSeparator;
			}
			else if (includeTime)
			{
				timeStamp = iso8601Util.formatExtendedTime(date) + fieldSeparator;
			}

			var userName:String = "";
			if (_userName)
			{
				userName = _userName + fieldSeparator;
			}

			var category:String = "";
			if (includeCategory)
			{
				category = ILogger(event.target).category + fieldSeparator;
			}

			internalLog("<" + prival + ">" + fieldSeparator + timeStamp + userName + category + event.message);
		}

		override mx_internal function internalLog(message:String):void
		{
			if (!_socket.connected)
			{
				_socket.connect(_host, _port);
			}
			_messages.push(message);
		}

		private function disconnectAuto():void
		{
			if (_messages.length == 0)
			{
				_timer.stop();
				_socket.close();
			}
		}

		private function _writelog(e:TimerEvent):void
		{
			var len:int = _messages.length;
			for (var i:int = 0; i < len; i++)
			{
				var msg:String = _messages.shift();
				msg = StringUtil.trim(msg);
				_socket.writeUTFBytes(msg + "\n");
				_socket.flush();
			}
			disconnectAuto();
		}
	}
}
