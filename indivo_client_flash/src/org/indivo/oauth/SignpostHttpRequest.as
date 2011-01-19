package org.indivo.oauth {

/**
* HttpRequestAdapter returns null from its getMessagePayload().
* use this if payload has params that need to go in the signature base string.
*/
//public class SignpostHttpRequest extends HttpRequestAdapter {
public class SignpostHttpRequest {
//    
//    private var payload:String= null;
//
//    /**
//    * @param connection same as for super class constructor.
//    * @param payload the form encoded params.  This class does nothing to
//    *    actually send the payload, just allows its contents to be included
//    *    in building the signature base string.  You must still send the payload
//    *    after signing the request.
//    */
//    public function SignpostHttpRequest(connection:URLRequest, payload:String) {
//        super(connection);
//        this.payload = payload;
//    }
//    
//    /** overrides getMessagePayload() of HttpRequestAdapter */
//    public function getMessagePayload():java.io.InputStream {
//        return new ByteArrayInputStream(payload.getBytes());
//    }
}
}