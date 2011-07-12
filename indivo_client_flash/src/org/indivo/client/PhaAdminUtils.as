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
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.utils.*;

import j2as3.collection.HashMap;

import mx.logging.*;
import mx.logging.targets.*;
import mx.utils.URLUtil;

import org.iotashan.oauth.OAuthConsumer;
import org.iotashan.oauth.OAuthRequest;
import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
import org.iotashan.oauth.OAuthToken;

public class PhaAdminUtils {
    private var specialBugWorkaround:Boolean= false; // for MessageQueue bug discovered Nov 12 '09
    
	private static var logger:ILogger;
    
    internal var defaultConsumerKey:String= null;
    internal var defaultConsumerSecret:String= null;
    
//    private var documentBuilderFactory:DocumentBuilderFactory= null;
//    private var documentBuilder:DocumentBuilder= null;

    
//    public function PhaAdminUtils() {
//        logger = LogFactory.getLog(this.getClass());
//        documentBuilderFactory = DocumentBuilderFactory.newInstance();
//        try {
//            documentBuilder = documentBuilderFactory.newDocumentBuilder();
//        } catch (pce:javax.xml.parsers.ParserConfigurationException) {
//            throw new IndivoClientException(pce);
//        }
//    }

    public function PhaAdminUtils(defaultConsumerKey:String, defaultConsumerSecret:String)
	{
		logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
//		documentBuilderFactory = DocumentBuilderFactory.newInstance();
//		try {
//			documentBuilder = documentBuilderFactory.newDocumentBuilder();
//		} catch (pce:javax.xml.parsers.ParserConfigurationException) {
//			throw new IndivoClientException(pce);
//		}
        this.defaultConsumerKey = defaultConsumerKey;
        this.defaultConsumerSecret = defaultConsumerSecret;
    }

    /** for use with clients that implement WikiTestable */
    private var testMode:int= 0;
    /** for use with clients that implement WikiTestable */
    internal function setTestMode(tm:int):void { testMode = tm; }
    /** for use with clients that implement WikiTestable */
    internal function getTestMode():int { return testMode; }
    
    /**
    * @param reqMethodStr GET, POST or etc.
    * @param adminURLString for example: http://localhost:80/myApp
    * @param queryString do not include the leading '?', for example: "abc=def&ghi=jkl"
    * @param signParams all params not in query string
    * @param contentType for example: "text/plain"
    * @return an URLRequest, not yet connected.
    */
    public function setupConnection(
            reqMethodStr:String,
            adminURLString:String,
            queryString:String,
            signParams:HashMap,
            contentType:String):URLRequest
	{
        if (queryString == null)
		{
            queryString = "";
        }
		else if (queryString.length > 0)
		{
            queryString = "?" + queryString;
        }
        var queryStringBuff:String = new String(queryString);
        if (signParams != null) {
            for (var akey:String in signParams.keys)
			{
                var vals:Array= signParams.get(akey);
                for (var ii:int= 0; ii < vals.length; ii++) {
                    if (queryStringBuff.length == 0) {
                        queryStringBuff += '?';
                    } else {
                        queryStringBuff += '&';
                    }
                    queryStringBuff += akey + '=' + vals[ii];
                }
            }
        }
        
//        var adminURL:String= null;
        var urlRequest:URLRequest= null;

		adminURLString = adminURLString + queryStringBuff.toString();
        urlRequest = new URLRequest(adminURLString);
        urlRequest.method = reqMethodStr;
		
		urlRequest.contentType = contentType;
//		urlRequest.data = queryString;
        
        if (contentType == null || contentType.length == 0) {
            urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type", "text/plain"));
        } else {
//            urlRequest.setDoOutput(true);
            urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type", contentType /*"application/xml"*/));
        }
//        urlRequest.requestHeaders.push(new URLRequestHeader("Accept", "text/plain"));      // don't be mistaken for a browser
//        urlRequest.requestHeaders.push(new URLRequestHeader("Accept", "application/xml")); // don't be mistaken for a browser

        return urlRequest;
    }

