package
collaboRhythm.plugins.diary.model{

[Bindable]public class ItemEntry
    {
        private var _name:String;
        private var _photo:Object;
        private var _type:String;
        
        public function ItemEntry()
        {
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function set name(name:String):void
        {
            _name = name;
        }

        public function get photo():Object
        {
            return _photo;
        }
        
        public function set photo(photo:Object):void
        {
            _photo = photo;
        }public function get type():String
        {
            return _type;
        }

        public function set type(type:String):void
        {
            _type = type;
        }

    }
}