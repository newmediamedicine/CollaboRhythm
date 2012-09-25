/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 */

package com.google.analytics.external
{
    public class FakeAdSenseGlobals extends AdSenseGlobals
    {
        private var _gaGlobal:Object;
        private var _dh:String;
        private var _hid:String;
        private var _sid:String;
        private var _vid:String;
        
        public function FakeAdSenseGlobals( gaGlobal:Object = null, dh:String = "",
                                            hid:String = "", sid:String = "", vid:String = "" )
        {
            super();
            _gaGlobal = gaGlobal;
            _dh       = dh;
            _hid      = hid;
            _sid      = sid;
            _vid      = vid;
        }
        
        public override function get gaGlobal():Object
        {
            return _gaGlobal;
        }
        
        public override function get dh():String
        {
            return _dh;
        }
        
        public override function get hid():String
        {
            return _hid;
        }
        
        public override function set hid( value:String ):void
        {
            _hid = value;
        }
        
        public override function get sid():String
        {
            return _sid;
        }
        
        public override function set sid( value:String ):void
        {
            _sid = value;
        }
        
        public override function get vid():String
        {
            return _vid;
        }
        
        public override function set vid( value:String ):void
        {
            _vid = value;
        }
    }
}