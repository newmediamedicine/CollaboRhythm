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
import j2as3.collection.*;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.logging.*;
import mx.logging.targets.*;

import org.indivo.client.IndivoClientException;
import org.iotashan.utils.URLEncoding;


/**
*   Some utility methods for doing Indivo OAuth.
*/
public class AuthUtils {

	private static var logger:ILogger = Log.getLogger((Object(new AuthUtils())).getClass().getName());

//	private static function AuthUtils()
//	{
//		logger = Log.getLogger((Object(new AuthUtils())).getClass().getName());
//	}
	
//    /** strictly for testing */
//    public static function main(args:Array):void {
//        System.err.println("just testing AuthUtils");
//        var toEncode:String= "tilde:~~~~.";
//        var encoded:String= null;
//        try {
//            encoded = encode(toEncode);
//        } catch (gse:GeneralSecurityException) {
//            throw new RuntimeException(gse);
//        }
//        System.err.println(toEncode + "    " + encoded);
//    }

//    /**
//    * make a Mac object.
//    * @param encodedSecret should be the output of AuthUtils.encode(String)
//    *     or the '&' delimited concatenation of outputs of AuthUtils.encode(String)
//    * @return the Mac object
//    */
//    public static function makeMac(encodedSecret:String):HMAC {
//        logger.info("string for secret Mac key: " + encodedSecret);
//        //var mac:HMAC= HMAC.getInstance("HmacSHA1");
//		var mac:HMAC= Crypto.getHMAC("sha1");
//        var secretKey:Key= new SecretKeySpec(
//                (/*AuthUtils.encode(consumerSecret) + '&'*/ encodedSecret).getBytes(), "HmacSHA1" );
//        mac.init(secretKey);
//        return mac;
//    }


    
    /** RFC3986 unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"
    * @param plain the un-encoded string
    * @return the encoded string.
    */
    public static function encode(plain:String):String {
//        var sb:String = new String();
//        for (var ii:int= 0; ii < plain.length;ii++) {
//            var charat:String= plain.charAt(ii);
//            if ( (charat < 'a' || charat > 'z')
//                    && (charat < 'A' || charat > 'Z')
//                    && (charat < '0' || charat > '9')
//                    && charat != '-' && charat != '.' && charat != '_' && charat != '~' ) {
//                var hx:int= ((int(charat)) & 0x000000) / 16;
//                var lx:int= ((int(charat)) & 0x000000) % 16;
//                var hxc:String, lxc;
//                if (hx < 10) {
//                    hxc = char(('0' + hx));
//                } else {
//                    hxc = char(('A' + (hx -10)));
//                }
//    
//                if (lx < 10) {
//                    lxc = char(('0' + lx));
//                } else {
//                    lxc = char(('A' + (lx -10)));
//                }
//                
//                if ( ((hxc < '0' || hxc > '9') && (hxc < 'A' || hxc > 'F'))
//                     || ((lxc < '0' || lxc > '9') && (lxc < 'A' || lxc > 'F')) ) {
//                    throw new RuntimeException("" + ((int(charat)) & 0x000000) + "  hxc_lxc: " + hxc + lxc);
//                }
//                
//                sb.append('%'); sb.append(hxc); sb.append(lxc);
//            }
//            else {
//                sb.append(charat);
//            }
//        }
//        return sb.toString();
		return URLEncoding.encode(plain);
    }

    /** RFC3986 unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"
    * @param coded the encoded string
    * @return the decoded string.
    */
    public static function decode(coded:String):String {
//        var sb:StringBuilder= new StringBuilder();
//        for (var ii:int= 0; ii < coded.length; ii++) {
//            var decoded:String;
//            var charat:String= coded.charAt(ii);
//            if (charat == '%') {
//                if (ii > coded.length -3) {
//                    throw new GeneralSecurityException(
//                            "unexpected coded string, late %: " + coded);
//                }
//                try {
//                decoded = char((
//                        (hexDig(coded.charAt(ii +1)) * 16)
//                        + hexDig(coded.charAt(ii +2))  ));
//                } catch (gse:GeneralSecurityException) {
//                    throw new GeneralSecurityException(coded, gse);
//                }
//                ii += 2;
//            } else {
//                decoded = charat;
//            }
//            sb.append(decoded);
//        }
//        return sb.toString();
		return URLEncoding.decode(coded);
    }

//    private static function hexDig(dig:int):int {
//        if (dig >= '0' && dig <= '9') {
//            return dig - '0';
//        } else if (dig >= 'a' && dig <= 'f') {
//            return (dig - 'a') + 10;
//        } else if (dig >= 'A' && dig <= 'F') {
//            return (dig - 'A') + 10;
//        } else {
//            throw new GeneralSecurityException("unrecognized % code");
//        }
//    }
    
