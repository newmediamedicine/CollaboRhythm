package com.google.analytics.external
{
    
    public class FakeHTMLDOM extends HTMLDOM
    {
        private var _host:String;
        private var _language:String;
        private var _characterSet:String;
        private var _colorDepth:String;
        private var _location:String;
        private var _pathname:String;
        private var _protocol:String;
        private var _search:String;
        private var _referrer:String;
        private var _title:String;
        
        public function FakeHTMLDOM( host:String = "", language:String = "",
                                     characterSet:String = "", colorDepth:String = "",
                                     location:String = "", pathname:String = "",
                                     protocol:String = "", search:String = "",
                                     referrer:String = "", title:String = "" )
        {
 
            super();
            
            _host = host;
            _language = language;
            _characterSet = characterSet;
            _colorDepth = colorDepth;
            _location = location;
            _pathname = pathname;
            _protocol = protocol;
            _search = search;
            _referrer = referrer;
            _title = title;
        }
        
        public override function get host():String
        {
            return _host;
        }
        
        public override function get language():String
        {
            return _language;
        }
        
        public override function get characterSet():String
        {
            return _characterSet;
        }
        
        public override function get colorDepth():String
        {
            return _colorDepth;
        }
        
        public override function get location():String
        {
            return _location;
        }
        
        public override function get pathname():String
        {
            return _pathname;
        }
        
        public override function get protocol():String
        {
            return _protocol;
        }
        
        public override function get search():String
        {
            return _search;
        }
        
        public override function get referrer():String
        {
            return _referrer;
        }
        
        public override function get title():String
        {
            return _title;
        }
    }
}