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
package org.indivo.oauth {

import flash.utils.*;

import j2as3.collection.*;

import mx.logging.*;
import mx.logging.targets.*;


/**
*  Use this to ensure, via 2-legged OAuth, that a request comes from the
*  entity it says it comes from.
*/
public class Authenticate {

    private static var serialVersionUID:Number= 1;
	private static var logger:ILogger;

    /** keep track of latest request from each client to make sure timestamps are in sequence
    * and timstamp/nonce doesn't repeat
    */
    private var latestRequest:HashMap = new HashMap();

//    private var base64:Base64= new Base64();
//    private var signatureBaseString:oauth.signpost.signature.SignatureBaseString=
//            new oauth.signpost.signature.SignatureBaseString(null,null);

//    /** main method strictly for testing */
//    public static function main(args:Array):void {
//        var retVal:HashMap = new HashMap();
//        var authHead:String= "OAuth realm=\"http://OSX1189.local/\"," +
//            "oauth_consumer_key=\"1nd1v0K3y\"," +
//            "oauth_signature_method=\"HMAC-SHA1\"," +
//            "oauth_version=\"1.0\"," +
//            "oauth_timestamp=\"1247764232\"," +
//            "oauth_nonce=\"iBHJL1j3iX2rR04Y\"," +
//            "oauth_signature=\"Bu6z0a9wFhl2LKzV8cCP8ibqPas=\"";
//        var instance:Authenticate= new Authenticate();
//        try {
//            instance.getReqAndAuthorizParams0(retVal, authHead);
//        } catch (exe:Error) {
//            throw new RuntimeException(exe);
//        }
//        Iterator<String> keys = retVal.keySet().iterator();
//        while (keys.hasNext()) {
//            var akey:String= keys.next();
//            var aval:Array= retVal.get(akey);
//            System.out.print(akey + '=');
//            for (var ii:int= 0; ii < aval.length; ii++) {
//                System.out.print("   " + aval[ii]);
//            }
//            System.out.println("");
//        }
//    }
    
    public function Authenticate() {
		logger = Log.getLogger(getQualifiedClassName(this).split("::")[1]);
    }
    
//    /**
//    *  HMAC-SHA1 3-legged oauth authentication, final step of the dance,
//    *  where access token and secret are already known to the consumer (Can also be used
//    *  for 2-legged oauth (omit oauth_token from params and tokenSecret = null)
//    *  @param req HttpServletRequest from the Servlet doGet() or doPost()
//    *  @param consumerSecret consumer secret, as agreed to by service provider and consumer prior
//    *  to starting oauth process.
//    *  @param tokenSecret null if oauth_token not present in params and signature base string (two legged).
//    *  token secret would have been provided by service provider along with oauth_token.
//    *  @return true if authentication succeeds.
//    */
//    public function authenticate(req:HttpServletRequest, consumerSecret:String, tokenSecret:String):Boolean {
//        var retVal:Boolean= false;  // not authentic unless authenticated
//        var apmap:HashMap = getReqAndAuthorizParams(req);
//
//        var signatureMethod:String= AuthUtils.getStringFromPmap(apmap,"oauth_signature_method");
//
//        if (! signatureMethod.equals("HMAC-SHA1")) {
//            throw new GeneralSecurityException("expected 'oauth_signature_method' of 'HMAC-SHA1'");
//        }
//        var sbs:String= startAuthenticate(req, apmap);
//        logger.info("Authenticate.authenticate signature base string:\n" + sbs);
//        if (sbs != null) {
//            var oaSign:String= AuthUtils.getStringFromPmap(apmap, "oauth_signature");
//            var tokenPresent:Boolean= apmap.get("oauth_token") != null;
//            var macSecret:String= consumerSecret + '&';
//            if (tokenSecret != null) {
//                if (! tokenPresent) {
//                    throw new GeneralSecurityException(
//                            "token_secret present, but no oauth_token param");
//                }
//                macSecret += tokenSecret;
//            } else if (tokenPresent) {
//                throw new GeneralSecurityException(
//                        "token_secret abset, but oauth_token present");
//            }
//            
//            var mac:Mac= AuthUtils.makeMac(macSecret);
//            logger.info("makeMac(" + macSecret + ")");
//            
//            var signature:Array= mac.doFinal(sbs.getBytes());
//            var sig64:String= new String(base64.encode(signature));
//            retVal = oaSign.equals(sig64);
//        }
//        return retVal;
//    }
    
//    /**
//    *  2-legged oauth to ensure client is who he says he is, RSA flavor.
//    *
//    * @param req request being authenticated (the request param of the servlet
//    * doGet/doPost.... method.
//    * @param getsPublic An instance of a class that can get the public key.
//    * @return true if authenticated, or false if not
//    */
//    public function authenticate2(req:HttpServletRequest, getsPublic:GetsPublicKey):Boolean {
//        var retVal:Boolean= false;  // not authentic unless authenticated
//        var apmap:HashMap = getReqAndAuthorizParams(req);
//
//        var sbs:String= startAuthenticate(req, apmap); // return null if early problem detected
//        logger.info("sbs: " + sbs);
//        if (sbs != null) {
//            var signatureMethod:String= AuthUtils.getStringFromPmap(apmap,"oauth_signature_method");
//            var keyName:String= AuthUtils.getStringFromPmap(apmap, "xoauth_signature_publickey");
//            var oaSign:String= AuthUtils.getStringFromPmap(apmap, "oauth_signature");
//            var consumerKey:String= AuthUtils.getStringFromPmap(apmap,"oauth_consumer_key");
//            /*
//            FROM http://wiki.opensocial.org/index.php?title=Validating_Signed_Requests:
//    
//            Certificates should not be fetched each time you want
//            to validate parameters - instead,
//            implement a server side key cache indexed on the value of
//            xoauth_signature_publickey, oauth_consumer_key, and oauth_signature_method.
//            If these value change, you will need to pull a new certificate down
//            and store it in your key cache.
//            */
//            var key509:String=
//                    getsPublic.getPublicKey(consumerKey, keyName, signatureMethod);
//            retVal = validatePublicKey(key509, oaSign, sbs);
//            logger.info("signatureMethod, keyName, oaSign, consumerKey, PKValid<br/>key509: "
//                + signatureMethod + ", " + keyName + ", " + oaSign + ", " + consumerKey + ", " + retVal
//                + "\n" + key509);
//        }
//        return retVal;
//    }
    
//    /**
//    * Do some validation checks, then return signature base string for further validation.
//    * @param req http request object
//    * @return signature base string, or null if already known to be invalid.
//    */
//    private function startAuthenticate(req:HttpServletRequest, apmap:HashMap):String {
//        var sbs:String= null; // not authentic unless authenticated
//        
//        // oauth_version: OPTIONAL. If present, value MUST be 1.0
//        var versionOK:Boolean= false;
//        var oauthVersionA:Array=  apmap.get("oauth_version");
//        if (oauthVersionA != null) {
//            if (oauthVersionA.length != 1|| (! oauthVersionA[0].equals("1.0"))) {
//                var vstring:StringBuffer= new StringBuffer();
//                for (var ii:int= 0; ii < oauthVersionA.length; ii++) {
//                    vstring.append(oauthVersionA[ii]);
//                    if (ii < oauthVersionA.length -1) {
//                        vstring.append(", ");
//                    }
//                }
//                logger.warn("oauth_version != '1.0': " + vstring);
//            } else {
//                versionOK = true;
//            }
//        }
//
//        var timestampNonceOK:Boolean= false;
//        if (versionOK) {
//            var timestamp:String= AuthUtils.getStringFromPmap(apmap,"oauth_timestamp");
//            var nonce:String= AuthUtils.getStringFromPmap(apmap, "oauth_nonce");
//            var consumerKey:String= AuthUtils.getStringFromPmap(apmap,"oauth_consumer_key");
//            timestampNonceOK = validateTimestampNonce(consumerKey, timestamp, nonce);
//        }
//        
//        if (timestampNonceOK) {
//            logger.info("contextPath: " + req.getContextPath()
//                    + "  servletPath: " + req.getServletPath()
//                    + "  pathInfo: " + req.getPathInfo());
//
//            var requestUrl:String= getRequestUrl(req);
//            List<oauth.signpost.Parameter> signpostParams = paramsToSPParams(apmap);
//            var selectedReqParams:String= null;
//            try {
//                selectedReqParams = signatureBaseString.normalizeParameters(signpostParams);
//                logger.info("using signpost: " + selectedReqParams);
//                
//                getSelectedReqParams(apmap);
//            } catch (ioe:IOException) {
//                throw new GeneralSecurityException(ioe);
//            }
//            sbs = req.getMethod() + '&' +
//                    AuthUtils.encode(requestUrl) + '&'
//                    + AuthUtils.encode(selectedReqParams);
//        }
//
//        return sbs; // or null if request already known to be invalid
//    }
    
//    private function paramsToSPParams(pmap:HashMap):ArrayList {
//        var retVal:ArrayList = new ArrayList();
//		for (var akey:String in pmap.keys)
//		{
//			var vals:Array= pmap.get(akey);
//			for (var ii:int= 0; ii < vals.length; ii++) {
//				if (akey != "realm")) {
//					retVal.add(new oauth.signpost.Parameter(akey, vals[ii]));
//				}
//			}
//		}
//        return retVal;
//    }
    
//    /**
//    * The timestamp value MUST be a positive integer and MUST be equal or greater than the
//    * timestamp used in previous requests.
//    */
//    private function validateTimestampNonce(
//            consumerKey:String, oauth_timestamp:String, oauth_nonce:String):Boolean {
//        var timestamp:Number= 0;
//        var goodNumber:Boolean= true;
//        var current:Boolean= true;
//        var insequence:Boolean= true;
//        var unique:Boolean= true;
//        
//        try {
//            timestamp = Long.parseLong(oauth_timestamp) * 1000;
//        } catch (nfe:NumberFormatException) {
//            logger.warn("NumberFormatException when parsing timestamp: " + timestamp);
//            goodNumber = false;
//        }
//        
//        // also make sure this is reasonably close to NOW
//        var now:Number= new Date().getTime();
//        var min:Number= now - (5* 60* 1000); // 5 minutes
//        var max:Number= now + (5* 60* 1000); // 5 minutes
//        if (timestamp < min || max < timestamp) {
//            logger.warn("timestamp far from now. timestamp: " + timestamp + ", now: " + now);
//            current = false;
//        }
//        
//        // a bit unclear what "...used in previous requests" means. Here we assume
//        // this refers to previous requests from the same consumer
//        var lrts:Array= latestRequest.get(consumerKey);
//        if (lrts != null) {
//            var lastTS:Number= Long.parseLong(lrts[0]);
//            if (lastTS > timestamp) {
//                logger.warn("timestamp older than prior timestamp from same consumer. "
//                    + "consumer_key: " + consumerKey + ", prior timestamp: " + lrts
//                    + ", this timestamp: " + timestamp);
//                insequence = false;
//            } else if (lastTS == timestamp) {
//                // also unclear what "...unique for all requests with that timestamp." means
//                // assume unique for all requests from that consumer with that timestamp
//                if (lrts[1].equals(oauth_nonce)) {
//                    unique = false;
//                }
//            }
//        }
//        var lrts0:Array= new String[2];
//        lrts0[0] = oauth_timestamp;
//        lrts0[1] = oauth_nonce;
//        latestRequest.put(consumerKey, lrts0);
//        
//        if (goodNumber && current && insequence && unique) {
//            return true;
//        }
//        else {
//            return false;
//        }
//    }


//    /** use java.security package and the consumer's public key to authenticate
//    */
//    private function validatePublicKey(
//            key509:String,
//            oaSign:String,
//            sbs:String):Boolean {
//        var retVal:Boolean= false;
//            
//            var pkey:PublicKey= null;
//            
//            
//            // copied from net.oauth, THANKS!
//            var fac:CertificateFactory= CertificateFactory.getInstance("X509");
//            var inStream:ByteArrayInputStream= new ByteArrayInputStream(key509.getBytes());
//            var cert:X509Certificate= X509Certificate(fac.generateCertificate(inStream));
//            pkey = cert.getPublicKey();
//            // end copied from net.oauth
//
//            
//        var sha1withrsa:Signature= Signature.getInstance("SHA1withRSA");
//        sha1withrsa.initVerify(pkey);   // init with public key
//        sha1withrsa.update(sbs.getBytes());
//        retVal = sha1withrsa.verify(base64.decode(oaSign.getBytes()));
//        return retVal;
//    }

    
//    /**
//    * COPIED FROM: http://wiki.opensocial.org/index.php?title=Validating_Signed_Requests
//    * Constructs and returns the full URL associated with the passed request
//    * object.
//    * 
//    * @param  request Servlet request object with methods for retrieving the
//    *         various components of the request URL
//    */
//    public static function getRequestUrl(request:HttpServletRequest):String {
//        var requestUrl:StringBuilder= new StringBuilder();
//        var scheme:String= request.getScheme().toLowerCase();
//        var port:int= request.getLocalPort();
//    
//        requestUrl.append(scheme);
//        requestUrl.append("://");
//        requestUrl.append(request.getServerName().toLowerCase());
//    
//        if ((! (scheme.equals("http") && port == 80))
//            && (! (scheme.equals("https") && port != 443)) ) {
//          requestUrl.append(":");
//          requestUrl.append(port);
//        }
//    
//        requestUrl.append(request.getContextPath());
//        requestUrl.append(request.getServletPath());
//        var pathInfo:String= request.getPathInfo();
//        if (pathInfo != null) {
//            requestUrl.append(pathInfo);
//        }
//    
//        return requestUrl.toString();
//    }
      
                 
//    /**
//    * see "http://oauth.net/core/1.0"  section: "9.1.  Signature Base String"
//    *
//    * @param req request param from the HttpServelt doGet/doPost.... method.
//    * @return parameters portion of signature base string.
//    */
//    private function getReqAndAuthorizParams(req:HttpServletRequest):HashMap {
//        // get authorization header params first, excluding "realm"
//        var retVal:HashMap = new HashMap();
//
//        var authHeads:ArrayCollection = req.getHeaders("Authorization");
//        if (authHeads == null) {
//            throw new GeneralSecurityException("unable to access 'Authorization' header");
//        }
//        while (authHeads.hasMoreElements()) {
//            var authHead:String= authHeads.nextElement().trim();
//            getReqAndAuthorizParams0(retVal, authHead);
//        }
//
//          
//        // now get post body and get url params
//        var pmap:HashMap = req.getParameterMap();
//        Iterator<String> keys = pmap.keySet().iterator();
//        while (keys.hasNext()) {
//            var key:String= keys.next();
//            var valueA:Array= pmap.get(key);
//            for (var ii:int= 0; ii < valueA.length; ii++) {
//                addToMapStringStringA(retVal, key,valueA[ii]);
//            }
//        }
//        
//        return retVal;
//    }


//    /**
//    * mutate retVal
//    */
//    private function getReqAndAuthorizParams0(retVal:HashMap, authHead:String):void {
//        if (authHead.startsWith("OAuth ")) {
//            logger.info("authHead: " + authHead);
//            var oahWork:String= authHead.substring(6).trim();  // skip over 'OAuth'
//            while (oahWork.length > 0) {
//                var eix:int= oahWork.indexOf('=');
//                if (eix == -1) {
//                    throw new GeneralSecurityException(
//                        "unexpected Authorization header format:" + oahWork);
//                }
//                var key:String= oahWork.substring(0, eix);
//                var tail:String= oahWork.substring(eix +1);
//                if (tail.charAt(0) != '"') {
//                    throw new GeneralSecurityException(
//                            "Authorization header value not quoted: " + oahWork);
//                }
//                var qix:int= tail.indexOf('"', 1);
//                if (qix == -1) {
//                    throw new GeneralSecurityException("close quote not found: " + oahWork);
//                }
//                var value:String= tail.substring(1, qix);
//                addToMapStringStringA(retVal, key,value);
//                oahWork = tail.substring(qix +1).trim();
//                if (oahWork.length > 0&& oahWork.charAt(0) == ',') {
//                    oahWork = oahWork.substring(1).trim();
//                    if (oahWork.length == 0) {
//                        throw new GeneralSecurityException("trailing comma in OAuth header");
//                    }
//                } else if (oahWork.length > 0) {
//                    throw new GeneralSecurityException("missing delimiter: " + oahWork);
//                }
//            }
//        }
//    }


    private function getSelectedReqParams(apmap:HashMap):String {
        var siglist:ArrayList = new ArrayList();
        for (var key:String in apmap.keys) 
		{
            if (! (key == "realm" || key == "oauth_signature") ) {
                var valueA:Array= apmap.get(key);
                for (var ii:int= 0; ii < valueA.length; ii++) {
                    var sla:Array= new String[2];
                    sla[0] = AuthUtils.encode(key); sla[1] = AuthUtils.encode(valueA[ii]);
                    siglist.addItem(sla);
                    logger.info("selected req param: " + sla[0] + '=' + sla[1]);
                }
            }
        }
        logger.info("alternate SBS: " + AuthUtils.saListToAmpString(siglist));
        return AuthUtils.saListToAmpString(siglist);
    }
    
    private function addToMapStringStringA(toMutate:HashMap, key:String, value:String):void {
        var oldVal:Array= toMutate.get(key);
        var newVal:Array= null;
        if (oldVal != null) {
            newVal = new String[oldVal.length +1];
            for (var ii:int= 0; ii < oldVal.length; ii++) {
                newVal[ii] = oldVal[ii];
            }
            newVal[oldVal.length] = value;
        } else {
            newVal = new String[1];
            newVal[0] = value;
        }
        toMutate.put(key, newVal);            
    }
}
}