    /**
    * @param siglist a list of key,value pairs
    * (each pair represented by a String array of length 2)
    * return the values in the form of a String formatted for use in an OAuth signature
    * base String.  The caller is responsible for ommitting the 'realm' and 'signature'
    * parameters, as saListToAmpString simply sorts and concatenates all pairs.
    * @return string that can be used as the parameters portion of a signature base string.
    */
    public static function saListToAmpString(siglist:ArrayList):String {
        var auInst:AuthUtils= new AuthUtils();
        
//		String[][] tosort = siglist.toArray(new String[0][0]);
//		Arrays.sort(tosort, auInst);
		
		// TODO: verify that this sorting works; also note that siglist is being modified
		var tosort:ArrayList = siglist;
		//tosort.sort(compare);
		
		var dataSortField:SortField = new SortField();
		dataSortField.compareFunction = compareParams;
		
		var paramsListSort:Sort = new Sort();
		paramsListSort.fields = [dataSortField];
		
        //Arrays.sort(tosort, auInst);
        var sb:String= new String();
        for (var ii:int= 0; ii < tosort.length; ii++) {
            var fromsort:Array= tosort[ii];
            sb += fromsort[0] + '=' + fromsort[1];
            if (ii < tosort.length -1) {
                sb += '&';
            }
        }
        return sb.toString();
    }

	private static function compareParams(a:Object, b:Object, fields:Array = null):int
	{
		var aParam:Array = a as Array;
		var bParam:Array = b as Array;
		
		// return default comparison results on first element in array (param name)
		var s:Sort = new Sort();
		s.fields = fields;
		var f:Function = s.compareFunction;
		var retVal:int = f.call(null, aParam[0], bParam[0], fields);
		
		// if param names are the same, sort on param value
		if (retVal == 0)
		{
			retVal = f.call(null, aParam[1], bParam[1], fields);
		}
		return retVal;
	}
	
	
    /** Same as getStringFromPmap(...) except that if key is not present in map,
    * return null;
    * @param pmap parameter map
    * @param key key of the parameter who's value is to be returned
    * @return parameter value or, if parameter of given key not present, null
    */
    public static function optionalFromPmap(pmap:HashMap, key:String):String {
        var val:Array= pmap.get(key);
        if (val == null) {
            return null;
        } else {
            return getStringFromPmap(pmap, key);
        }
    }

    /**
    * In cases where a map, such as a parameter map, has values in the form of String[],
    * and you know a particular map key must be present, and you know there must be exactly
    * zero or one value for that key, this will return that value (or return null if
    * zero values for that key.  Key must be present even if there length of the value
    * array is 0.
    *
    * @param pmap parameter map
    * @param key key of the parameter who's value is to be returned
    * @return parameter value
    * @throws GeneralSecurityException if no parameter of given key
    *    is in the map, or if more than one parameter value for the given key.
    */    
    public static function getStringFromPmap(pmap:HashMap, key:String):String {
        var val:Array= pmap.get(key);
        if (val == null) {
            throw new IndivoClientException("pmap missing key: " + key);
        } else if (val.length > 1) {
            throw new IndivoClientException("pmap value array length > 1 for key: " + key);
        }
        
        if (val.length == 0) {
            return null;
        } else {
            return val[0];
        }
    }

      
//    /**
//    * This method not intended for application use, it is public in order to implement
//    * the Comparator interface.
//    *
//    * This method is meant to be used by Arrays.sort(...)
//    *
//    * From OAuth Spec:
//    * "parameters MUST be encoded as described in Parameter Encoding (Parameter Encoding)
//    * prior to constructing the Signature Base String."
//    *
//    * Not entirely clear, but seems that "prior" means before sorting, so that the sort
//    * should be based on the % encoded values, not on the order of the plain text values
//    */
//    public function compare(o1:Array, o2:Array):int {
//        var o1a:String= null, o1b = null, o2a = null, o2b = null;
//            // seems that "prior" means before sorting, don't decode, should test this!
//            o1a = /*decode(*/o1[0]/*)*/;
//            o1b = /*decode(*/o1[1]/*)*/;
//            o2a = /*decode(*/o2[0]/*)*/;
//            o2b = /*decode(*/o2[1]/*)*/;
//
//        var retVal:int= o1a.compareTo(o2a);
//        if (retVal == 0) {
//            retVal = o1b.compareTo(o2b);
//        }
//        return retVal;
//    }      
}
}