	public function signWithSignpost(
		urlRequest:URLRequest,
		consumerKey0:String,
		consumerSecret0:String,
		accessToken:String,
		accessTokenSecret:String):void {
		
		var consumerKey:String= null;
		var consumerSecret:String= null;
		if (consumerKey0 == null) {
			consumerKey = defaultConsumerKey;
			consumerSecret = defaultConsumerSecret;
		} else {
			consumerKey = consumerKey0;
			consumerSecret = consumerSecret0;
		}
		
		//         var oauthConsumer:OAuthConsumer= new DefaultOAuthConsumer(
		//                consumerKey, consumerSecret, SignatureMethod.HMAC_SHA1);
		//    
		//         var httpRequest:HttpRequest= new HttpRequestAdapter(urlRequest);
		//         oauthConsumer.setTokenWithSecret(accessToken, accessTokenSecret);
		//         try {
		//             oauthConsumer.sign(httpRequest);
		//         } catch (omse:OAuthMessageSignerException) {
		//             throw new IndivoClientException(omse);
		//         } catch (oefe:OAuthExpectationFailedException) {
		//             throw new IndivoClientException(oefe);
		//         }
		
//		var oauthConsumer:OAuthConsumer = new OAuthConsumer(consumerKey, consumerSecret);
//		var oauthToken:OAuthToken = new OAuthToken(accessToken, accessTokenSecret);
//		var oauthRequest:OAuthRequest = new OAuthRequest(urlRequest.method, urlRequest.url, urlRequest.data, oauthConsumer, oauthToken);
//		var requestHeader:URLRequestHeader = oauthRequest.buildRequest(new OAuthSignatureMethod_HMAC_SHA1(), OAuthRequest.RESULT_TYPE_HEADER);
//		
//		urlRequest.requestHeaders.push(requestHeader);
		
		
		var oauthConsumer:OAuthConsumer = new OAuthConsumer(consumerKey, consumerSecret);
		
		var requestUrl:String;
		var queryString:String;
		
		if (urlRequest.url.indexOf("?") >= 0)
		{
			if (urlRequest.method != "GET")
				throw new ArgumentError("urlRequest.method is GET and urlRequest.url contains a ? character and thus appears to be invalid");
			
			var requestParts:Array = urlRequest.url.split("?");
			requestUrl = requestParts[0];
			queryString = requestParts[1];
		}
		else
		{
			requestUrl = urlRequest.url;
			if (urlRequest.data != null && urlRequest.contentType == "application/x-www-form-urlencoded")
				queryString = urlRequest.data.toString();
		}
		
		var requestParams:Object;
		if (queryString != null && queryString.length > 0)
			requestParams = URLUtil.stringToObject(queryString, "&");
		
		var oauthToken:OAuthToken;
		if (accessToken != null && accessToken.length > 0)
			oauthToken = new OAuthToken(accessToken, accessTokenSecret);
			
		var oauthRequest:OAuthRequest = new OAuthRequest(urlRequest.method, requestUrl, requestParams, oauthConsumer, oauthToken);
		var requestHeader:URLRequestHeader = oauthRequest.buildRequest(new OAuthSignatureMethod_HMAC_SHA1(), OAuthRequest.RESULT_TYPE_HEADER);
		
		urlRequest.requestHeaders.push(requestHeader);
	}
	
