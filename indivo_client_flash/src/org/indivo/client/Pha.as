package org.indivo.client {
/* change log
Jan. 2010 - changed params param throughout, now can be Map as well as String.
            If Map, Pha will handle encoding, if String assumed already encoded.

Jan. 2010 - added constants for known medical reports.

Jan. 2010 - constructor now accepts baseURL either with or without a final slash ('/').

Jan. 2010 - added support for:
   PUT /records/{record_id}/inbox/{message_id}/attachments/{attachment_num}
   GET /codes/systems/
   GET /codes/systems/{short_name}/query?q={query}

Jan. 2010 - changed some params from String to int, such as attachmentNum
*/

import flash.events.EventDispatcher;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLVariables;
import flash.utils.*;

import j2as3.collection.HashMap;

import mx.collections.*;
import mx.logging.*;
import mx.logging.targets.*;
import mx.utils.StringUtil;
import mx.utils.URLUtil;

import org.iotashan.oauth.OAuthConsumer;
import org.iotashan.oauth.OAuthRequest;
import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
import org.iotashan.oauth.OAuthToken;
import org.iotashan.utils.URLEncoding;

/**
* Convenience methods that wrap the Indivo REST api calls
* that are documented at <code>http://wiki.chip.org/indivo</code>
* for Personal Health Applications (PHA-s), plus
* a few utilites.<br/><br/>
*
* HERE ARE THE RULES FOR TRANSLATING A REST URL TO A JAVA API METHOD NAME.
* <ul>
* <li>code REST '/' as Java '_', except omit the leading '/'</li>
* <li>where ever there is a variable, use 'X'</li>
* <li>omit record/{record_id} from the translation, except where there is nothing else.</li>
* <li>When record/{record_id} absent from the REST call, AND there would
*   otherwise be ambiguity (because there is a REST call that is the same except it has
*   record/{record_id} and this is omited from the translation), start the method name with "nr_"</li>
* <li>When REST call includes a dash ("-"), remove the dash and upper-case the first character that followed
*   the dash.</li>
* <li>use request method (GET|PUT|POST|DELETE) as last part of method name.</li>
* <li>for REST calls than can include a ?params, params is the first Java
*   method param.</li>
* <li>variables in the REST url map to parameters in their respective sequence.</li>
* <li>where record token/secret are needed, these are the last two parameters when there is no
*   HTTP content to be sent.  record token/secret are the last two paramters before
*   HTTP content when HTTP content present.</li>
* <li>where content is to be supplied in the call, that is the last parameter</li>
* <li>all REST calls of the form: <code>GET /records/{record_id}/reports/minimal/&lt;type_eg_medications&gt;/</code>
*   are combined into one method as if the REST calls were documented as:
*   <code>GET /records/{record_id}/reports/minimal/{type_of_minimal_eg_medications}/</li>
* <li>every method comes in two flavors. In one flavor, consumerKey/secret and indivoURL assumed to
*   have been set at Pha instance construction time.  In the other flavor, consumerKey,
*   consumerSecret, and indivoURL are the first three params or, when params is present,
*   the first three parameters following the params param.</li>
* <li>Higher level methods that are named as if they map to a REST call,
*   but that do more than map directly to a single
*   REST call, are named according to the fictional REST URL that would seem to do their function,
*   but the method name is given "_HL" as a suffix.</li>
* </ul>
* <h3>params param</h3>
* <p>For all methods that have a params parameter, params
*     represents the part of URL following '?', but not including '?'
*     params can be a String or Map&lt;String,Object&gt;.
*     if of type String, caller must have already taken care that the keys and values within
*     the string are urlencoded.  If of type Map,
*     the caller must <b>NOT</b> have done the urlEncoding.
*     Where type is Map, each value must be of type String or String[].  Where one key
*     has multiple values, type String[] must be used for that key's value.
*     Where no params is needed, null, "", or Map will all work.
* </p>
* <pre>
*    Example of a String: a=x%3dy&b=z
*    Example of Map&lt;String,Object&gt;
*       Map&lt;String,Object&gt; query = new HashMap&lt;String,Object&gt;()
*       query.put("a","x=y");
*       String[] value = new String[2]; value[0] = "z"; value[1] = "w";
*       query.put("b",value);
* </pre>
*/
public class Pha extends EventDispatcher implements WikiTestable
{
    private static var serialVersionUID:Number= 1;

    /** medical report name constant.  medical reports names other than those represented by constants
    *  might be valid.  Constants are provided for these known as of January 22, 2010.
    *  Follow measurements with "/{lab-code}/".
    */
    public static var   // known medical reports
        MEASUREMENTS:String = "measurements";

    /** medical report name constant.  medical reports names other than those represented by constants
    *  might be valid.  Constants are provided for these known as of January 22, 2010.
    */
    public static var // known medical reports
    	MEDICATIONS:String = "medications",
    	ALLERGIES:String = "allergies",
    	EQUIPMENT:String = "equipment",
    	IMMUNIZATIONS:String = "immunizations",
    	PROCEDURES:String = "procedures",
    	PROBLEMS:String = "problems",
    	VITALS:String = "vitals";
    
	private var logger:ILogger;

//    private var documentBuilderFactory:DocumentBuilderFactory= null;
    private var documentBuilder:DocumentBuilder= null;
    
    private var instanceConsumerKey:String= null;
    private var instanceConsumerSecret:String= null;
    private var appId:String= null;
    private var phaBase:String= null;
    
    private var phaAdminUtils:PhaAdminUtils= null;
    //private OAuthConsumer oauthConsumer = null;  not thread safe, make a new one each time
    
    private var testMode:int= 0;
    
    /**
    * Use this constructor when you will use the same installation,
    * as the same consumer, repeatedly.
    * @param oauthConsumerKey key your Indivo administrator assigned to
    *     the calling Personal Health Application.
    * @param oauthConsumerSecret secret your Indivo administrator assigned
    *     to the calling Personal Health Application.  Keep this secret.
    * @param baseURL server URL prior to documented REST API portion, for example
    *   most Indivo REST API locations start with "/records/...",
    *   <code>adminBase</code> is the part of the URL before "/records/...".
    */
    public function Pha(oauthConsumerKey:String, oauthConsumerSecret:String, baseURL:String) {
        this.instanceConsumerKey = oauthConsumerKey;
        this.instanceConsumerSecret = oauthConsumerSecret;
        this.phaBase = baseURL;
        if (baseURL.length > 0 && baseURL.charAt(baseURL.length -1) != '/') {
            this.phaBase += '/';
        }
        phaAdminUtils = new PhaAdminUtils(instanceConsumerKey, instanceConsumerSecret);
        constructorHelper();
        logger = Log.getLogger(getQualifiedClassName(this).split("::")[1]);
        
        //oauthConsumer = new DefaultOAuthConsumer(
        //        instanceConsumerKey, instanceConsumerSecret, SignatureMethod.HMAC_SHA1);
    }

//    /**
//    * Use this constructor when there is not to be any default installation
//    * or default consumer.
//    */
//    public function Pha() {
//        phaAdminUtils = new PhaAdminUtils();
//        constructorHelper();
//    }
    
    private function constructorHelper():void {
//        documentBuilderFactory = DocumentBuilderFactory.newInstance();
//        try {
//            documentBuilder = documentBuilderFactory.newDocumentBuilder();
//        } catch (pce:ParserConfigurationException) {
//            throw new IndivoClientException(pce);
//        }
    }


    
    /** implements WikiTestable, not for application use.
    *  This if for Indivo development team internal use, when testing
    *  that the methods of this class correspond correctly to the REST
    *  API as documented on the Wiki.
    */
    public function setTestMode(tm:int):HashMap {
        this.testMode = tm;
        
		var retVal:HashMap = new HashMap();

        var mparams2:Array= new String[3];
        mparams2[0] = "{consumer-key}";
        mparams2[1] = "{consumer-secret}";
        mparams2[2] = "{indivo-url}";
        retVal.put("extraParams", mparams2);
        
        retVal.put("threeLegged",true);
        retVal.put("PhaAdminUtils", phaAdminUtils);
        retVal.put("dropRecord", true);
        
        return retVal;
    }
    /** implements WikiTestable */
    internal function getTestMode():Number {
        return testMode;
    }

/*
	Search/replace pairs for converting from Java (synchronus) to Flash (asynchronus)
	
	^\s*?(//)*?\s+var\ fromPhaRequest:XML=\ null;\n
	
	fromPhaRequest\ =\ phaRequest\(
	phaRequest\(
	
	^\s*?(//)*?\s+return\ fromPhaRequest;\n
	
	):XML {
	):void {
	
	*/
	
	
    /** *GET /accounts/{account_id}/records/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param accountId account ID
    * @param accountToken OAuth token for account
    * @param accountTokenSecret OAuth token secret for account
    */
    public function accounts_X_records_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String, accountId:String, accountToken:String, accountTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "accounts/" + accountId + "/records/";
        //if (params != null && params.length > 0) {
        //    requestUrl += "?" + params;
        //}
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accountToken, accountTokenSecret, null, params, userData);
    }
    
    /**
    *GET /records/{record_id}   get all the documents of the record
    *records_XGET(String recordId, ...)  [see rule (d) above: "... except ..."
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function records_XGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, null, accessToken, accessTokenSecret, null, userData);
    }
    
    /**GET /records/{record_id}/apps/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_GET(params:Object,consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/apps/";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
    }
    
    /**
    *  GET /records/{record_id}/documents/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_GET(
            params:Object,
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
//        var metaFromPhaRequest:XML= null;
        var requestUrlMeta:String= "records/" + recordId + "/documents/";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlMeta, accessToken, accessTokenSecret, null, params, userData);
//        return metaFromPhaRequest;
    }

    /**
    * GET /records/{record_id}/documents/?type={type}
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param type XML schema datatype, with prefix of http://indivo.org/vocab/xml/documents#
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_type_X_GET(
            params:Object,
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            type:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
//        var metaFromPhaRequest:XML= null;
        var requestUrlMeta:String= "records/" + recordId + "/documents/";
		
		var typeParam:String = URLUtil.objectToString({ type: type }, "&", false);
		if (params != null)
			params = typeParam + "&" + params;
		else
			params = typeParam;
		
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlMeta, accessToken, accessTokenSecret, null, params, userData);
//        return metaFromPhaRequest;
    }

    /**
    *GET /records/{record_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_XGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /**
    * GET /records/{record_id}/special/demographics
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function special_demographicsGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/special/demographics";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }
    /**
    * PUT /records/{record_id}/special/demographics
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML of the document to PUT
    */
    public function special_demographicsPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, document:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/special/demographics";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, document, null, userData);
    }
