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
import j2as3.collection.HashMap;

import mx.collections.ArrayList;
           
/**
* For OAuth request signing.
*/
public class SignRequest {

//    private static var serialVersionUID:Number= 1;
//    private var logger:Log= null;
//	private var nonceRandom:Random= null;
//
//    private var defaultMac:Mac= null;
//    private var defaultSecret:String= null;
//
//    private var base64:Base64= new Base64();
//
//    private var messageDigestSha1:MessageDigest= null;
//    
//    private var authhead:StringBuilder= null;
//    private var siglist:ArrayList = null;
//    private var prePercentEncoded:Boolean= false;
//
//    
////    /** construct an instance without a default consumer secret.
////    * convenience constructor for SignRequest(String encodedSecret)
////    */
////    public function SignRequest() {
////        this(null);
////    }
//
//    /**
//    * construct an instance with a default consumer secret.
//    * @param encodedSecret signRequest(....) will use this encodedSecret
//    * to generate the Mac key only, if the signRequest macSecret param is null.
//    * encodedSecret should be %encoded(consumerSecret) + '&'.
//    */
//    public function SignRequest(encodedSecret:String) {
//        logger = LogFactory.getLog(this.getClass());
//        if (encodedSecret != null) {
//            defaultMac = AuthUtils.makeMac(encodedSecret);
//            this.defaultSecret = encodedSecret;
//        }
//
////        try {
//            messageDigestSha1 = MessageDigest.getInstance("SHA-1");
////        } catch (nsae:NoSuchAlgorithmException) {
////            throw new GeneralSecurityException(nsae);
////        }
//
//        // use SecureRandom (more truly random) to generate a seed
//        // SecureRandom probably Uses System hardware to seed the randoms
//        // for nonce, use java.util.Random (Random has method to get an int
//        // in an arbitrary range)
//        var secureRandom:SecureRandom= SecureRandom.getInstance("SHA1PRNG");
//        var seed:Array= secureRandom.generateSeed(8);
//        // now turn the 8 bytes seed into one long primitive seed
//        var randomLong:Number= 0;
//        for (var ii:int= 0; ii < 8; ii++) {
//            // new rightmost 8 bits OR-ed in after left shift 8 bits
//            randomLong = (randomLong << 8) | (/*drop propogated sign bits*/ 255& seed[ii]);
//        }
//        nonceRandom = new Random(randomLong);
//    }
//
//    /** return 16 characters, each of the 16 chosen randomly from a set of 62
//    * displayable candidate characters (alphas upper and lower, and digits).
//    */
//    public function getNonce():String {
//        var sbn:StringBuilder= new StringBuilder();
//        // make 16 random base64 digits
//        for (var ii:int= 0; ii < 16; ii++) {
//            var ndig:int= nonceRandom.nextInt(62);
//            if (ndig < 26) {
//                sbn.append(char(('A' + ndig)));
//            } else if (ndig < 52) {
//                sbn.append(char(('a' + (ndig - 26))));
//            } else if (ndig < 62) {
//                sbn.append(char(('0' + (ndig - 52))));
//            }
//        }
//        return sbn.toString();
//    }
//
//
//    /**
//    * place oauth params in "Authenticate:" header, not elsewhere.
//    */
//    private function removeOAuthParam(required:Boolean, key:String, inmap:HashMap):String {
//        var retVal:String= null;
//        var value0:Array= inmap.remove(key);
//        if (value0 == null || value0[0] == null) {
//            if (required) {
//                throw new GeneralSecurityException("missing key in params: " + key);
//            }
//        } else {
//            retVal = value0[0];
//        }
//        
//        return retVal;
//    }
//
//    
//    /** place oauth params in both "Authentication:" header,
//    * and in the signature base string.
//    */
//    private function headAndSiglist(key:String, val0:String):void {
//        var val:String= val0;
//        if (! prePercentEncoded) {
//            val = AuthUtils.encode(val0);
//            if (key.equals("oauth_body_hash")) {
//                logger.info(key + ": " + val0 + "  --  " + val);
//            }
//        }
//        
//        if (authhead.length > 0) {
//            authhead.append(',');
//        }
//        authhead.append(key + "=\"" + val + "\"");
//        
//        var sigent:Array= new String[2];
//        sigent[0] = key; sigent[1] = val;
//        siglist.add(sigent);
//    }
//    
//    /** convenience method for signRequest(false, requestUrl, reqParams,
//    *        consumerSecret, tokenSecret, rMeth, null).
//    * @deprecated use signpost, see Nate for an example.
//    */
}
}