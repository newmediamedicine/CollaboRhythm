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