//---------------------------

    /**
    * GET /records/{record_id}/special/contact
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function special_contactGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/special/contact";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /**
    * PUT /records/{record_id}/special/contact
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML of the document to PUT
    */
    public function special_contactPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, accessToken:String, accessTokenSecret:String, document:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/special/contact";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, document, null, userData);
    }
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

    /**
    *GET /records/{record_id}/documents/{document_id}/meta
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_metaGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/meta";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /**
    *GET /records/{record_id}/documents/{document_id}/versions/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_versions_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/versions/";
        //if (params != null && params.length > 0) {
        //    requestUrl += "?" + params;
        //}
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
    }

    /**
    *GET /records/{record_id}/documents/external/{app_id}/{external_id}/meta
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_external_X_X_metaGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, appId:String, xId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/external/" + appId + "/" + xId + "/meta";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /** add a document to an Indivo record
    * See POST /records/{record_id}/documents/
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML document to POST
    */
    public function documents_POST(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            accessToken:String,
            accessTokenSecret:String,
            document:String,
			userData:Object=null):void {
        phaRequest(
                consumerKey, consumerSecret, installationURL,
                "POST",
                "records/" + recordId + "/documents/",
                accessToken,
                accessTokenSecret,
                document, null, userData);  // no URL params
    }

    /**
    *PUT /records/{record_id}/documents/external/{app_id}/{external_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML document to PUT
    */
    public function documents_external_X_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, appId:String, xId:String, accessToken:String, accessTokenSecret:String, document:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/external/" + appId + "/" + xId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, document, null, userData);
    }

    /**PUT /records/{record_id}/documents/{document_id}/label
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param newLabel new label
    */
    public function documents_X_labelPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, newLabel:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/label";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, newLabel, null, userData);
    }


    /**
    * PUT /records/{record_id}/documents/external/{app_id}/{external_id}/label
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param newLabel new label
    */
    public function documents_external_X_X_labelPUT(consumerKey:String, consumerSecret:String, installationURL:String,
        recordId:String, appId:String, xId:String, accessToken:String, accessTokenSecret:String, newLabel:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/external/" + appId + "/" + xId + "/label";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, newLabel, null, userData);
    }

    /** POST /records/{record_id}/documents/{document_id}/replace
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param replacement XML replacment document
    */
    public function documents_X_replacePOST(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, replacement:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/replace";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "POST", requestUrl, accessToken, accessTokenSecret, replacement, null, userData);
    }

    /**
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID of original document
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_replace_external_X_XPUT(consumerKey:String, consumerSecret:String, installationURL:String,
        recordId:String, docId:String, appId:String, xId:String, accessToken:String, accessTokenSecret:String, replacement:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/replace/external/" + appId + "/" + xId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, replacement, null, userData);
    }    

    /** DELETE /records/{record_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_XDELETE(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            docId:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "DELETE", requestUrl, accessToken, accessTokenSecret, null, userData);
    }
    
    /** POST /records/{record_id}/documents/{document_id}/set-status
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param formUrlEncoded reason={reason}&status={void|active|archived}
    */
    public function documents_X_setStatusPOST(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, formUrlEncoded:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/set-status";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "POST", requestUrl, accessToken, accessTokenSecret, formUrlEncoded, null, userData);
    }
    
    /** GET /records/{record_id}/documents/{document_id}/status-history
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_statusHistoryGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/status-history";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }
    
    /** PUT /records/{record_id}/documents/{document_id}/rels/{rel_type}/{other_document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID of the first document in the relationship
    * @param relType type of relationship
    * @param otherDocId document ID of the second document in the relationship
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_rels_X_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, relType:String, otherDocId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/rels/" + relType + "/" + otherDocId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /** add a related document (e.g. annotation) to an Indivo record
    *POST /records/{record_id}/documents/{document_id}/rels/{rel_type}/
    *{INDIVO DOCUMENT CONTENT}
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID of the older document in the relationship
    * @param relType type of relationship
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document the new, related, document being added
    */
    public function documents_X_rels_X_POST(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            docId:String,
            relType:String,
            accessToken:String,
            accessTokenSecret:String,
            document:String,
			userData:Object=null):void {
        phaRequest(
                consumerKey, consumerSecret, installationURL,
                "POST",
                "records/" + recordId + "/documents/" + docId + "/rels/" + relType + "/",
                accessToken,
                accessTokenSecret,
                document,
				null,
				userData);  // no URL params
        //logger.info("response from POST: " + domToString(fromPhaRequest));
    }
    
    /** *PUT /records/{record_id}/documents/{document_id}/rels/{rel_type}/external/{app_id}/{external_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID of the older document in the relationship
    * @param relType type of relationship
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document the new, related, document being added
    */
    public function documents_X_rels_X_external_X_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, docId:String, relType:String, appId:String, xId:String, accessToken:String, accessTokenSecret:String, document:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/rels/" + relType + "/external/" + appId + "/" + xId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, document, null, userData);
    }

    /**
    * See GET /records/{record_id}/documents/{document_id}/rels/{rel_type}/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param docId document ID of the older document in the relationship
    * @param relType type of relationship
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function documents_X_rels_X_GET(
            params:Object,
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            docId:String,
            relType:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/documents/" + docId + "/rels/" + relType + '/';
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
    }
        
//    /**
//    *  GET /records/{record_id}/documents/{document_id}/rels/{rel_type}/
//    *  GET /records/{record_id}/documents/{document_id}
//    * @param params becomes ?{query_string} at end of URL.
//    *     See <b>params param</b> note in the class description, above.
//    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
//    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
//    * @param installationURL base URL of the Indivo server
//    * @param recordId record ID
//    * @param docId document ID of the older document in the relationship
//    * @param relType type of relationship
//    * @param accessToken OAuth token for access to record
//    * @param accessTokenSecret OAuth token secret for access to record
//    */
//    public function documents_X_rels_X_GET_HL(
//            params:Object,
//            consumerKey:String,
//            consumerSecret:String,
//            installationURL:String,
//            recordId:String,
//            docId:String,
//            relType:String,
//            accessToken:String,
//            accessTokenSecret:String,
//            userData:Object=null):ArrayList {
//        var fromPhaRequest:XML= documents_X_rels_X_GET(
//            params, consumerKey, consumerSecret,
//            installationURL,
//            recordId,
//            docId,
//            relType,
//            accessToken,
//            accessTokenSecret);
//		var retVal:ArrayList = new ArrayList();
//        var relNL:NodeList= fromPhaRequest.getDocumentElement().getElementsByTagName("XML");
//        for (var ii:int= 0; ii < relNL.getLength(); ii++) {
//            var aDocMeta:Element= Element(relNL.item(ii));
//            var aId:String= aDocMeta.getAttribute("id");
//            var relReq:String= "records/" + recordId + "/documents/" + aId;
//            var fromPhaRelated:XML= phaRequest("GET", relReq, accessToken, accessTokenSecret, null);
//            retVal.add(fromPhaRelated);
//        }
//        
//        return retVal;
//    }

    /*
    *Send a Message
    */
    
    /**PUT /accounts/{account_id}/inbox/{message_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param accountId account ID
    * @param messageId messageID
    * @param accountToken OAuth token for account
    * @param accountTokenSecret OAuth token secret for account
    * @param message subject={subject}&body={body}
    */
    public function accounts_X_inbox_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, accountId:String, messageId:String, accountToken:String, accountTokenSecret:String, message:String, userData:Object=null):void {
        var requestUrl:String= "accounts/" + accountId + "/inbox/" + messageId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accountToken, accountTokenSecret, message, null, userData);
    }

    /** PUT /records/{record_id}/inbox/{message_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param messageId messageID
    * @param accountToken OAuth token for account
    * @param accountTokenSecret OAuth token secret for account
    * @param message subject={subject}&body={body}
    */
    public function inbox_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, messageId:String, accountToken:String, accountTokenSecret:String, message:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/inbox/" + messageId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accountToken, accountTokenSecret, message, null, userData);
    }
    
    /** PUT /records/{record_id}/inbox/{message_id}/attachments/{attachment_num}
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param messageId messageID
    * @param attachmentNum 1-indexed (count from one?) integer that represents the order of the attachment.
    *     It cannot be larger than num_attachments that was declared. 
    * @param accountToken OAuth token for account
    * @param accountTokenSecret OAuth token secret for account
    * @param attachedDoc {INDIVO_DOCUMENT}
    */
    public function inbox_X_attachments_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, messageId:String, attachmentNum:int, accountToken:String, accountTokenSecret:String, attachedDoc:String):void {
        var requestUrl:String= "records/" + recordId + "/inbox/" + messageId + "/attachments/" + attachmentNum;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accountToken, accountTokenSecret, attachedDoc);
    }

    /**
    * POST /records/{record_id}/notify.
    * (used to be: PUT /records/{record_id}/notifications/{notification_id})
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param accountToken OAuth token for account
    * @param accountTokenSecret OAuth token secret for account
    * @param message subject={subject}&body={body}
    */
    public function notifyPOST(consumerKey:String, consumerSecret:String, installationURL:String,
            recordId:String, accountToken:String, accountTokenSecret:String, message:String):void {
        var requestUrl:String= "records/" + recordId + "/notify";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "POST", requestUrl, accountToken, accountTokenSecret, message);
    }



