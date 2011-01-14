package org.indivo.client {
import j2as3.collection.HashMap;

/**
* classes that implement this interface and have a full path name of "org.indivo.client.&lt;classname&gt;"
* can be tested for fidelity to wiki document REST interface using main method of org.indivo.client.TestClient.
*/
internal interface WikiTestable {
    function setTestMode(mode:int):HashMap;

/*
    int getTestMode();
    String[] altFlavorExtraParams();
    boolean threeLegged();
    boolean getDropRecord();

    PhaAdminUtils getAdminUtils();
*/
}
}