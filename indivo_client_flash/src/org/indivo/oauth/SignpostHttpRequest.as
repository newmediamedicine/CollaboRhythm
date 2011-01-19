/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.indivo.oauth {

/**
* HttpRequestAdapter returns null from its getMessagePayload().
* use this if payload has params that need to go in the signature base string.
*/
//public class SignpostHttpRequest extends HttpRequestAdapter {
public class SignpostHttpRequest {
//    
//    private var payload:String= null;
//
//    /**
//    * @param connection same as for super class constructor.
//    * @param payload the form encoded params.  This class does nothing to
//    *    actually send the payload, just allows its contents to be included
//    *    in building the signature base string.  You must still send the payload
//    *    after signing the request.
//    */
//    public function SignpostHttpRequest(connection:URLRequest, payload:String) {
//        super(connection);
//        this.payload = payload;
//    }
//    
//    /** overrides getMessagePayload() of HttpRequestAdapter */
//    public function getMessagePayload():java.io.InputStream {
//        return new ByteArrayInputStream(payload.getBytes());
//    }
}
}