	public function prepareRequest(urlRequest:URLRequest, requestBody:String):void
	{
		if (requestBody != null && requestBody.length > 0)
			urlRequest.data = requestBody;
//		else
//			urlRequest.data = null;
	}
	
//    /**
//    *
//    * This connects the connection and sends the request body, any response
//    * from the server is left unread.
//    *
//    * @param urlRequest connection to be connected
//    * @param requestBody body of date to be sent over the connection
//    */
//    public function connectConnection(urlRequest:URLRequest, requestBody:String):void {
//        try {
//            connectConnection0(urlRequest, requestBody);
//        } catch (ioe:IOException) {
//            throw new IndivoClientException(ioe);
//        }
//    }
//
//    private function connectConnection0(urlRequest:URLRequest, requestBody:String):void {
//        logger.info("about to connect: " + urlRequest);
//        urlRequest.connect();
//        logger.info("did connect: " + urlRequest);
//        if (requestBody != null && requestBody.length > 0) {
//            var os:OutputStream= urlRequest.getOutputStream();
//            
//            os.write(requestBody.getBytes());
//            logger.info("requestBody: " + requestBody);
//            os.close();
//        }
//        var cnctnResponseCode:int= 0;
//        try {
//            cnctnResponseCode = urlRequest.getResponseCode();
//            logger.info("sendRequest connection response code: " + cnctnResponseCode);
//        } catch (ioe:IOException) {
//            logger.info("in PhaAdminUtils.java", ioe);
//        }
//        
//        var errStr:InputStream= urlRequest.getErrorStream();
//        var sb:StringBuilder= new StringBuilder();
//        var cc:int= 0;
//        if (errStr != null) {
//            cc = errStr.read();
//            while (cc != -1) {
//                sb.append(char(cc));
//                cc = errStr.read();
//            }
//            logger.info("error from Indivo: " + sb.toString());
//        }
//        if (cnctnResponseCode != 200) {
//            var cnctnIS:InputStream= null;
//            try {
//                cnctnIS = urlRequest.getInputStream();
//            } catch (not200fnfe:java.io.FileNotFoundException) {
//                logger.info("after non-200", not200fnfe);
//            }
//            if (cnctnIS != null) {
//                logStream("non 200 response body: ", cnctnIS);
//            }
//            
//            if (cnctnResponseCode == 404) {
//                throw new IndivoClientExceptionHttp404("response code from indivo not 200. "
//                        + cnctnResponseCode + " - " + urlRequest.getResponseMessage());
//            } else {
//                throw new IndivoClientException("response code from indivo not 200. "
//                        + cnctnResponseCode + " - " + urlRequest.getResponseMessage());
//            }
//        }
//    }

    //public boolean ttt = false;    
//    /**
//    * given a connected URLRequest over which the request body has already been sent
//    * (see connectConnection) read the server's response and return that response in the
//    * form of an XML Document.
//    */
//    public function docFromConnection(urlRequest:URLRequest):XML {
//        var docForContent:XML= null;
//        var contentType:String= urlRequest.contentType;
//            
//        var fromCnctn:String= dataFromConnection(urlRequest);
//
//        if (contentType != "application/xml") {
//            logger.info("NOT application/xml content: " + fromCnctn);
//            throw new IndivoClientException(
//                    "response content type from indivo not 'application/xml'. "
//                    + contentType);
//        }
//
//        var bais:ByteArrayInputStream= new ByteArrayInputStream(fromCnctn.getBytes());
//        
////                    bais = (xstr.getBytes());
//        
//        try { // get the content
////			synchronized(documentBuilder) {
//                docForContent = documentBuilder.parse(bais);
////            }
//        } catch (sxe:org.xml.sax.SAXException) {
//            logger.error("\n" +  fromCnctn + "\nnot xml parsable stream");
//            throw new IndivoClientException(sxe);
//        } catch (ioe:IOException) {
//            throw new IndivoClientException(ioe);
//        }
//        var docElem:Element= docForContent.getDocumentElement();
//        logger.info("docElem tag name: " + docElem.getTagName());
//        
//        return docForContent;
//    }
//    
//    function dataFromConnection(urlRequest:URLRequest):String {
//        var indivoContent:Object= null;
//        var bais:ByteArrayInputStream= null; 
//        var xstr:String= null;
//        try {
//            indivoContent = urlRequest.getContent();
//            logger.info("getContent() returned an: " + indivoContent.getClass().getName());
//            if ( !(indivoContent is InputStream)) {
//                throw new IndivoClientException(urlRequest.getURL().toString() + " returned value not "
//                    + " InputStream as expected, was: " + indivoContent.getClass().getName());
//            } else {
//                var icIS:InputStream= InputStream(indivoContent);
//                logger.info("indivoContent is an InputStreamm");
//                    var xcc:int= icIS.read();
//                    var xstrb:StringBuffer= new StringBuffer();
//                    var unexpectedBuffer:StringBuffer= new StringBuffer();
//                    while (xcc != -1) {
//                unexpectedBuffer.append("" + char(xcc));
//                unexpectedBuffer.append(" " + xcc + "   ");
//                        xstrb.append(char(xcc));
//                        xcc = icIS.read();
//                    }
//                    xstr = xstrb.toString();
//                    
//                    // indivo bug workaround
//                    if (xstr.startsWith("<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n<")) {
//                        xstrb.replace(34,36,"8");
//                        logger.warn("replacing " + xstr.substring(0,50) + " with " + xstrb.substring(0,49));
//                        xstr = xstrb.toString();
//                    }
//                    
//                    
//                    logger.info("might have unexpected char: " + unexpectedBuffer);
//                
//            }
//        
//        } catch (ioe:java.io.IOException) {
//            if (urlRequest != null) {
//                var errStr2:InputStream= urlRequest.getErrorStream();
//                if (errStr2 != null) {
//                    var sb2:StringBuilder= new StringBuilder();
//                    try {
//                        var cc2:int= errStr2.read();
//                        while (cc2 != -1) {
//                            sb2.append(char(cc2));
//                            cc2 = errStr2.read();
//                        }
//                    } catch (ioe2:java.io.IOException) {
//                        throw new RuntimeException(ioe2);
//                    }
//                    logger.info("error 2 from Indivo: " + sb2.toString());
//                }
//            }
//            throw new IndivoClientException(ioe);
//        }
//        
//        return xstr;
//    }

