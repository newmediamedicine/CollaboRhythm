package org.indivo.client {
/**
*  Use this to mark an IndivoClientException as caused by HTTP 404 exception.
*  In some cases, 404 is among the possible expected results, not an error.
*/
public class IndivoClientExceptionHttp404 extends IndivoClientException {
    private static var serialVersionUID:Number= 1;

    
//    public function IndivoClientExceptionHttp404(thrwbl:Throwable) {
//        super(thrwbl);
//    }
    public function IndivoClientExceptionHttp404(msg:String, thrwbl:Error) {
        super(msg, thrwbl);
    }
//    public function IndivoClientExceptionHttp404(msg:String) {
//        super(msg);
//    }
}
}