/* APP SPECIFIC STORAGE -- non-record-specific */

    /**GET /apps/{app_id}/documents/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    */
    public function nr_apps_X_documents_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String, appId:String):void {
        return apps_X_documents_GET(params, consumerKey, consumerSecret, installationURL, null, appId, null, null);
    }

    /**GET /apps/{app_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param docId document ID
    */
    public function nr_apps_X_documents_XGET(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, docId:String):void {
        return apps_X_documents_XGET(consumerKey, consumerSecret, installationURL, null, appId, docId, null, null);
    }
    
    /**GET /apps/{app_id}/documents/{document_id}/meta
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param docId document ID
    */
    public function nr_apps_X_documents_X_metaGET(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, docId:String):void {
        return apps_X_documents_X_metaGET(consumerKey, consumerSecret, installationURL, null, appId, docId, null, null);
    }

    /**GET /apps/{app_id}/documents/external/{external_id}/meta
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    */
    public function nr_apps_X_documents_external_X_metaGET(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, xId:String):void {
        return apps_X_documents_external_X_metaGET(consumerKey, consumerSecret, installationURL, null, appId, xId, null, null);
    }
    
    /**POST /apps/{app_id}/documents/
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param document XML document to POST
    */
    public function nr_apps_X_documents_POST(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, document:String):void {
        return apps_X_documents_POST(consumerKey, consumerSecret, installationURL, null, appId, null, null, document);
    }

    /**PUT /apps/{app_id}/documents/external/{external_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    */
    public function nr_apps_X_documents_external_XPUT(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, xId:String, docToAdd:String):void {
        return apps_X_documents_external_XPUT(consumerKey, consumerSecret, installationURL, null, appId, xId, null, null, docToAdd);
    }

    /**PUT /apps/{app_id}/documents/{document_id}/label
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param docId document ID
    * @param newLabel new label
    */
    public function nr_apps_X_documents_X_labelPUT(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, docId:String, newLabel:String):void {
        return apps_X_documents_X_labelPUT(consumerKey, consumerSecret, installationURL, null, appId, docId, newLabel, null, null);
    }    
    
    /**DELETE /apps/{app_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId application ID
    * @param docId document ID
    */
    public function nr_apps_X_documents_XDELETE(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, docId:String):void {
        return apps_X_documents_XDELETE(consumerKey, consumerSecret, installationURL, null, appId, docId, null, null);
    }

    /** GET /apps/{app_id}/inbox/
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId applications ID
    */
    public function nr_apps_X_inbox_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String, appId:String):void {
        var requestUrlList:String= "apps/" + appId + "/inbox/";
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlList, null, null, null, params);
    }

    /** GET /apps/{app_id}/inbox/{message_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId applications ID
    * @param messageId ID of message to get
    */
    public function nr_apps_X_inbox_XGET(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, messageId:String):void {
        var requestUrlMsg:String= "apps/" + appId + "/inbox/" + messageId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlMsg, null, null, null, null);
    }
    
    /** GET /apps/{app_id}/inbox/{message_id}/attachments/{attachment_num}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param appId applications ID
    * @param messageId ID of message to get
    * @param attachmentNum attachment number
    */
    public function nr_apps_X_inbox_X_attachments_XGET(consumerKey:String, consumerSecret:String, installationURL:String, appId:String, messageId:String, attachmentNum:int):void {
        var requestUrlAtch:String= "apps/" + appId + "/inbox/" + messageId + "/attachments/" + attachmentNum;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlAtch, null, null, null, null);
    }
    
    /*
* APP SPECIFIC STORAGE -- record-specific
*/

    /**
    * See GET /records/{record_id}/apps/{app_id}/documents/
    *  Get metadata for all documents of a record.
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_GET(
            params:Object, 
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrlMeta:String= null;
        if (recordId == null) {
            requestUrlMeta = "apps/" + appId + "/documents/";
        } else {
            requestUrlMeta = "records/" + recordId + "/apps/" +
                appId + "/documents/";
        }
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlMeta, accessToken, accessTokenSecret, null, params, userData);
    }

    /**
    * GET /records/{record_id}/apps/{app_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_XGET(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            docId:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrl:String= null;
        if (recordId == null) {
            requestUrl = "apps/" + appId + "/documents/" + docId;
        } else {
            requestUrl = "records/" + recordId + "/apps/" +
                appId + "/documents/" + docId;
        }
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

    /**GET /records/{record_id}/apps/{app_id}/documents/{document_id}/meta
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_X_metaGET(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, appId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= null;
        if (recordId != null) {
            requestUrl = "records/" + recordId + "/apps/" + appId + "/documents/" + docId + "/meta";
        } else {
            requestUrl = "apps/" + appId + "/documents/" + docId + "/meta";
        }
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }
    
    /**
    *  See GET /records/{record_id}/apps/{app_id}/documents/external/{external_id}/meta.
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_external_X_metaGET(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            xId:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrlMeta:String= null;
        if (recordId == null) {
            requestUrlMeta = "apps/" + appId + "/documents/external/" + xId + "/meta";
        } else {
            requestUrlMeta = "records/" + recordId + "/apps/" +
                    appId + "/documents/external/" + xId + "/meta";
        }
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrlMeta, accessToken, accessTokenSecret, null, null, userData);
    }


    /**
    * see POST /records/{record_id}/apps/{app_id}/documents/
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML document to POST
    */
    public function apps_X_documents_POST(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            accessToken:String,
            accessTokenSecret:String,
            document:String):void {
        var requestURL:String= null;
        if (recordId == null) {
            requestURL =  "apps/" + appId + "/documents/";
        } else {
            requestURL = 
                "records/" + recordId + "/apps/" + appId + "/documents/";
        }
        phaRequest(
                consumerKey,
                consumerSecret,
                installationURL,
                "POST",
                requestURL, //"records/" + indivoRecordId + "/apps/" + appId + "/documents/",
                accessToken,
                accessTokenSecret,
                document);  // no URL params
    }

    /**
    * See PUT /records/{record_id}/apps/{app-id}/documents/external/{external_id}.
    *  add or overwrite app specific document with given external ID.
    *  Uses http PUT method.
    *  No equivalent non-app-specific method, as medical documents should
    *  not be overwritten.
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param xId external ID (application supplied ID)
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    * @param document XML document to POST
    */
    public function apps_X_documents_external_XPUT(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            xId:String,
            accessToken:String,
            accessTokenSecret:String,
            document:String):void {
        var request:String= null;//"records/" + indivoRecordId + "/apps/" + appId + "/documents/external/" + xtrnl;
        if (recordId == null) {
            request = "apps/" + appId + "/documents/external/" + xId;
        } else {
            request = "records/" + recordId + "/apps/" +
                    appId + "/documents/external/" + xId;
        }
        phaRequest(
                consumerKey, consumerSecret, installationURL,
                "PUT", request, accessToken, accessTokenSecret, document);
    }

    /**PUT /records/{record_id}/apps/{app_id}/documents/{document_id}/label
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param docId document ID
    * @param newLabel new label
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_X_labelPUT(consumerKey:String, consumerSecret:String, installationURL:String, recordId:String, appId:String, docId:String, newLabel:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= null;
        if (recordId == null) {
            requestUrl = "apps/" + appId + "/documents/" + docId + "/label";
        } else {
            requestUrl = "records/" + recordId + "/apps/" +
                appId + "/documents/" + docId + "/label";
        }
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "PUT", requestUrl, accessToken, accessTokenSecret, newLabel, null, userData);
    }
 
    /**DELETE /records/{record_id}/apps/{app_id}/documents/{document_id}
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param docId document ID
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_XDELETE(consumerKey:String, consumerSecret:String, installationURL:String,
        recordId:String, appId:String, docId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= null;
        if (recordId == null) {
            requestUrl = "apps/" + appId + "/documents/" + docId;
        } else {
            requestUrl = "records/" + recordId + "/apps/" +
                appId + "/documents/" + docId;
        }
//        String requestUrl = "records/" + recId + "/apps/" + appId + "/documents/" + docId;
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "DELETE", requestUrl, accessToken, accessTokenSecret, null, null, userData);
    }

	// TODO: fix JSON request methods and uncomment
	
//    /** GET /codes/systems/
//    *
//    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
//    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
//    * @param installationURL base URL of the Indivo server
//    * @param accessToken OAuth token for access to record
//    * @param accessTokenSecret OAuth token secret for access to record
//    */
//    public function codes_systems_GET(consumerKey:String, consumerSecret:String, installationURL:String, accessToken:String, accessTokenSecret:String, userData:Object=null):ArrayList {
//        var requestUrl:String= "/codes/systems/";
//        List<Map<String,String>> fromPhaRequest = phaRequestJSON( consumerKey, consumerSecret, installationURL,
//            "GET", requestUrl, null, accessToken, accessTokenSecret, null);
//    }
//
//    /** GET /codes/systems/{short_name}/query?q={query}
//    *
//    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
//    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
//    * @param installationURL base URL of the Indivo server
//    * @param params
//    * @param shortName
//    * @param accessToken OAuth token for access to record
//    * @param accessTokenSecret OAuth token secret for access to record
//    */
//    public function codes_systems_X_queryGET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String, shortName:String, accessToken:String, accessTokenSecret:String, userData:Object=null):ArrayList {
//        var requestUrl:String= "/codes/systems/" + shortName + "/query";
//        List<Map<String,String>> fromPhaRequest = phaRequestJSON( consumerKey, consumerSecret, installationURL,
//            "GET", requestUrl, params, accessToken, accessTokenSecret, null);
//    }

    
    /* SOME HIGHER LEVEL METHODS BUILT ON REST API,
    NAMED AS IF THERE WERE AN EQUIVALENT REST CALL BUT WITH _HL SUFFIX */
    
