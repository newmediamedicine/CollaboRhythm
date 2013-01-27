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
package org.indivo.client
{

	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.*;

	import j2as3.collection.HashMap;

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;
	import mx.utils.URLUtil;

	/**
* Methods that provide convenient wrappers around the Indivo admin REST api calls
* documented at <code>http://wiki.chip.org/indivo</code>
* Users of <code>Admin</code> should include a log4j jar and log4j.xml in their classpath.
* a few utilites.
*
* MOST OF THE METHODS IN Admin MAP TO REST CALLS.
* HERE ARE THE RULES FOR DEVELOPING METHOD NAMES FROM THE REST URL.
* <ul>
* <li>code '/' as '_', except omit the leading '/'</li>
* <li>where ever there is a variable, use 'X'</li>
* <li>When REST call includes a dash ("-"), remove the dash and upper-case the first character that followed
*   the dash.</li>
* <li>use request method as last part of method name</li>
* <li>for GET calls than can include a ?queryString, queryString is the first Java
*   method param.</li>
* <li>where document XML is supplied in the call, that is the last parameter</li>
* <li>where record token/secret are needed, these are the last two parameters before document XML.</li>
* <li>variables in the REST url map to parameters in their respective sequence.</li>
* <li>every method comes in two flavors, one with indivoURL consumerKey/secret assumed to have been
*   set at object constuction time, the other with consumerKey, consumerSecret, indivoURL as the first
*   three params.</li>
* <li>Higher level methods that are named as if they map to a REST call,
*   but that do more than map directly to a single.
*   REST call, are named according to the most likely REST URL that would do their function, if there were
*   such a rest call, but with "_HL" prefix.</li>
* </ul>
*/
public class Admin extends EventDispatcher implements WikiTestable
{
    private static var serialVersionUID:Number= 1;
	private var logger:ILogger;
    private var testMode:int= 0;

    //private String oauthConsumerKey = null;
    //private String consumerSecret = null;
//    private var base64:Base64= new Base64();
//    private var documentBuilderFactory:DocumentBuilderFactory= null;
    private var documentBuilder:DocumentBuilder= null;

    private var consumerKey:String= null;
    private var consumerSecret:String= null;
    private var adminBase:String= null;
    private var phaAdminUtils:PhaAdminUtils= null;
    //private DefaultOAuthConsumer oauthConsumer = null;
    
    /**
    * @param oauthConsumerKey key your app has been assigned by your Indivo administrator.
    * @param consumerSecret secret your app has been assigned by your Indivo administrator,
    *      keep it secret.
    * @param adminBase server URL prior to documented REST API portion, for example
    *   most Indivo REST API locations start with "/records/...",
    *   <code>adminBase</code> is the part of the URL before "/records/...".
    */
    public function Admin(oauthConsumerKey:String, consumerSecret:String, adminBase:String)
	{
        //this.consumerSecret = consumerSecret;
        this.consumerKey = oauthConsumerKey;
        this.consumerSecret = consumerSecret;
        this.phaAdminUtils = new PhaAdminUtils(oauthConsumerKey, consumerSecret);
        this.adminBase = adminBase;
        if (adminBase.length > 0 && adminBase.charAt(adminBase.length -1) != '/') {
            this.adminBase += '/';
        }
		logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
        logger.info("Base URL: " + this.adminBase);

//        oauthConsumer = new DefaultOAuthConsumer(oauthConsumerKey, consumerSecret, SignatureMethod.HMAC_SHA1);
        
//        documentBuilderFactory = DocumentBuilderFactory.newInstance();
//        try {
//            documentBuilder = documentBuilderFactory.newDocumentBuilder();
//        } catch (var pce:javax.xml.parsers.ParserConfigurationException) {
//            throw new IndivoClientException(pce);
//        }
    }
    
    
    /** implements WikiTestable */
    public function setTestMode(tm:int):HashMap {
        this.testMode = tm;
        this.phaAdminUtils.setTestMode(tm);
        
        var retVal:HashMap = new HashMap();
        retVal.put("threeLegged",false);
        retVal.put("PhaAdminUtils", phaAdminUtils);
        retVal.put("dropRecord", false);
        
        return retVal;
    }
    /** implements WikiTestable */
    internal function getTestMode():int {
        return testMode;
    }

	/*
	Search/replace pairs for converting from Java (synchronus) to Flash (asynchronus)
	
	^\s*?(//)*?\s+var\ fromAdminRequest:XML=\ null;\n
	
	fromAdminRequest\ =\ adminRequest\(
	adminRequest\(
	
	^\s*?(//)*?\s+return\ fromAdminRequest;\n
	
	):XML {
	):void {
	
	*/
	
    /** GET /accounts/{account_id}
    */
    public function accounts_XGET(accountId:String, userData:Object=null):void {
        adminRequest("accounts/" + accountId, null, userData, "GET");
    }

    /** POST /accounts/{account_id}/authsystems/password/change
    *
    */
    public function accounts_X_authsystems_password_changePOST(accountId:String, content:String, userData:Object=null):void {
        adminRequest("accounts/" + accountId + "/authsystems/password/change", content, userData);
    }

    /** POST /accounts/{account_id}/authsystems/
    *
    */
    public function accounts_X_authsystems_POST(accountId:String, content:String, userData:Object=null):void {
        adminRequest("accounts/" + accountId + "/authsystems/", content, userData);
    }

    /** POST /accounts/{account_id}/reset
    *
    */
    public function accounts_X_resetPOST(accountId:String, userData:Object=null):void {
        adminRequest("accounts/" + accountId + "/reset", null, userData);
    }
    
    /** POST /accounts/
    * @param params form-urlencoded
    *   username={username}&contact_email={contact_email}&primary_secret_p={0|1}&secondary_secret_p={0|1}&password={password}
    * @return &lt;Account id="joe@smith.org" /&gt;
    */
    public function accounts_POST(params:String, userData:Object=null):void {
        adminRequest("accounts/", params, userData);
    }
    
    /** POST /accounts/{account_id}/secret-resend
    * @param accountId id of account for which secret is to be resent.
    */
    public function accounts_X_secretResendPOST(accountId:String, userData:Object=null):void {
        adminRequest("accounts/" + accountId + "/secret-resend", null, userData);
    }
    
    /**
    * 
    * POST /records/
    *
    * @param contact XML String representing the root node
    *    of a document to be included with the new record.
    */
    public function records_POST(contact:String, userData:Object=null):void {
        adminRequest("records/", contact, userData);
    }
    
    /**
    * see REST API: PUT /records/external/{app_id}/{external_id}
    *
    * @param appId ID of the calling application, which uses external_id to make sure two records are
    *   not created for the same person.
    *
    * @param extrnlRecId a unique identifier that is meaningful
    *   to your institution.  You can use this value, later, to retrieve
    *   the record ID assigned by Indivo if you do not remember that
    *   Indivo will not create
    *   a new record if you have already created a record with this
    *   extrnlRecId.  May be null to create a new record without and external ID.
    *
    * @param contact XML String representing the root node
    *    of contact document to be included with the new record.
    *
    * @param demographics XML String representing the root node
    *    of demographic document to be included with the new record.  Must be null for now,
    *    pending addition of functionality.
    */
    public function records_external_X_XPUT(appId:String, extrnlRecId:String, contact:String, demographics:String=null, userData:Object=null):void {
        if (demographics != null) {
            throw new IndivoClientException("creation or initial demographics document not supported yet");
        }
        if (extrnlRecId == null) {
            logger.info("no external record id");
            adminRequest("records/", contact);
        } else {
            adminRequest("records/external/" + appId + '/' + extrnlRecId, contact, userData, "PUT");
        }
    }

    /** PUT /records/{record_id}/owner
    * @param recordId record id
    * @param ownerEmail as text, form-urlencoded
    */
    public function records_X_ownerPUT(recordId:String, ownerEmail:String, userData:Object=null):void {
        adminRequest("records/" + recordId + "/owner", ownerEmail, userData, "PUT");
    }
    
    /**
    *POST /records/{record_id}/apps/{app_id}/setup
    * @param consumerKey this admin's oauth key on the foriegn installation.
    * @param consumerSecret this admin's oauth secret on the foriegn installation.
    * @param installationURL foriegn installation URL.
    * @param recordId the indivo assigned record ID.
    * @param phaId the ID that your Indivo administrator has
    *    assigned to your Personal Health Application.
    * @param setupDoc setup_document, may be null
    */
    public function records_X_apps_X_setupPOST(
            recordId:String, phaId:String, setupDoc:String=null, userData:Object=null,
			consumerKey:String=null, consumerSecret:String=null, installationURL:String=null):void {
        adminRequest(
                "records/" + recordId + "/apps/"
                + /*AuthUtils.encode(*/phaId/*)  I recommend that, for now, Nate use the '@' in a raw way in the URL, so that it gets singly-encoded to %40. It's a minor violation, not a terrible one. We'll fix it later. Ben*/
                + "/setup",
				setupDoc,
				userData,
				"POST",
				consumerKey, consumerSecret, installationURL
		);
//        var plainStr1:String= phaAdminUtils.processIndivoResultPlain(fromAdminRequest);
//        var tokenSecret:HashMap = phaAdminUtils.mapFromHttpResponse(plainStr1);
//
//        logger.info("token: " + tokenSecret.get("oauth_token") + "  --  secret: " + tokenSecret.get("oauth_token_secret"));
//        return tokenSecret;
    }
	
	public function create_session(
		username:String,
		password:String,
		userData:Object=null,
		consumerKey:String=null, consumerSecret:String=null):void
	{
		// based on method from the python client library: create_session [/alpha2-indivo_ui_server/indivo_client_py/lib/api.py:78]	

//		def create_session(self, app_info, data=None, debug=False): 
//		return self.utils_obj.get_response('create_session', 
//			'post', 
//			'/oauth/internal/session_create', 
//			[], 
//			app_info, 
//			data, 
//			debug=debug)		
		var params:String = URLUtil.objectToString({ username: username, password: password}, "&", false);
		adminRequest(
			"/oauth/internal/session_create",
			params,
			userData,
			"POST",
			consumerKey,
			consumerSecret);
	}

    /**
    * Typically, better to use the more specific API calls rather than this more
    * general one.  <code>adminRequest</code> is public so that it can
    * be used as an alternative to the more specific methods.  This
    * might be useful, for example, if various types of requests are
    * generated dynamically.
    * @param consumerKey most often null, use value supplied by constructor
    * @param consumerSecret most often null, use value supplied by constructor
    * @param installationURL most often null, use value supplied by constructor
    * @param reqMeth GET, PUT or POST
    * @param relativePath part or the URL documented with the REST API. Do
    *    not include the adminBase provided to the constructor.
    * @param requestXmlOrParams for those calls which require an XML document, this
    *    is the root node of that document, and first character must be &lt;.
    * <p>For calls requiring formURLencoded params, this is the form URL encoded param string</p> 
    * <p><code>null</code> where no
    *    XML and no formURLencoded params are associated with making the request.</p>
    */
    public function adminRequest(relativePath:String, requestXmlOrParams:String=null, userData:Object=null, reqMeth:String="POST", consumerKey:String=null, consumerSecret:String=null, installationURL:String=null):void {
        var urlRequest:URLRequest= null;
        var indivoContent:Object= null;
        
		relativePath = phaAdminUtils.removeLeadingSlash(relativePath);
		
        var adminURLString:String= null;
        if (installationURL == null) {
            adminURLString = adminBase + relativePath;
        } else {
            adminURLString = installationURL + relativePath;
        }

        if (getTestMode() == 1)
		{
            phaAdminUtils.setTestMode(1);
            var inputString:String =
                    "<rest>" + reqMeth + " /" + relativePath.replace("&","&amp;") + "</rest>";

			this.dispatchEvent(new IndivoClientEvent(IndivoClientEvent.COMPLETE,
													 new XML(inputString), null, null, relativePath, requestXmlOrParams, null,
													 userData));
		}

		logger.info(reqMeth + " " + relativePath + (requestXmlOrParams ? ", requestXmlOrParams=" + requestXmlOrParams : ""));

        var contentType:String= null;
        if (requestXmlOrParams != null && requestXmlOrParams.length > 0) {
            if (requestXmlOrParams.charAt(0) == '<') {
                contentType = "application/xml";
            } else if (requestXmlOrParams.indexOf("=") >= 1) {
                contentType = "application/x-www-form-urlencoded";
            }
        }
		urlRequest = phaAdminUtils.setupConnection(
                reqMeth, adminURLString, null, new HashMap(), contentType);

		phaAdminUtils.prepareRequest(urlRequest, requestXmlOrParams);
		
		phaAdminUtils.signWithSignpost(urlRequest, consumerKey, consumerSecret, null, null);
		
		var handler:IndivoRequestHandler = new IndivoRequestHandler(this, this.phaAdminUtils);
		logger.info(ObjectUtil.toString(urlRequest));
		handler.handle(urlRequest, relativePath, requestXmlOrParams, null, userData);
    }


//    /**
//    *  given a connection, return the XML Document of the body of
//    *  the response from that connection.
//    *  @param cnctn connection to which the request has already been
//    *     sent.
//    */
//    private function processIndivoResultXml(cnctn:XML):Document {
//                
//        if (getTestMode() == 1) {
//            (TestClientFakeConnection(cnctn)).setContentType("application/xml");
//        }
//
//        var docForContent:Document= null;
//        var contentType:String= cnctn.getContentType();
//        if (! "application/xml".equals(contentType)) {
////            try {
//                var indivoContent:Object= cnctn.getContent();
//                logger.info("getContent() returned an: " + indivoContent.getClass().getName());
//                logger.info("contentType, indivoContent: " + contentType + ", " + indivoContent);
//                if (indivoContent instanceof InputStream) {
//                    var indivoContentIS:InputStream= InputStream(indivoContent); 
//                    var indivoContentStrb:StringBuffer= new StringBuffer();
//                    var indivoContentCC:int= indivoContentIS.read();
//                    while (indivoContentCC != -1) {
//                        indivoContentStrb.append(char(indivoContentCC));
//                        indivoContentCC = indivoContentIS.read();
//                        if (indivoContentStrb.length > 80) {
//                            logger.info("indivoContent part: " + indivoContentStrb.toString());
//                            indivoContentStrb = new StringBuffer();
//                        }
//                    }
//                    logger.info("indivoContent content: " + indivoContentStrb.toString());
//                }
////            } catch (var ioe:IOException) {
////                throw new IndivoClientException(ioe);
////            }
//            throw new IndivoClientException(
//                    "response content type from indivo not 'application/xml'. "
//                    + contentType);
//        }
//
////        try {
//            var indivoContent:Object= cnctn.getContent();
//            logger.info("getContent() returned an: " + indivoContent.getClass().getName());
//    
//            if ( !(indivoContent instanceof InputStream)) {
//                throw new IndivoClientException(cnctn.getURL().toString() + " returned value not "
//                    + " InputStream as expected, was: " + indivoContent.getClass().getName());
//            } else {
//                logger.info("indivoContent is an InputStream");
////                try {
//					// TODO: synchronized?
////					synchronized(documentBuilder) { docForContent = documentBuilder.parse(InputStream(indivoContent)); }
//                    docForContent = documentBuilder.parse(InputStream(indivoContent));
////                } catch (var sxe:org.xml.sax.SAXException) {
////                    throw new IndivoClientException(sxe);
////                }
//                var docElem:Element= docForContent.getDocumentElement();
//                logger.info("docElem tag name: " + docElem.getTagName());
//            }
////        } catch (var ioe:IOException) {
////            throw new IndivoClientException(ioe);
////        }
//        
//        return docForContent;
//    }
 
    public function getAdminUtils():PhaAdminUtils { return phaAdminUtils; }
    
    public override function toString():String {
        return getQualifiedClassName(this) + ": " + phaAdminUtils.defaultConsumerKey
            + "; " + phaAdminUtils.defaultConsumerSecret + "; " + this.adminBase;
    }

	public function clone():Admin
	{
		return new Admin(consumerKey, consumerSecret, adminBase);
	}
}
}