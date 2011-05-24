/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model.healthRecord
{
import collaboRhythm.shared.model.services.ICurrentDateSource;
import collaboRhythm.shared.model.services.WorkstationKernel;

import flash.events.EventDispatcher;
import flash.net.URLRequestMethod;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

import org.indivo.client.IndivoClientEvent;

[Event(name="complete", type="org.indivo.client.IndivoClientEvent")]

public class HealthRecordServiceSimpleBase extends EventDispatcher
{
    private var _oauthConsumerKey:String;
    private var _oauthConsumerSecret:String;
    private var _indivoServerBaseURL:String;
    protected var _currentDateSource:ICurrentDateSource;

    protected var logger:ILogger;

    public function HealthRecordServiceSimpleBase(oauthConsumerKey:String, oauthConsumerSecret:String, indivoServerBaseURL:String)
    {
        logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

        _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

        _oauthConsumerKey = oauthConsumerKey;
        _oauthConsumerSecret = oauthConsumerSecret;
        _indivoServerBaseURL = indivoServerBaseURL;
    }

    public function get oauthConsumerKey():String
    {
        return _oauthConsumerKey;
    }

    public function set oauthConsumerKey(value:String):void
    {
        _oauthConsumerKey = value;
    }

    public function get oauthConsumerSecret():String
    {
        return _oauthConsumerSecret;
    }

    public function set oauthConsumerSecret(value:String):void
    {
        _oauthConsumerSecret = value;
    }

    public function get indivoServerBaseURL():String
    {
        return _indivoServerBaseURL;
    }

    protected function indivoClientEventHandler(event:IndivoClientEvent):void
    {
//			_pha.removeEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
//			_pha.removeEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler);

        if (event.type == IndivoClientEvent.COMPLETE)
        {
            // TODO: what if the request was a POST
            if (event.urlRequest.method == URLRequestMethod.POST)
            {
            }

            var responseXml:XML = event.response;
            var fixedString:String = event.response.toXMLString().split("xmlns=").join("junk=");
            responseXml = new XML(fixedString);

            // TODO: what if responseXml is null
            if (responseXml != null)
            {
                handleResponse(event, responseXml);
            }
        }
        else
        {
            var innerError:XMLList = event.response.InnerError;
            var errorStatus:String;

            if (innerError != null)
            {
                errorStatus = innerError.text;
            }
            else
            {
                errorStatus = "Unhandled error occurred."
            }

            handleError(event, errorStatus);
        }
    }

    /**
     * Virtual method which subclasses should override in order to handle the asynchronous response to a request.
     *
     * @param event
     * @param responseXml
     *
     */
    protected function handleResponse(event:IndivoClientEvent, responseXml:XML):void
    {
        // Base class does nothing. Subclasses should override.
    }

    /**
     * Virtual method which subclasses should override in order to handle the asynchronous error response to a request.
     *
     * @param event
     *
     */
    protected function handleError(event:IndivoClientEvent, errorStatus:String):void
    {
        logger.info("Unhandled IndivoClientEvent error: " + errorStatus);
    }

    // TODO: Detemine why there are two date parsing functions
    /**
     * Simple parsing function to convert the date strings in our dataset to the equivalent Date object.
     */
    public function dateParse(value:String):Date
    {
        var dateArray:Array = value.split('-');
        return new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);
    }

    /**
     * Parses an Indivo date in the format "YYYY-MM-DD".
     * @param str
     * @return The corresponding date, if str is non-null; otherwise null.
     */
    public static function parseDate( str : String ) : Date
    {
        if (str != null && str.length > 0)
        {
            var matches : Array = str.match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
            // TODO: avoid using the current time
            var d : Date = new Date();

            d.setUTCFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
            return d;
        }
        else
            return null;
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