    public function docFromResponse(data:String):XML {
        var indivoContent:Object= null;

        indivoContent = data;
//        logger.info("URLLoader returned class: " + indivoContent.getClass().getName());
//            if ( !(indivoContent is InputStream)) {
//                throw new IndivoClientException(urlRequest.getURL().toString() + " returned value not "
//                    + " InputStream as expected, was: " + indivoContent.getClass().getName());
//            } else {

		var xstr:String = data;
		
		// indivo bug workaround
		var utfBug:String = "<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n<";
		var utfFix:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<";
        if (xstr.substr(0, utfBug.length) == utfBug) {
			var xstrb:String = new String(xstr);
            xstrb.replace(utfBug, utfFix);
            logger.warn("replacing " + utfBug + " with " + utfFix);
            xstr = xstrb;
        }

		try
		{
			return new XML(xstr);
		} catch(e:Error)
		{
			logger.error("Failed to parse response as XML: " + xstr);
		}
		return null;
    }
	
	
//    /**
//    * Use this to post a request that expects a text/plain response. no formEncoded params in body.
//    */
//    public function postRequestForString(
//            oauthConsumerKey:String,
//            consumerSecret:String,
//            token:String,
//            tokenSecret:String,
//            adminURLString:String,
//            signParams:HashMap):String {
//        return postRequestForString(
//            oauthConsumerKey, consumerSecret, token, tokenSecret, adminURLString, signParams, null);
//    }

//    /**
//    * Use this to post a request that expects a text/plain response.
//    */
//    public function postRequestForString(
//            oauthConsumerKey:String,
//            consumerSecret:String,
//            token:String,
//            tokenSecret:String,
//            adminURLString:String,
//            signParams:HashMap,
//            formEncoded:String):String {
//        var contentType:String= null;
//        if (formEncoded != null && formEncoded.length > 0) {
//            contentType = "application/x-www-form-urlencoded";
//        }
//        var urlRequest:URLRequest= setupConnection("POST", adminURLString, "", signParams, contentType);
//        var httpRequest:HttpRequest= new SignpostHttpRequest(urlRequest, formEncoded);
//        var consumerKey0:String= oauthConsumerKey;
//        var consumerSecret0:String= consumerSecret;
//        if (consumerKey0 == null) {
//            consumerKey0 = defaultConsumerKey;
//            consumerSecret0 = defaultConsumerSecret;
//        }
//        var oauthConsumer:OAuthConsumer=
//                new DefaultOAuthConsumer(consumerKey0, consumerSecret0, SignatureMethod.HMAC_SHA1);
//        if (token == null) {
//            oauthConsumer.setTokenWithSecret(null, "");
//        } else {
//            oauthConsumer.setTokenWithSecret(token, tokenSecret);
//        }
//        logger.info("about to sign -- consumerKey, consumerSecret, token, tokenSecret: " +
//                consumerKey0 + ", " + consumerSecret0 + ", " + token +  ", " + tokenSecret);
//        try {
//            oauthConsumer.sign(httpRequest);
//        } catch (omse:OAuthMessageSignerException) {
//            throw new IndivoClientException(omse);
//        } catch (oefe:OAuthExpectationFailedException) {
//            throw new IndivoClientException(oefe);
//        }
////        connectConnection(urlRequest, formEncoded);
//		prepareRequest(urlRequest, formEncoded);
//        return processIndivoResultPlain(urlRequest);
//    }
//    
//    /**
//    * Use this to post a request that expects a text/plain response when there is no
//    * tokenSecret (2-legged).
//    */
//    public function postRequestForString2(
//            oauthConsumerKey:String,
//            consumerSecret:String,
//            adminURLString:String,
//            signParams:HashMap):String {
//        var urlRequest:URLRequest= setupConnection(
//                "POST", adminURLString, "", signParams, null);
//        var httpRequest:HttpRequest= new HttpRequestAdapter(urlRequest);
//        var oauthConsumer:OAuthConsumer=
//                new DefaultOAuthConsumer(oauthConsumerKey, consumerSecret, SignatureMethod.HMAC_SHA1);
//        oauthConsumer.setTokenWithSecret(null, "");
//        try {
//            oauthConsumer.sign(httpRequest);
//        } catch (omse:OAuthMessageSignerException) {
//            throw new IndivoClientException(omse);
//        } catch (oefe:OAuthExpectationFailedException) {
//            throw new IndivoClientException(oefe);
//        }
//        return processIndivoResultPlain(urlRequest);
//    }
//
//    /**
//    *  Use this to post a request if the org.indivo.client.Http instance
//    *  was created with a consumer key and secret, and there is no
//    *  token secret (2-legged).
//    */
//    public function postRequestForString3(adminURLString:String, signParams:HashMap):String {
//        if (this.defaultConsumerKey == null) {
//            throw new IndivoClientException("cannot use this method with an "
//                    + "org.indivo.client.Http instance constructed "
//                    + "without a oauthConsumerKey");
//        }
//        var urlRequest:URLRequest= setupConnection(
//                "POST", adminURLString,  "", signParams, null);
//        var oauthConsumer:OAuthConsumer=
//                new DefaultOAuthConsumer(defaultConsumerKey, defaultConsumerSecret, SignatureMethod.HMAC_SHA1);
//        oauthConsumer.setTokenWithSecret(null, "");
//        var httpRequest:HttpRequest= new HttpRequestAdapter(urlRequest);
//        try {
//            oauthConsumer.sign(httpRequest);
//        } catch (omse:OAuthMessageSignerException) {
//            throw new IndivoClientException(omse);
//        } catch (oefe:OAuthExpectationFailedException) {
//            throw new IndivoClientException(oefe);
//        }
//        return processIndivoResultPlain(urlRequest);
//    }

    
    
    
    
    
//    /**
//    *  given a connection, return the String of the body of
//    *  the response from that connection.
//    *  @param urlRequest connection to which the request body has already been
//    *     sent.
//    */
//    public function processIndivoResultPlain(urlRequest:URLRequest):String {
//        if (this.getTestMode() == 1) {
//            //((TestClientFakeConnection) urlRequest).setContentType("application/x-www-form-urlencoded");
//            (TestClientFakeConnection(urlRequest)).setContentType("text/plain");
//        }
//        var contentType:String= urlRequest.getContentType();
//        var indivoContent:Object= null;
//        try {
//            indivoContent = urlRequest.getContent();
//        } catch (ioe:IOException) {
//            throw new IndivoClientException(ioe);
//        }
//        logger.info("getContent() returned an: " + indivoContent.getClass().getName());
//
//        var isb:StringBuffer= new StringBuffer();
//        if ( !(indivoContent is InputStream)) {
//            throw new IndivoClientException(urlRequest.getURL().toString() + " returned value not "
//                + " InputStream as expected, was: " + indivoContent.getClass().getName());
//        } else {
//            var istrm:InputStream= InputStream(indivoContent);
//            if (contentType != null && contentType.startsWith("text/plain")
//                || specialBugWorkaround) {
//                try {
//                    var cc:int= istrm.read();
//                    while (cc != -1) {
//                        isb.append(char(cc));
//                        cc = istrm.read();
//                    }
//                } catch (ioe:IOException) {
//                    throw new RuntimeException(ioe);
//                }
//            }
//            else {
//                try {
//                var ecc:int= istrm.read();
//                while (ecc != -1) {
//                    isb.append(char(ecc));
//                    ecc = istrm.read();
//                }
//                System.err.println("contents: " + isb.toString());
//                } catch (eioe:java.io.IOException) {
//                    throw new RuntimeException(eioe);
//                }
//                logger.info("NOT text/plain content: " + isb.toString());
//                throw new IndivoClientException(
//                        "response content type from indivo not 'text/plain'. "
//                        + contentType);
//            }
//        }        
//        return isb.toString();
//    }
//
//    /**
//    * given a form-urlencoded response, return that response in the
//    * form of a key-value map.
//    */
//    public function mapFromHttpResponse(hresp:String):HashMap
//            {
//                
//        var retVal:HashMap = new HashMap();
//        
//        if (getTestMode() == 1) {
//            if (! (hresp.startsWith("<rest>") && hresp.endsWith("</rest>"))) {
//                throw new RuntimeException("in test mode 1, expected <rest>...</rest>, got: " + hresp);
//            }
//            retVal.put("rest", hresp.substring(6, hresp.length - 7));
//            return retVal;
//        }
//                
//        var hresp0:String= StringEscapeUtils.unescapeHtml(hresp);
//        logger.info("encoded entitied response body: " + hresp
//                + "         encoded response body: " + hresp0);
//        var pairs:Array= hresp0.split("&");
//        for (var tt:int= 0; tt < pairs.length; tt++) {
//            logger.info("apair: " + pairs[tt]);
//        }
//
//        for (var ii:int= 0; ii < pairs.length; ii++) {
//            var eix:int= pairs[ii].indexOf('=');
//            if (eix == -1) {
//                throw new IndivoClientException("did not find '=' in param: " + pairs[ii] + "\n" + hresp0);
//            }
//            var pName:String= pairs[ii].substring(0,eix);
//            if (retVal.get(pName) != null) {
//                throw new IndivoClientException("found multiple '" + pName + "' params." + hresp0);
//            }
//            retVal.put(pName, pairs[ii].substring(eix +1));
//        }
//        return retVal;
//    }
    
//    /** log the contents of an InputStream */
//    private function logStream(prefix:String, cnctnIs:InputStream):void {
//        var sb2:StringBuilder= new StringBuilder();
//        try {
//            var cc2:int= cnctnIs.read();
//            while (cc2 != -1) {
//                sb2.append(char(cc2));
//                cc2 = cnctnIs.read();
//            }
//        } catch (ioe2:java.io.IOException) {
//            throw new RuntimeException(ioe2);
//        }
//        logger.info(prefix + sb2.toString());
//    }
            

//	/** utility for returning the String representation of an XML document. */
//	public function domToString(theDoc:XML):String {
//		return domToString(theDoc, theDoc);
//	}   
//	/** utility for returning the String representation of an XML document.
//	 * @param theDoc the document containing the node.
//	 * @param theNode return the String representation of this node.
//	 */
//	public function domToString(theDoc:XML, theNode:XMLNode):String {
//		var domI:DOMImplementation = theDoc.getImplementation();
//		var domIls:DOMImplementationLS = DOMImplementationLS(domI.getFeature("LS", "3.0"));
//		var lss:LSSerializer = domIls.createLSSerializer();
//		var xmlstr:String = lss.writeToString(theNode);
//		//<?xml version="1.0" encoding="UTF-16"?>
//		return xmlstr;
//	}
	
	public function removeLeadingSlash(relativePath:String):String
	{
		if (relativePath.substr(0, 1) == "/")
			return relativePath.substr(1);
		else
			return relativePath;
	}
}
}