//    /**
//    * See GET /records/{record_id}/apps/{app_id}/documents/external/{external_id}/meta
//    * and GET /records/{record_id}/apps/{app_id}/documents/{document_id}<br/>
//    * This method first gets the metadata of the app specfic stored document of the given
//    * external ID, then gets the actual app specific stored document by its Indivo ID.
//    * return null if no such document found.
//    *
//    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
//    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
//    * @param installationURL base URL of the Indivo server
//    * @param recordId record ID
//    * @param appId application ID
//    * @param xId external ID (application supplied ID)
//    * @param accessToken OAuth token for access to record
//    * @param accessTokenSecret OAuth token secret for access to record
//    * @return the requested document, or null if no document of that
//    *    external Id exists.
//    */
//    public function apps_X_documents_external_XGET_HL(
//            consumerKey:String,
//            consumerSecret:String,
//            installationURL:String,
//            recordId:String,
//            appId:String,
//            xId:String,
//            accessToken:String,                                                                                                      
//            accessTokenSecret:String, userData:Object=null):void {
//        //need meta first!!!
//        var ofId:XML= null;
//        var xMeta:XML= null;
//        try {
//            xMeta = apps_X_documents_external_X_metaGET(
//                consumerKey, consumerSecret, installationURL,
//                recordId, appId, xId, accessToken, accessTokenSecret);
//        } catch (notfoundex:IndivoClientExceptionHttp404) {
//            logger.info("turning not found exception into null", notfoundex);
//        }
//
//        if (xMeta != null) {
//            var docEl:Element= xMeta.getDocumentElement();
//            if (! docEl.getTagName().equals("XML")) {
//                throw new IndivoClientException(
//                        "getAppDocumentXtrnlMeta returned document element with tag != 'XML'");
//            }
//                var docId:String= docEl.getAttribute("id");
//                ofId = apps_X_documents_XGET(
//                        consumerKey, consumerSecret, installationURL,
//                        recordId, appId, docId, accessToken, accessTokenSecret);
//        }
//        
//        return ofId;
//    }

    
/* type in url not supported by REST API, _HL indicates this is a higher lever method build on the REST API */
    /**
    * GET /records/{record_id}/apps/{app_id}/documents/types/{type_url}/
    *  Get all metadatas for all app specific stored documents of a type, of a record.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param appId application ID
    * @param type XML schema datatype, suffix to http://indivo.org/vocab/xml/documents#
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function apps_X_documents_types_X_GET_HL(
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            appId:String,
            type:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrlMeta:String= "records/" + recordId + "/apps/" +
                appId + "/documents/?types=" + type;
        phaRequest(
                consumerKey, consumerSecret, installationURL,
                "GET", requestUrlMeta, accessToken, accessTokenSecret, null, null, userData);
        //logger.info("metaFrom getAppDocumentsMetaType: " + domToString(metaFromPhaRequest));
    }

    
    

/* END APP SPECIFIC STORAGE */
    

    /** get the latest measurement of a type from an Indivo record
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * See GET /records/{record_id}/reports/minimal/measurements/{lab_code}/
    *
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param measType type of measurement
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function reports_minimal_measurements_X_GET(
            params:Object,
            consumerKey:String,
            consumerSecret:String,
            installationURL:String,
            recordId:String,
            measType:String,
            accessToken:String,
            accessTokenSecret:String,
			userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/reports/minimal/measurements/" + measType + "/";

        phaRequest(
                consumerKey, consumerSecret, installationURL,
                "GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
    }


    /** GET /records/{record_id}/reports/minimal/medications/ 
    * @param params becomes ?{query_string} at end of URL.
    *     See <b>params param</b> note in the class description, above.
    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
    * @param installationURL base URL of the Indivo server
    * @param recordId record ID
    * @param report type of report, must be one of: medications | allergies | immunizations | procedures | conditions | vitals
    * @param accessToken OAuth token for access to record
    * @param accessTokenSecret OAuth token secret for access to record
    */
    public function reports_minimal_X_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String,
            recordId:String, report:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
        var requestUrl:String= "records/" + recordId + "/reports/minimal/" + report + '/';
        phaRequest(
            consumerKey, consumerSecret, installationURL,
            "GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
    }    

	/** GET /records/{record_id}/shares/
	 * Entire records can be shared. The list of accounts with whom a record is shared can be obtained. 
	 * @param params becomes ?{query_string} at end of URL.
	 *     See <b>params param</b> note in the class description, above.
	 * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
	 * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
	 * @param installationURL base URL of the Indivo server
	 * @param recordId record ID
	 * @param accessToken OAuth token for access to record
	 * @param accessTokenSecret OAuth token secret for access to record
	 */
	public function shares_GET(params:Object, consumerKey:String, consumerSecret:String, installationURL:String,
							   recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):void {
		var requestUrl:String= "records/" + recordId + "/shares/";
		phaRequest(
			consumerKey, consumerSecret, installationURL,
			"GET", requestUrl, accessToken, accessTokenSecret, null, params, userData);
	}    
	
	/** Creates a new full-record share with an account 
	 * See POST /records/{record_id}/shares/
	 * account_id={account_id}&role_label={role_label}
	 *
	 * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
	 * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
	 * @param installationURL base URL of the Indivo server
	 * @param recordId record ID of the record to share
	 * @param accountId account ID to share the record with
	 * @param roleLabel The role_label is currently nothing more than that: a label. The label will come back in the XML for <Shares> 
	 * @param accessToken OAuth token for access to record
	 * @param accessTokenSecret OAuth token secret for access to record
	 */
	public function shares_POST(
		consumerKey:String,
		consumerSecret:String,
		installationURL:String,
		recordId:String,
		accountId:String,
		roleLabel:String,
		accessToken:String,
		accessTokenSecret:String,
		userData:Object=null):void
	{
		var requestData:String = URLUtil.objectToString({ account_id: accountId, role_label: roleLabel}, "&", true);
		phaRequest(
			consumerKey, consumerSecret, installationURL,
			"POST",
			"records/" + recordId + "/shares/",
			accessToken,
			accessTokenSecret,
			requestData, null, userData);  // no URL params
	}
	
	/** GET /records/{record_id}/owner
	 * Retrieves the account that owns the record. A successful response should be of the form:
	 *   <Account id="{account_id}"/>
	 * Example:
	 *   <Account id="ssmith@indivohealth.org"/>
	 * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
	 * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
	 * @param installationURL base URL of the Indivo server
	 * @param recordId record ID
	 * @param accessToken OAuth token for access to record
	 * @param accessTokenSecret OAuth token secret for access to record
	 */
	public function records_X_owner_GET(consumerKey:String, consumerSecret:String, installationURL:String,
							   recordId:String, accessToken:String, accessTokenSecret:String, userData:Object=null):IndivoRequestHandler {
		var requestUrl:String= "records/" + recordId + "/owner";
		return phaRequest(
			consumerKey, consumerSecret, installationURL,
			"GET", requestUrl, accessToken, accessTokenSecret, null, null, userData);
	}    
	
    /* PHA version of ADMIN SETUP */
