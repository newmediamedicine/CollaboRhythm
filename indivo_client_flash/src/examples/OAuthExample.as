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
package examples {
//import j2as3.collection.HashMap;
//
//import java.io.IOException;
//import java.security.GeneralSecurityException;
//import java.util.Date;
//import java.util.HashMap;
//import java.util.Map;
//
//import javax.servlet.ServletException;
//import javax.servlet.ServletOutputStream;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.indivo.client.Admin;
//import org.indivo.client.IndivoClientException;
//import org.indivo.client.Pha;
//import org.indivo.client.PhaAdminUtils;
//import org.indivo.oauth.AuthUtils;
//import org.w3c.dom.XML;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//
///**
//*  Example for using org.indivo.client.Admin and org.indivo.client.Pha.
//*  To run this example, see indivo_client_java/examples/runTest.sh
//*/
////public class OAuthExample extends HttpServlet {
public class OAuthExample {
//    private static var serialVersionUID:Number= 1;
//    private var logger:Log= null;
//
//    private var consumerKey:String;
//    private var consumerSecret:String;
//    //private String baseURL;
//    private var admin:Admin;
//    private var phaAdminUtils:PhaAdminUtils;
//    //private String indivoServerURL;
//    private var indivoAPI_URL:String;
//    private var indivoUI_URL:String;
//    
//    private var authStartPath:String;
//    private var authAfterPath:String;
//
//    private var savedSecrets:HashMap;
//
//    private var recordId:String;
//    
//    public function init():void {
//        logger = LogFactory.getLog(this.getClass());
//        
//        indivoAPI_URL = getInitParameter("indivoAPI_URL");
//        indivoUI_URL = getInitParameter("indivoUI_URL");
//        
//        //if (true) { throw new RuntimeException("abc"); }
//        //indivoServerURL = getInitParameter("indivoServerURL");
//        authStartPath = getInitParameter("authStartPath");
//        authAfterPath = getInitParameter("authAfterPath");
//        consumerKey = getInitParameter("consumerKey");
//        consumerSecret = getInitParameter("consumerSecret");
//        savedSecrets = new HashMap();
//        try {
//            phaAdminUtils = new PhaAdminUtils(consumerKey, consumerSecret);
//        } catch (ice:IndivoClientException) {
//            throw new ServletException(ice);
//        }
//    }
//    
//    public function doGet(req:HttpServletRequest, resp:HttpServletResponse):void {
//        resp.setContentType("text/html;charset=UTF-8");
//        var pathInfo:String= req.getPathInfo();
//        var paramMap:HashMap = req.getParameterMap();
//        
//        if (pathInfo == null) {
//            throw new ServletException("no path info following " + req.getServletPath() +
//                    ". Expected 'auth/start' or 'auth/after'");
//        }
//        if (pathInfo.equals(authStartPath)
//                || (pathInfo.charAt(0) == '/' && pathInfo.substring(1).equals(authStartPath)) ) {   //"/auth/start"
//            
//            // ask Indivo server for a request token for the record
//            // this map will have request token and secret, but NOT recordId
//            // record ID is not returned until user has actually authorized
//            Map<String,String> requestTokenSecret = getRequestToken();
//
//            var oauth_callback_confirmed:String= requestTokenSecret.get("oauth_callback_confirmed");
//            if (oauth_callback_confirmed == null) {
//                logger.warn("oauth_callback_confirmed not present along with request token");
//            }
//            else if (! oauth_callback_confirmed.equals("true")) {
//                throw new ServletException("oauth_callback_confirmed=" + oauth_callback_confirmed
//                        + " request_token:" +  requestTokenSecret.get("oauth_token"));
//            }
//            
//            savedSecrets.put(
//                    requestTokenSecret.get("oauth_token"),
//                    requestTokenSecret.get("oauth_token_secret")
//            );
//            
//            try {
//                //User Authorization URL: https://INDIVO_SERVER/oauth/authorize
//                resp.sendRedirect(resp.encodeRedirectURL(
//                        indivoUI_URL + "oauth/authorize?oauth_token="
//                        + requestTokenSecret.get("oauth_token") ));
//            } catch (ioe:IOException) {
//                throw new ServletException(ioe);
//            }
//            
//            var response:String= "<html><head><title></title></head><body>"
//                    + "<p>If not promptly redirected to " + indivoUI_URL
//                    + "get help from your Indivo installation.</p>"
//                    + "</body></html>";
//            try {
//                var respOut:ServletOutputStream= resp.getOutputStream();
//                respOut.println(response);
//            } catch (ioe:IOException) { throw new ServletException(ioe); }
//        }
//
//        // request token authorization is complete (either success or failure)
//        else if (pathInfo.equals(authAfterPath)
//                || (pathInfo.charAt(0) == '/' && pathInfo.substring(1).equals(authAfterPath)) ) {   //"/auth/after"
//            var token:String= getStringFromPmap(paramMap, "oauth_token");
//            var verifier:String= getStringFromPmap(paramMap, "oauth_verifier");
//            var savedSecret:String= savedSecrets.remove(token);
//            
//            // this map DOES have recordID (along with authorized token and secret) if user in fact authorized
//            // when user has authorized, recordId may be given out
//            Map<String,String> authorizedTokenSecret = getAuthorizedToken(token, savedSecret, verifier);
//
//            var response:String= "<html><head><title></title></head><body>"
//                    + "<p>Authorization is complete<br/>use the below token and secret values "
//                    + "when running PhaTest from the command line or via this servlet<br/><code>"
//                    + "$ java -cp .... examples.PhaExample &lt;token&gt; &lt;secret&gt; &lt;record_id&gt;</code></p>"
//                    + "<strong>token: </strong><span style='background-color:#ccffff'>"
//                    + authorizedTokenSecret.get("oauth_token") + "</span><br/>"
//                    + "<strong>secret: </strong><span style='background-color:#ccffff'>"
//                    + authorizedTokenSecret.get("oauth_token_secret") + "</span><br/>"
//                    + "<strong>authorized for recordId: </strong><span style='background-color:#ccffff'>"
//                    + authorizedTokenSecret.get("xoauth_indivo_record_id") + "</span><p>"
//                    + "<strong>To run the Pha example from this servlet: </strong><br/><span style='font-size:large'>"
//                    + req.getScheme() + "://" + req.getServerName() + ':' + req.getServerPort()
//                    + req.getContextPath() + req.getServletPath()
//                    + "/runPhaExample/" + authorizedTokenSecret.get("oauth_token")
//                    + '/' + authorizedTokenSecret.get("oauth_token_secret")
//                    + '/' + authorizedTokenSecret.get("xoauth_indivo_record_id")
//                    + "</span></p></body></html>";
//            try {
//                var respOut:ServletOutputStream= resp.getOutputStream();
//                respOut.println(response);
//            } catch (ioe:IOException) { throw new ServletException(ioe); }
//        }
//
//        // run the PhaExample using the most recent authorization
//        else if (pathInfo.startsWith("/runPhaExample/")) {
//            var pathInfoA:Array= pathInfo.substring(1).split("/");
//            if (pathInfoA.length != 4) {
//                var errMsgP2:String= "";
//                for (var ii:int= 0; ii < pathInfoA.length; ii++) {
//                    errMsgP2 += "\n" + pathInfoA[ii];
//                }
//                throw new ServletException(
//                        "expected ''<path_to_servlet>/runPhaExample/<authorizedToken>/<tokenSecret>/<recordId>''\n"
//                        + "got: " + errMsgP2);
//            }
//            var authToken:String= pathInfoA[1];
//            var authSecret:String= pathInfoA[2];
//            var authForRec:String= pathInfoA[3];
//            
//            
//            
//            
//            // FOR ONE-TIME TEST ONLY
//            var testPha:Pha= null;
//            var tres:XML= null;
//            try {
//                testPha = new Pha(consumerKey, consumerSecret, indivoAPI_URL);
//                tres = testPha.reports_minimal_X_GET(null, authForRec, "vitals", authToken, authSecret);
//            } catch (tice:IndivoClientException) { throw new ServletException(tice); }
//            logger.info(testPha.domToString(tres));
//
//
//            
//            
//            var phaExample:PhaExample= new PhaExample(consumerKey, consumerSecret, indivoAPI_URL);
//            Map<String,String> result = phaExample.runTest(authToken, authSecret, authForRec);
//            try {
//                var respOut:ServletOutputStream= resp.getOutputStream();
//                respOut.println(
//                    "<html><head><title></title></head><body>"
//                    + "<p><strong>Success</strong></p><p>"
//                    + "you added document of ID: <b>" + result.get("documentAdded")
//                    + "</b> to record of ID: <b>" + result.get("recordId")
//                    + "</b>.<br/>There are now <b>"
//                    + result.get("numberOfDocs") + "</b> documents in the record."
//                    + "</p></body></html>"
//                );
//            } catch (ioe:IOException) { throw new ServletException(ioe); }
//        }
//        
//        else {
//            throw new ServletException("unexpected path info: " + pathInfo
//                    + ".  must match value of match web.xml init-param named authStartPath:  " + authStartPath
//                    + " or value of match web.xml init-param named authAfterPath:" + authAfterPath
//                    + " or ''/runPhaExample''");
//        }
//    }
//
//    private function getRequestToken():HashMap {
//        var tokenSecret:HashMap = null;
//        try {
//            var hasTextResponse:String= phaAdminUtils.postRequestForString(
//                    this.consumerKey,
//                    this.consumerSecret,
//                    null,  // two-legged oauth call to get the request token
//                    null,  // two-legged oauth call to get the request token
//                    indivoAPI_URL + "oauth/request_token",
//                    null,  // no additional oauth params
//
//                    // the indivo installation must already know about you, must already know
//                    // where to call back when the authorization process is complete
//                    "oauth_callback=oob"
//                    );
//
//            // this map will have request token and secret, but NOT recordId
//            // record ID is not returned until user has actually authorized
//            tokenSecret = phaAdminUtils.mapFromHttpResponse(hasTextResponse);
//        } catch (ice:IndivoClientException) {
//            throw new ServletException(ice);
//        }
//        
//        return tokenSecret;
//    }
//
//    private function getAuthorizedToken(requestToken:String, requestSecret:String, verifier:String):HashMap {
//        var tokenSecret:HashMap = null; 
//        try {
//            var hasTextResponse:String= phaAdminUtils.postRequestForString(
//                this.consumerKey,
//                this.consumerSecret,
//                requestToken,
//                requestSecret,
//                indivoAPI_URL + "oauth/access_token",
//                null,
//                "oauth_verifier=" + verifier);
//
//            // this map DOES have recordID (along with authorized token and secret) if user in fact authorized
//            // when user has authorized, recordId may be given out
//            tokenSecret = phaAdminUtils.mapFromHttpResponse(hasTextResponse);
//        } catch (ice:IndivoClientException) {
//            throw new ServletException(ice);
//        }
//        
//        return tokenSecret;
//    }
//
//    private function getStringFromPmap(pmap:HashMap, key:String):String {
//        try {
//            return AuthUtils.getStringFromPmap(pmap,key); // FIXME for authorizedReqSec
//        } catch (nde:GeneralSecurityException) {
//            throw new ServletException(nde);
//        }
//    }
//
//
}
}