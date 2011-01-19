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

import j2as3.collection.HashMap;

//import org.indivo.client.IndivoClientException;
//import org.indivo.client.Pha;


public class PhaExample {
//
//    private static var instance:PhaExample= null;
//
//    private var pha:Pha= null;
//    
//    public function PhaExample(consumerKey:String, consumerSecret:String, baseURL:String) {
//        this.pha = new Pha(consumerKey, consumerSecret, baseURL);
//    }
//
//    /**
//    *  $ java examples.PhaExample -cp &lt;classpath&gt; examples.PhaExample \
//    *       &lt;consumerKey&gt; &lt;consumerSecret&gt; &lt;indivoServerURL&gt;
//    *       &lt;token&gt; &lt;secret&gt; &lt;recordId&gt;
//    */
//    public static function main(params:Array):void {
//        instance = new PhaExample(params[0], params[1], params[2]);
//        instance.runTest(params[3], params[4], params[5]);
//    }
//
//    public function runTest(token:String, secret:String, recordId:String):HashMap {
//        var appDocToAdd:String= "<notReallyAMedicalDocument/>";
//        var addResult:XML= null;
//        var docMetaDoc:XML= null;
//        var addedId:String= null;
//        var numberOfDocs:int= 0;
//        try {
//            addResult = pha.documents_POST(recordId, token, secret, appDocToAdd);
//            var resultE:Element= addResult.getDocumentElement();
//            if (! resultE.getTagName().equals("XML")) {
//                throw new RuntimeException("expected return of ''<XML....''");
//            }
//            addedId = resultE.getAttribute("id");
//            System.out.println(pha.domToString(addResult));
//            
//            docMetaDoc = pha.documents_GET(null, recordId, token, secret);
//            resultE = docMetaDoc.getDocumentElement();
//            var nl:NodeList= resultE.getElementsByTagName("XML");
//            numberOfDocs = nl.getLength();
//            System.out.println(pha.domToString(docMetaDoc));
//        } catch (ice:IndivoClientException) {
//            throw new RuntimeException(ice);
//        }
//        
//        //<XML id="1acc8d19-1150-43d5-8a72-31f435faba37" type=""/>
//        var dEl:Element= addResult.getDocumentElement();
//        var retVal:HashMap = new HashMap();
//        retVal.put("documentAdded", addedId);
//        retVal.put("numberOfDocs", "" + numberOfDocs);
//        retVal.put("recordId", recordId);
//        return retVal;
//    }
}
}