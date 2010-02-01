package com.cutecoma.engine3d.common.utils
{

    public class Color extends Object
    {
        protected var _A:int = 0;
        protected var _R:int = 0;
        protected var _G:int = 0;
        protected var _B:int = 0;
        public static const WHITE:Color = new Color(16777215);
        public static const BLACK:Color = new Color(0);
        public static const RED:Color = new Color(16711680);
        public static const GREEN:Color = new Color(65280);
        public static const BLUE:Color = new Color(255);
        public static const GREY:Color = new Color(7829367);
        public static const DARK_GREY:Color = new Color(2236962);
        public static const SKY_BLUE:Color = new Color(3714284);
        public static const NAVY_BLUE:Color = new Color(128);
        public static const ROYAL_BLUE:Color = new Color(4286945);
        public static const PURPLE:Color = new Color(10494192);
        public static const YELLOW:Color = new Color(16774656);
        public static const ORANGE:Color = new Color(16753152);
        public static const PINK:Color = new Color(16711896);

        public function Color(param1:int)
        {
            this._A = param1 >> 24 & 255;
            this._R = param1 >> 16 & 255;
            this._G = param1 >> 8 & 255;
            this._B = param1 & 255;
            
        }

        public function get a() : int
        {
            return this._A;
        }

        public function get r() : int
        {
            return this._R;
        }

        public function get g() : int
        {
            return this._G;
        }

        public function get b() : int
        {
            return this._B;
        }

        public function set a(param1:int) : void
        {
            this._A = param1 & 255;
            
        }

        public function set r(param1:int) : void
        {
            this._R = param1 & 255;
            
        }

        public function set g(param1:int) : void
        {
            this._G = param1 & 255;
            
        }

        public function set b(param1:int) : void
        {
            this._B = param1 & 255;
            
        }

        public function toInt() : int
        {
            return (this._A << 24) + (this._R << 16) + (this._G << 8) + this._B;
        }

        public static function fromArgb(param1:int, param2:int, param3:int, param4:int) : Color
        {
            var _loc_5:int = 0;
            _loc_5 = 0 + ((param1 & 255) << 24);
            _loc_5 = _loc_5 + ((param2 & 255) << 16);
            _loc_5 = _loc_5 + ((param3 & 255) << 8);
            _loc_5 = _loc_5 + (param4 & 255);
            return new Color(_loc_5);
        }

        public static function fromRgb(param1:int, param2:int, param3:int) : Color
        {
            var _loc_4:int = 0;
            _loc_4 = 0 + (param1 << 16);
            _loc_4 = _loc_4 + (param2 << 8);
            _loc_4 = _loc_4 + param3;
            return new Color(_loc_4);
        }

        public static function random() : Color
        {
            return new Color(Math.round(Math.random() * 16777215));
        }

    }
}