//    /**
//    * see: POST /records/{record_id}/apps/{app_id}/setup
//    * @param consumerKey OAuth consumer key, assigned to your application by the Indivo service provider
//    * @param consumerSecret OAuth consumer secret, assigned to your application by the Indivo service provider
//    * @param installationURL base URL of the Indivo server
//    * @param recordId record ID
//    * @param otherAppId application ID of other application to get access token
//    * @param accessToken OAuth token for access to record
//    * @param accessTokenSecret OAuth token secret for access to record
//        URLRequest fromAdminRequest = null;
//        fromAdminRequest = adminRequest(
//                "records/" + recordId + "/apps/"
//                + /+AuthUtils.encode(+/phaId/+)  I recommend that, for now, Nate use the '@' in a raw way in the URL, so that it gets singly-encoded to %40. It's a minor violation, not a terrible one. We'll fix it later. Ben+/
//                + "/setup", null);
//        String plainStr1 = icHttp.processIndivoResultPlain(fromAdminRequest);
//        String[] tokenSecret = icHttp.tokenSecretFromHttpResponse(plainStr1);
//    */
//    public function apps_X_setupPOST(
//            consumerKey:String,
//            consumerSecret:String,
//            installationURL:String,
//            recordId:String,
//            otherAppId:String,
//            accessToken:String,
//            accessTokenSecret:String, userData:Object=null):ArrayCollection {
//        var requestUrl:String= "records/" + recordId + "/apps/" + otherAppId + "/setup";
//        var fromTokenRequest:Array= null;
//        var urlRequest:URLRequest= null;
//        var indivoContent:Object= null;
//        
//        var adminURLString:String= null;
//        if (installationURL == null) {
//            adminURLString = phaBase + requestUrl;
//        } else {
//            adminURLString = installationURL + requestUrl;
//        }
//        
//		var signParams:HashMap = new HashMap();
//        urlRequest = phaAdminUtils.setupConnection(
//                "POST", adminURLString, "", signParams, null);
//        
//        signWithSignpost(urlRequest, consumerKey, consumerSecret, accessToken, accessTokenSecret);
//        
//        /*
//        HttpRequest httpRequest = new HttpRequestAdapter(urlRequest);
//        oauthConsumer.setTokenWithSecret(accessToken, accessTokenSecret);
//        try {
//            oauthConsumer.sign(httpRequest);
//        } catch (OAuthMessageSignerException omse) {
//            throw new IndivoClientException(omse);
//        } catch (OAuthExpectationFailedException oefe) {
//            throw new IndivoClientException(oefe);
//        }
//*/
//        var plainStr1:String= phaAdminUtils.processIndivoResultPlain(urlRequest);
//        Map<String,String> tokenSecret = phaAdminUtils.mapFromHttpResponse(plainStr1);
//
//        logger.info("PHA setup token: " + tokenSecret.get("oauth_token")
//                + "  --  secret: " + tokenSecret.get("oauth_token_secret"));
//        return tokenSecret;
//    }

    
    
