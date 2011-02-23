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
import j2as3.collection.HashMap;

/**
* classes that implement this interface and have a full path name of "org.indivo.client.&lt;classname&gt;"
* can be tested for fidelity to wiki document REST interface using main method of org.indivo.client.TestClient.
*/
internal interface WikiTestable {
    function setTestMode(mode:int):HashMap;

/*
    int getTestMode();
    String[] altFlavorExtraParams();
    boolean threeLegged();
    boolean getDropRecord();

    PhaAdminUtils getAdminUtils();
*/
}
}