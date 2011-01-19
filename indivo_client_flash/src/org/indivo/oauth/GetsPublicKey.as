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
*  When using org.indivo.oauth.Authenticate, provide it with an object for getting
*  the consumer's public key.  Don't want public key access logic in Authenticate iteself
*  because users of Authenticate may have different ways of caching keys.
*/
public interface GetsPublicKey {
    
    /**
    * @param consumerKey value of oauth_consumer_key
    * @param keyName value of xoauth_signature_publickey
    * @param signatureMethod value of oauth_signature_method
    */
    function getPublicKey(consumerKey:String, keyName:String, signatureMethod:String):String /*
        FROM http://wiki.opensocial.org/index.php?title=Validating_Signed_Requests:
        Certificates should not be fetched each time you want to validate parameters - instead,
        implement a server side key cache indexed on the value of
        xoauth_signature_publickey, oauth_consumer_key, and oauth_signature_method.
        If these value change, you will need to pull a new certificate down
        and store it in your key cache. 
        */
            }
}