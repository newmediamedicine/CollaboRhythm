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
//import java.util.Map;
//
//import org.w3c.dom.XML;
//import org.w3c.dom.Element;
//import org.w3c.dom.NodeList;
//
//import org.indivo.client.Admin;
//import org.indivo.client.Pha;


/**
*  Example for using org.indivo.client.Admin and org.indivo.client.Pha.
*  To run this example, edit then use indivo_client_java/examples/runTest.sh
*/
public class AdminExample {
//
//    private var consumerKey:String;
//    private var consumerSecret:String;
//    private var baseURL:String;
//    private var admin:Admin;
//
//    
//    public function AdminExample(consumerKey:String, consumerSecret:String, baseURL:String) {
//        this.consumerKey = consumerKey;
//        this.consumerSecret = consumerSecret;
//        this.baseURL = baseURL;
//        try {
//            admin = new Admin(consumerKey, consumerSecret, baseURL);
//        } catch (exc:Error) {
//            throw new RuntimeException(exc);
//        }
//    }
//    
//    
//    /** main is Strictly for use as an example or a test.
//    * See indivo_client_java/runExample.sh for how to run this example.
//    */
//    public static function main(args:Array):void {
//        var Example:AdminExample= null;
//
//        // to run this test, you must have a consumerKey, consumerSecret from 
//        if (args.length != 7) {
//            throw new RuntimeException(
//                    "usage: org.indivo.Example <adminConsumerKey> <adminConsumerSecret> "
//                    + "<appConsumerKey> <appConsumerSecret> <server_base_url> <adminId> <appId>");
//        }
//        
//        // construct an instance with the consumerKey/secret and baseURL
//        var example:AdminExample= new AdminExample(args[0], args[1], args[4]);
//        
//        // run the example
//        example.runExample(args[2], args[3], args[4], args[5], args[6]);
//    }
//    
//    private function runExample(appConsumerKey:String, appConsumerSecret:String, baseURL:String, adminId:String, appId:String):void {
//        var fromIndivo:XML= null;
//        try {
//var idoc:String=
//"<Demographics xmlns=\"Demographics\">"
//+ "<name><fullname>nameForTestDocument</fullname><givenName/><familyName/></name>"
//+ "<email><emailType/><emailAddress>abc@def.ghi</emailAddress></email>"
//+ "<address><addressType/><streetAddress/><postalCode>" + "99999"
//+   "</postalCode><locality/><region/><country/><timeZone/></address>"
//+ "<tumbnail/>"
//+ "</Demographics>";
//
//            // create record with an external ID
//            fromIndivo = admin.records_external_X_XPUT(adminId, "xtrnalrecid", idoc);
//            System.out.println("fromIndivo: " + admin.getAdminUtils().domToString(fromIndivo));
//            
//            var docElem:Element= fromIndivo.getDocumentElement();
//            var recordId:String= docElem.getAttribute("id");
//            System.out.println("Indivo ID of record: " + recordId);
//
//            // authorize appId as an app to access the record
//            Map<String,String> fromAuth = admin.records_X_apps_X_setupPOST(recordId, appId);
//            
//            System.out.println("authorized: oauth_token: " + fromAuth.get("oauth_token")
//                + ", oauth_token_secret: " + fromAuth.get("oauth_token_secret") + " for"
//                + " recordId: " + recordId);
//
//            //Pha pha = new Pha(appConsumerKey, appConsumerSecret, baseURL);
//            
//            // now run the Personal Health Application test
//            var mainParam:Array= new String[6];
//            mainParam[0] = appConsumerKey;
//            mainParam[1] = appConsumerSecret;
//            mainParam[2] = baseURL;
//            mainParam[3] = fromAuth.get("oauth_token");
//            mainParam[4] = fromAuth.get("oauth_token_secret");
//            mainParam[5] = recordId;
//            examples.PhaExample.main(mainParam);
//        
//        } catch (exc:Error) {
//            throw new RuntimeException(exc);
//        }
//    }
}
}