//    /**
//    * Convenience method for 9 argument method where there
//    * is to be no query string,
//    * and consumer token/secret and installationURL were supplied by Pha
//    * constructor.
//    */
//    public function phaRequest(
//            reqMeth:String,
//            relativePath:String,
//            token:String,
//            secret:String,
//            requestXml:String):XML {
//       return phaRequest(reqMeth, relativePath, null, token, secret, requestXml);
//    }
//    /**
//    * Convenience method for 9 argument method when
//    * query string may be present,
//    * and consumer token/secret and installationURL were supplied by Pha
//    * constructor.
//    */
//    public function phaRequest(
//            reqMeth:String,
//            relativePath:String,
//            params:Object,
//            token:String,
//            secret:String,
//            requestXml:String):XML {
//       return phaRequest(null, null, null,
//                reqMeth, relativePath, params, token, secret, requestXml);
//    }
//    /**
//    * Convenience method for 9 argument method
//    * where query string is not present,
//    * and consumer token/secret and installationURL are not the defaults provided by the
//    * constructor.
//    */
//    public function phaRequest(
//            consumerToken:String,
//            consumerSecret:String,
//            foreignURL:String,
//        
//            reqMeth:String,
//            relativePath:String,
//            phaToken:String,
//            phaTokenSecret:String,
//            requestXml:String):XML {
//       return phaRequest(consumerToken, consumerSecret, foreignURL,
//                reqMeth, relativePath, null, phaToken, phaTokenSecret, requestXml);
//    }
    
    
    /**
    * General wrapper for all Indivo PHA REST calls, where
    * URL params are to be added.  Most applications will not
    * use this, the more specific methods are recommended.
    * This more general method might be useful, for example,
    * where requests of various types are generated dynamically.
    *
    * @param consumerToken can be <code>null</code> if 3 arg Pha constructor used.
    * @param consumerSecret can be <code>null</code> if 3 arg Pha constructor used.
    * @param foreignURL can be <code>null</code> if 3 arg Pha constructor used.
    *
    * @param reqMeth POST, GET, or .....
    * @param relativePath as documented at <code>http://wiki.chip.org/indivo</code>
    * @param params part of URL following '?', but not including '?'
    *     See <b>params param</b> note in the class description, above.
    * @param phaToken authorized request token
    * @param phaTokenSecret authorized request token secret
    * @param requestXml document to add, or null
    */
    public function phaRequest(
            consumerToken:String,
            consumerSecret:String,
            foreignURL:String,
            reqMeth:String,
            relativePath:String,
            phaToken:String,
            phaTokenSecret:String,
            requestXml:String,
			params:Object = null,
			userData:Object = null):IndivoRequestHandler
	{
		relativePath = phaAdminUtils.removeLeadingSlash(relativePath);
    
        if (getTestMode() == 1)
		{
			var inputString:String = new String(
				"<rest>" + reqMeth + " /" + relativePath.replace("&","&amp;") + "</rest>");
	
			this.dispatchEvent(new IndivoClientEvent(new XML(inputString), null, userData)); 
        }
        
        var urlRequest:URLRequest= phaRequestPart1(
            consumerToken, consumerSecret, foreignURL,
            reqMeth, relativePath, params, phaToken, phaTokenSecret, requestXml);
		
		var handler:IndivoRequestHandler = new IndivoRequestHandler(this, this.phaAdminUtils);
		handler.handle(urlRequest, userData);
		return handler;
//        return phaAdminUtils.docFromConnection(urlRequest);
    }
    
    public function phaRequestJSON(
            consumerToken:String,
            consumerSecret:String,
            foreignURL:String,
            reqMeth:String,
            relativePath:String,
            params:Object,
            phaToken:String,
            phaTokenSecret:String,
            requestXml:String):void {
    
        if (getTestMode() == 1) {
                var hasOneMap:ArrayList = new ArrayList();
                var onlyMap:HashMap = new HashMap();
                onlyMap.put("rest", reqMeth + " " + relativePath.replace("&","&amp;"));
                hasOneMap.addItem(onlyMap);
//                return hasOneMap;
				// TODO: what kind of event should we dispatch for JSON?
				this.dispatchEvent(new IndivoClientEvent(new XML(onlyMap.toString()), null, null)); 
        }
        
        var urlRequest:URLRequest= phaRequestPart1(
            consumerToken, consumerSecret, foreignURL,
            reqMeth, relativePath, params, phaToken, phaTokenSecret, requestXml);
		
		// TODO: use a different event handler or some other means of ensuring that the response data is formatted as JSON 
        
//        return jsonFromConnection(urlRequest);

		var handler:IndivoRequestHandler = new IndivoRequestHandler(this, this.phaAdminUtils);
		handler.handle(urlRequest, null);
    }
    
