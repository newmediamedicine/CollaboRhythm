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
package org.indivo.client {

/**
*  This is a class of dummy connections used to test REST clients without
*  having to connect them to an actual Indivo installation.
*/
//class TestClientFakeConnection extends URLRequest {
internal class TestClientFakeConnection {

    private var inputText:String= null;
    private var contentType:String= null;
    
    /** create a "connection" that will "receive" the given text */
    public function TestClientFakeConnection(inputText:String) {
//        super(null); // no URL really
        this.inputText = inputText;
    }

    public function disconnect():void {} // not a real connection anyway
    public function usingProxy():Boolean { return false; }  // not a real connection anyway
    public function connect():void {} // not a real connection anyway
    
//    public function getInputStream():InputStream {
//        var retVal:InputStream= new ByteArrayInputStream(inputText.getBytes());
//        return retVal;
//    }

    public function getContentType():String {
        return this.contentType;
    }
    
    internal function setContentType(contentType:String):void {
        this.contentType = contentType;
    }
    
}
}