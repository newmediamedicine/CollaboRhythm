
package com.google.analytics.utils
{
    import core.version;
    
    public class FakeEnvironment extends Environment
    {
        private var _appName:String;
        private var _appVersion:version;
        private var _url:String;
        private var _referrer:String;
        private var _documentTitle:String;
        private var _domainName:String;
        private var _locationPath:String;
        private var _locationSearch:String;
        private var _flashVersion:version;
        private var _language:String;
        private var _languageEncoding:String;
        private var _operatingSystem:String;
        private var _playerType:String;
        private var _platform:String;
        private var _protocol:String;
        private var _screenWidth:Number;
        private var _screenHeight:Number;
        private var _screenColorDepth:String;
        private var _userAgent:String;
        private var _isInHTML:Boolean;
        private var _isAIR:Boolean;
        
        public function FakeEnvironment( appName:String = "", appVersion:version = null,
                                       url:String = "", referrer:String = "",
                                       documentTitle:String = "", domainName:String = "",
                                       locationPath:String = "", locationSearch:String = "",
                                       flashVersion:version = null, language:String = "",
                                       languageEncoding:String = "", operatingSystem:String = "",
                                       playerType:String = "", platform:String = "",
                                       protocol:String = null, screenWidth:Number = NaN,
                                       screenHeight:Number = NaN, screenColorDepth:String = "",
                                       userAgent:String = null,
                                       isInHTML:Boolean = false,
                                       isAIR:Boolean = false )
        {
            super("", "", "", null);
            
            _appName = appName;
            _appVersion = appVersion;
            _url = url;
            _referrer = referrer;
            _documentTitle = documentTitle;
            _domainName = domainName;
            _locationPath = locationPath;
            _locationSearch = locationSearch;
            _flashVersion = flashVersion;
            _language = language;
            _languageEncoding = languageEncoding;
            _operatingSystem = operatingSystem;
            _playerType = playerType;
            _platform = platform;
            _protocol = protocol;
            _screenWidth = screenWidth;
            _screenHeight = screenHeight;
            _screenColorDepth = screenColorDepth;
            _userAgent = userAgent;
            _isInHTML = isInHTML;
            _isAIR = isAIR;
        }
        
        public override function get appName():String
        {
            return _appName;
        }
        
        public override function set appName( value:String ):void
        {
            _appName = value;
        }
        
        public override function get appVersion():version
        {
            return _appVersion;
        }
        
        public override function set appVersion( value:version ):void
        {
            _appVersion = value;
        }
        
//        ga_internal override function set url( value:String ):void
//        {
//            _url = value;
//        }
        
        public override function get locationSWFPath():String
        {
            return _url;
        }
        
        public override function get referrer():String
        {
            return _referrer;
        }
        
        public override function get documentTitle():String
        {
            return _documentTitle;
        }
        
        public override function get domainName():String
        {
            return _domainName;
        }
        
        public override function get locationPath():String
        {
            return _locationPath;
        }
        
        public override function get locationSearch():String
        {
            return _locationSearch;
        }
        
        public override function get flashVersion():version
        {
            return _flashVersion;
        }
        
        public override function get language():String
        {
            return _language;
        }
        
        public override function get languageEncoding():String
        {
            return _languageEncoding;
        }
        
        public override function get operatingSystem():String
        {
            return _operatingSystem;
        }
        
        public override function get playerType():String
        {
            return _playerType;
        }
        
        public override function get platform():String
        {
            return _platform;
        }
        
        public override function get protocol():String
        {
            return _protocol;
        }
        
        public override function get screenWidth():Number
        {
            return _screenWidth;
        }
        
        public override function get screenHeight():Number
        {
            return _screenHeight;
        }
        
        public override function get screenColorDepth():String
        {
            return _screenColorDepth;
        }
        
        public override function get userAgent():String
        {
            return _userAgent;
        }
        
        public override function set userAgent( custom:String ):void
        {
            _userAgent = custom;
        }
        
        public override function isInHTML():Boolean
        {
            return _isInHTML;
        }
        
        public override function isAIR():Boolean
        {
            return _isAIR;
        }
    }
}