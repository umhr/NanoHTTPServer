package jp.mztm.umhr.create 
{
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author umhr
	 */
	public class ARGB 
	{
		private var _a:int = 0;
		private var _r:int = 0;
		private var _g:int = 0;
		private var _b:int = 0;
		private var _isRGBChanged:Boolean;
		private var _isHSBChanged:Boolean;
		private var _argb:uint = 0;
		private var _rgb:int = 0;
		/**
		 * 0-360
		 */
		private var _hue:Number;
		/**
		 * 0-1.0
		 */
		private var _saturation:Number;
		/**
		 * 0-1.0
		 */
		private var _brightness:Number;
		
		static public function argbFromRGB(rgb:int, a:int = 0xFF):uint {
			return a << 24 | rgb;
		}
		static public function rgbFromARGB(argb:uint):int {
			return argb & 0xFFFFFF;
		}
		
		public function ARGB(argb:uint = 0, a:int = -1, r:int = -1, g:int = -1, b:int = -1) 
		{
			//trace(argb, isNaN(argb));
			var isChange:Boolean;
			if (argb > 0) {
				_a = argb >> 24 & 0xff;//24bit右にずらす。
				_r = argb >> 16 & 0xff;//16bit右にずらして、下位8bitのみを取り出す。
				_g = argb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
				_b = argb & 0xff;//下位8bitのみを取り出す。
				isChange = true;
			}
			if(a > -1){
				_a = a & 0xff;
				isChange = true;
			}
			if(r > -1){
				_r = r & 0xff;
				isChange = true;
			}
			if(g > -1){
				_g = g & 0xff;
				isChange = true;
			}
			if(b > -1){
				_b = b & 0xff;
				isChange = true;
			}
			
			if(isChange){
				_isRGBChanged = true;
				_isHSBChanged = true;
			}
		}
		
		/**
		 * RGBとHSV・HSBの相互変換ツールと変換計算式 - PEKO STEP
		 * http://www.peko-step.com/tool/hsvrgb.html
		 */
		private function calcHSB():void {
			var max:int = Math.max(_r, _g, _b);
			var min:int = Math.min(_r, _g, _b);
			
			if (max == min) {
				_hue = 0;
			}else if (max == _r) {
				_hue = 60 * (_g - _b) / (max - min);
			}else if (max == _g) {
				_hue = 60 * (_b - _r) / (max - min) + 120;
			}else if (max == _b) {
				_hue = 60 * (_r - _g) / (max - min) + 240;
			}
			if (_hue < 0) {
				_hue+= 360;
			}
			if(max == 0){
				_saturation = 0;
			}else {
				_saturation = (max - min) / max;
			}
			_brightness = max / 255;
			_isHSBChanged = false;
		}
		
		private function calcRGBByHSB():void {
			var max:Number = _brightness;
			var min:Number = max - (_saturation / 1) * max;
			//var min:Number = max - (_saturation / 255) * max;
			
			if (_hue <= 60) {
				_r = (max)*255;
				_g = ((_hue / 60) * (max - min) + min)*255;
				_b = (min)*255;
			}else if (_hue <= 120) {
				_r = (((120 - _hue) / 60) * (max - min) + min)*255;
				_g = (max)*255;
				_b = (min)*255;
			}else if (_hue <= 180) {
				_r = (min)*255;
				_g = (max)*255;
				_b = (((_hue-120) / 60) * (max - min) + min)*255;
			}else if (_hue <= 240) {
				_r = (min)*255;
				_g = (((240 - _hue) / 60) * (max - min) + min)*255;
				_b = (max)*255;
			}else if (_hue <= 300) {
				_r = (((_hue-240) / 60) * (max - min) + min)*255;
				_g = (min)*255;
				_b = (max)*255;
			}else {
				_r = (max)*255;
				_g = (min)*255;
				_b = (((360 - _hue) / 60) * (max - min) + min)*255;
			}
			_isRGBChanged = true;
		}
		
		public function get colorTransform():ColorTransform {	
			return new ColorTransform(0, 0, 0, 0, _r, _g, _b, _a);
		}
		public function setLuminous(ratio:Number):ARGB {
			if (ratio < 0 || 2 < ratio) { ratio = 1; trace("function rgbBrightness 範囲外") };
			if(ratio <= 1){
				_r *= ratio;
				_g *= ratio;
				_b *= ratio;
			}else{
				_r = (255 - _r) * (ratio - 1) + _r;
				_g = (255 - _g) * (ratio - 1) + _g;
				_b = (255 - _b) * (ratio - 1) + _b;
			}
			_isRGBChanged = true;
			_isHSBChanged = true;
			return this;
		}
		
		public function get hex():String {
			return argb.toString(16).toUpperCase();
		}
		
		public function get a():int 
		{
			return _a;
		}
		
		public function set a(value:int):void 
		{
			if (_a == value) { return };
			_a = value;
			_isRGBChanged = true;
			_isHSBChanged = true;
			
		}
		
		public function get r():int 
		{
			return _r;
		}
		
		public function set r(value:int):void 
		{
			if (_r == value) { return };
			_r = value;
			_isRGBChanged = true;
			_isHSBChanged = true;
		}
		
		public function get g():int 
		{
			return _g;
		}
		
		public function set g(value:int):void 
		{
			if (_g == value) { return };
			_g = value;
			_isRGBChanged = true;
			_isHSBChanged = true;
		}
		
		public function get b():int 
		{
			return _b;
		}
		
		public function set b(value:int):void 
		{
			if (_b == value) { return };
			_b = value;
			_isRGBChanged = true;
			_isHSBChanged = true;
		}
		
		public function get argb():uint 
		{
			if (_isRGBChanged) {
				_argb = _a << 24 | _r << 16 | _g << 8 | _b;
				_rgb = _argb & 0xFFFFFF;
				_isRGBChanged = false;
			}
			return _argb;
		}
		
		public function set argb(value:uint):void 
		{
			if (_argb == value) { return };
			_argb = value;
			_rgb = _argb & 0xFFFFFF;
			_a = value >> 24 & 0xFF;//24bit右にずらす。
			_r = value >> 16 & 0xFF;//16bit右にずらして、下位8bitのみを取り出す。
			_g = value >> 8 & 0xFF;//8bit右にずらして、下位8bitのみを取り出す。
			_b = value & 0xFF;//下位8bitのみを取り出す。
		}
		
		public function get rgb():int 
		{
			if (_isRGBChanged) {
				argb;
			}
			return _rgb;
		}
		
		public function set rgb(value:int):void 
		{
			if (_rgb == value) { return };
			_r = value >> 16 & 0xFF;//16bit右にずらして、下位8bitのみを取り出す。
			_g = value >> 8 & 0xFF;//8bit右にずらして、下位8bitのみを取り出す。
			_b = value & 0xFF;//下位8bitのみを取り出す。
			_isRGBChanged = true;
			_isHSBChanged = true;
		}
		
		public function get hue():Number 
		{
			if (_isHSBChanged) {
				calcHSB();
			}
			return _hue;
		}
		
		public function set hue(value:Number):void 
		{
			if (_hue == value) { return };
			_hue = value;
			calcRGBByHSB();
		}
		
		public function get saturation():Number 
		{
			if (_isHSBChanged) {
				calcHSB();
			}
			return _saturation;
		}
		
		public function set saturation(value:Number):void 
		{
			if (_saturation == value) { return };
			_saturation = value;
			calcRGBByHSB();
		}
		
		public function get brightness():Number 
		{
			if (_isHSBChanged) {
				calcHSB();
			}
			return _brightness;
		}
		
		public function set brightness(value:Number):void 
		{
			if (_brightness == value) { return };
			_brightness = value;
			calcRGBByHSB();
		}
		
		public function toString():String {
			var result:String = "ARGB:{";
			result += "hex:" + hex;
			result += ", argb:" + argb;
			result += ", rgb:" + rgb;
			result += ", a:" + _a;
			result += ", r:" + _r;
			result += ", g:" + _g;
			result += ", b:" + _b;
			result += ", hue:" + hue;
			result += ", saturation:" + saturation;
			result += ", brightness:" + brightness;
			result += "}";
			return result;
		}
	}

}