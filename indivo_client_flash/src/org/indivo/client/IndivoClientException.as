package org.indivo.client {
public class IndivoClientException extends Error {
    private static var serialVersionUID:Number= 1;

    
//    public function IndivoClientException(thrwbl:Throwable) {
//        super(thrwbl);
//    }
    public function IndivoClientException(msg:String, thrwbl:Error = null) {
        super(msg, thrwbl);
    }
//    public function IndivoClientException(msg:String) {
//        super(msg);
//    }
}
}