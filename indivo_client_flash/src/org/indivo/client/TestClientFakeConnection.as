package org.indivo.client {

/**
*  This is a class of dummy connections used to test REST clients without
*  having to connect them to an actual Indivo installation.
*/
//class TestClientFakeConnection extends URLRequest {
internal class TestClientFakeConnection {

    private var inputText:String= null;
    private var contentType:String= null;
    
    /** create a "connection" that will "receive" the given text */
    public function TestClientFakeConnection(inputText:String) {
//        super(null); // no URL really
        this.inputText = inputText;
    }

    public function disconnect():void {} // not a real connection anyway
    public function usingProxy():Boolean { return false; }  // not a real connection anyway
    public function connect():void {} // not a real connection anyway
    
//    public function getInputStream():InputStream {
//        var retVal:InputStream= new ByteArrayInputStream(inputText.getBytes());
//        return retVal;
//    }

    public function getContentType():String {
        return this.contentType;
    }
    
    internal function setContentType(contentType:String):void {
        this.contentType = contentType;
    }
    
}
}