//    function jsonFromConnection(urlRequest:URLRequest):ArrayList {
//        var cnctnData:String= phaAdminUtils.dataFromConnection(urlRequest);
//        var gson:Gson= new Gson();
//        var listMapStringString:Type= (new TypeToken()).getType();
//        var retVal:ArrayList = gson.fromJson(cnctnData, listMapStringString);
//        return retVal;
//    }

    
    private function phaRequestPart1(
            consumerToken:String,
            consumerSecret:String,
            foreignURL:String,
        
            reqMeth:String,
            relativePath:String,
            params:Object,
            phaToken:String,
            phaTokenSecret:String,
            requestXml:String):URLRequest
	{
        logger.info("relativePath, requestXml: " + relativePath + '\n' + requestXml + "\n\n");

		var queryString0:String = getQueryStringFromParams(params);
		
        var phaBase0:String= phaBase;
        if (foreignURL != null) {
            phaBase0 = foreignURL;
        }

        logger.info("phaAdminUtils: " + phaAdminUtils
            + " -- phaBase0: " + phaBase0
            + " -- relativePath: " + relativePath
            + " -- queryString: " + queryString0);
        var phaURLString:String= phaBase0 + relativePath;

		var contentType:String= null;
		if (requestXml != null && requestXml.length > 0) {
			if (requestXml.charAt(0) == '<') {
				contentType = "application/xml";
			} else if (requestXml.indexOf("=") >= 1) {
				contentType = "application/x-www-form-urlencoded";
			}
		}
		
        var urlRequest:URLRequest= phaAdminUtils.setupConnection(
                reqMeth, phaURLString, queryString0, null, contentType);
        
		phaAdminUtils.prepareRequest(urlRequest, requestXml);

		phaAdminUtils.signWithSignpost(urlRequest, consumerToken, consumerSecret, phaToken, phaTokenSecret);
/*
        HttpRequest httpRequest = new HttpRequestAdapter(urlRequest);
        oauthConsumer.setTokenWithSecret(phaToken, phaTokenSecret);
        //long thenonce = 0;
        try {
            oauthConsumer.sign(httpRequest);
            //thenonce = ((oauth.signpost.AbstractOAuthConsumer) oauthConsumer).publicnonce;
        } catch (OAuthMessageSignerException omse) {
            throw new IndivoClientException(omse);
        } catch (OAuthExpectationFailedException oefe) {
            throw new IndivoClientException(oefe);
        }
*/
//        try {
//            if (requestXml != null) {
//                var os:OutputStream= urlRequest.getOutputStream();
//                
//                os.write(requestXml.getBytes());
//                logger.info("requestXml: " + requestXml);
//                os.close();
//            }
//        } catch (ioe:IOException) {
//            throw new IndivoClientException(ioe);
//        }
        
        return urlRequest;
    }

	public static function getQueryStringFromParams(params:Object):String
	{
		var queryString0:String;
		if (params == null) {
			queryString0 = "";
		} else if (params is String) {
			var qsString:String= String(params);
			if (qsString.indexOf('=') < 1) {
				throw new IndivoClientException(
					"unexpected params, did not have any key/value delimiter of '=': " + params);
			}
			queryString0 = qsString;
		} else if (params is HashMap) {
			var qsBuff:String = new String();
			var qsMap:HashMap= HashMap(params);
			for (var keyObj:Object in qsMap.keys)
			{
				//			var iter:Iterator= qsMap.keySet().iterator();
				//        	while (iter.hasNext()) {
				if (qsBuff.length > 0) { qsBuff += '&'; }
				
				//                var keyObj:Object= iter.next();
				if (! (keyObj is String)) {
					throw new IndivoClientException("params map key of unexpected type: "
						+ keyObj.getClass().getName() + " -- " + keyObj);
				}
				var key:String= String(keyObj);
				
				var valueObj:Object= qsMap.get(key);
				//                try {
				if (valueObj is String) {
					qsBuff += URLEncoding.utf8Encode(key) + '=' + URLEncoding.utf8Encode(String(valueObj));
				} else if (valueObj is Array) {
					var valueArr:Array= valueObj as Array;
					for (var ii:int= 0; ii < valueArr.length; ii++) {
						qsBuff += URLEncoding.utf8Encode(key) + '=' + URLEncoding.utf8Encode(valueArr[ii]);
					}
				} else {
					throw new IndivoClientException("params map value of unexpected type: "
						+ valueObj.getClass().getName() + " -- " + valueObj);
				}
				//                } catch (uee:java.io.UnsupportedEncodingException) {
				//                    throw new IndivoClientException(uee);
				//                }
			}
			queryString0 = qsBuff.toString();
		}
		else if (params is URLVariables)
		{
			queryString0 = URLVariables(params).toString();	
		} else {
			throw new IndivoClientException(
				"params not String or Map, type is: " + params.getClass().getName());
		}
		return queryString0;
	}
    
    private function paramsFromString(query:String):HashMap
            {
        var retVal:HashMap = new HashMap();
        if (query != null && query.length > 0) {
            var splits:Array= query.split("&");
            for (var ii:int= 0; ii < splits.length; ii++) {
                var aSplt:String= splits[ii];
                var eix:int= aSplt.indexOf('=');
                if (eix < 1) {
                    throw new IndivoClientException("no '=' in query param: " + query);
                }
                var key:String= aSplt.substring(0, eix);
                var val:String= aSplt.substring(eix +1);
                var prior:Array= retVal.get(key);
                if (prior == null) {
                    prior = new String[1];
                }
                else {
                    var priorOld:Array= prior;
                    prior = new String[prior.length +1];
                    for (var jj:int= 0; jj < priorOld.length; jj++) {
                        prior[jj] = priorOld[jj];
                    }
                }
                prior[prior.length -1] = val;
                retVal.put(key, prior);
            }
        }
        return retVal;
    }


