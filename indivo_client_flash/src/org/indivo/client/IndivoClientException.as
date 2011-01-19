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
package org.indivo.client {
public class IndivoClientException extends Error {
    private static var serialVersionUID:Number= 1;

    
//    public function IndivoClientException(thrwbl:Throwable) {
//        super(thrwbl);
//    }
    public function IndivoClientException(msg:String, thrwbl:Error = null) {
        super(msg, thrwbl);
    }
//    public function IndivoClientException(msg:String) {
//        super(msg);
//    }
}
}