//    /**
//    *  Given a document containing a list of metadata ("XML")
//    * elements, return a list of just the document Id-s.
//    * @param hasMetas the document with document element tag of
//    *     <code>&lt;Documents&gt;</code>
//    */
//    public function utilDocIdsFromMetas(hasMetas:XML):ArrayList {
//		var retVal:ArrayList = new ArrayList();
//        var docElem:Element= hasMetas.getDocumentElement();
//        var deNL:NodeList= docElem.getElementsByTagName("XML");
//        for (var ii:int= 0; ii < deNL.getLength(); ii++) {
//            var docEl:Element= Element(deNL.item(ii));
//            var docId:String= docEl.getAttribute("id");
//            retVal.add(docId);
//        }
//        return retVal;
//    }
    
    
    public function domToString(theDoc:XML):String {
//        return domToString(theDoc, theDoc);
		return theDoc.toString();
    }   
	// TODO: synchronized equivalent for action script?
	//public synchronized function domToString(theDoc:XML, theNode:Node):String {
//    public function domToString(theDoc:XML, theNode:XMLNode):String {
//        var domI:DOMImplementation= theDoc.getImplementation();
//        var domIls:DOMImplementationLS= DOMImplementationLS(domI.getFeature("LS", "3.0"));
//        var lss:LSSerializer= domIls.createLSSerializer();
//        var xmlstr:String= lss.writeToString(theNode);
//        //<?xml version="1.0" encoding="UTF-16"?>
//        return xmlstr;
//    }

    private function signWithSignpost(
            urlRequest:URLRequest,
            consumerKey0:String,
            consumerSecret0:String,
            accessToken:String,
            accessTokenSecret:String):void {
    
         var consumerKey:String= null;
         var consumerSecret:String= null;
         if (consumerKey0 == null) {
             consumerKey = instanceConsumerKey;
             consumerSecret = instanceConsumerSecret;
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
		 
		 var oauthConsumer:OAuthConsumer = new OAuthConsumer(consumerKey, consumerSecret);
		 var oauthToken:OAuthToken = new OAuthToken(accessToken, accessTokenSecret);
		 var oauthRequest:OAuthRequest = new OAuthRequest(urlRequest.method, urlRequest.url, urlRequest.data, oauthConsumer, oauthToken);
		 var requestHeader:URLRequestHeader = oauthRequest.buildRequest(new OAuthSignatureMethod_HMAC_SHA1(), OAuthRequest.RESULT_TYPE_HEADER);
		 
		 urlRequest.requestHeaders.push(requestHeader);
    }

    private function logConnectionHeaders(urlRequest:URLRequest):void {
//        var key:String= null;
//        var field:String= urlRequest.getHeaderField(0);
//        var ii:int= 0;
//        while (field != null) {
//            key = urlRequest.getHeaderFieldKey(ii);
		for (var headerObj:Object in urlRequest.requestHeaders)
		{
			var header:URLRequestHeader = URLRequestHeader(headerObj); 
			var key:String = header.name
			var field:String = header.value;
            logger.info("header field from Indivo -- " + key + " : " + field);
//            ii++;
//            field = urlRequest.getHeaderField(ii);
        }
    }
  
    public function defaultURL():String { return this.phaBase; }
    
    public override function toString():String {
        return  getQualifiedClassName(this) + ": " + this.instanceConsumerKey
            + "; " + this.instanceConsumerSecret + "; " + this.phaBase;
    }
}
}