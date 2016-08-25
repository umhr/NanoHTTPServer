package jp.mztm.umhr.create
{
	import flash.geom.ColorTransform;
	
	/**
	 * https://ja.wikipedia.org/wiki/HSV%E8%89%B2%E7%A9%BA%E9%96%93
	 * setHue、setSaturationも作る
	 * setGrayscaleグレースケール化も対応
	 * 色の平均値？
	 * ポップな色5色がほしい→arrayで返す
	 * ↓
	 * getVariation(色数、開始色=0xFFFFFFFF、hue方向？明るさ方向？彩度方向？知覚的？)
	 * HUE固定のgetHUEVariationでいいんじゃない？開始色はコンストラクタで渡してという処理が良い？だからstaticでは無い？
	 * getHUEVariation(色数、is知覚的=true):Array
	 * 
	 * ColorはあくまでもC#のクローンにして、RGB,ARGBクラスを作る？
	 * 
	 * ...
	 * @author umhr
	 */
	public class ColorUtils
	{
		public var a:int = 0;
		public var r:int = 0;
		public var g:int = 0;
		public var b:int = 0;
		public var argb:uint = 0;
		public var rgb:int = 0;
		public var hue:Number;
		public var saturation:Number;
		public var brightness:Number;
		public function ColorUtils(argb:uint = NaN, a:int = NaN, r:int = NaN, g:int = NaN, b:int = NaN)
		{
			if(!isNaN(a)){
				this.a = a;
			}else if(!isNaN(argb)){
				this.a = argb >> 24;//24bit右にずらす。
			}
			if(!isNaN(r)){
				this.r = r;
			}else if(!isNaN(argb)){
				this.r = argb >> 16 & 0xff;//16bit右にずらして、下位8bitのみを取り出す。
			}
			if(!isNaN(g)){
				this.g = g;
			}else if(!isNaN(argb)){
				this.g = argb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
			}
			if(!isNaN(b)){
				this.b = b;
			}else if(!isNaN(argb)){
				this.b = argb & 0xff;//下位8bitのみを取り出す。
			}
			calc();
			calcHSB();
		}
		
		/**
		 * RGBとHSV・HSBの相互変換ツールと変換計算式 - PEKO STEP
		 * http://www.peko-step.com/tool/hsvrgb.html
		 */
		private function calcHSB():void {
			var max:int = Math.max(r, g, b);
			var min:int = Math.min(r, g, b);
			
			if (max == min) {
				hue = 0;
			}else if (max == r) {
				hue = 60 * (g - b) / (max - min);
			}else if (max == g) {
				hue = 60 * (b - r) / (max - min) + 120;
			}else if (max == b) {
				hue = 60 * (r - g) / (max - min) + 240;
			}
			if (hue < 0) {
				hue+= 360;
			}
			
			saturation = (max - min) / max;
			brightness = max / 255;
		}
		
		private function calcRGBByHSB():void {
			//brightness *= 255;
			//saturation *= 255;
			var max:Number = brightness;
			var min:Number = max - (saturation / 255) * max;
			
			if (hue <= 60) {
				r = max;
				g = (hue / 60) * (max - min) + min;
				b = min;
			}else if (hue <= 120) {
				r = ((120 - hue) / 60) * (max - min) + min;
				g = max;
				b = min;
			}else if (hue <= 180) {
				r = min;
				g = max;
				b = ((hue-120) / 60) * (max - min) + min;
			}else if (hue <= 240) {
				r = min;
				g = ((240 - hue) / 60) * (max - min) + min;
				b = max;
			}else if (hue <= 300) {
				r = ((hue-240) / 60) * (max - min) + min;
				g = min;
				b = max;
			}else {
				r = max;
				g = min;
				b = ((360 - hue) / 60) * (max - min) + min;
			}
		}
		
		
		private function calc():void {
			argb = a << 24 | r << 16 | g << 8 | b;
			rgb = r << 16 | g << 8 | b;
		}
		
		public function toColorTransform():ColorTransform {	
			return new ColorTransform(0, 0, 0, 0, r, g, b, a);
		}
		public function setBrightness(ratio:Number):ColorUtils {
			if(ratio < 0 || 2 < ratio){ratio = 1;trace("function rgbBrightness 範囲外")}
			if(ratio <= 1){
				r *= ratio;
				g *= ratio;
				b *= ratio;
			}else{
				r = (255 - r) * (ratio - 1) + r;
				g = (255 - g) * (ratio - 1) + g;
				b = (255 - b) * (ratio - 1) + b;
			}
			calc();
			return this;
		}
		
		
		static public function argbFromRGB(rgb:int, a:int = 0xFF):uint {
			return a << 24 | rgb;
		}
		static public function rgbFromARGB(argb:uint):int {
			return argb & 0xFFFFFF;
		}
		/**
		 * フィールドカラーに変色します.
		 * 6桁16進数から、2桁ぶんずつを取り出す。 
		 * 色情報は24bit。r8bit+g8bit+b8bit。24桁の二進数 
		 * @param	rgb
		 * @param	ratio
		 * @return
		 */
		static public function ColorTransformFromRGB(rgb:int, ratio:Number = 1):ColorTransform {	
			//ratioが1以外の場合、明度変更関数へ
			if(ratio != 1){rgb = rgbBrightness(rgb,ratio)};
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.redMultiplier = colorTransform.blueMultiplier = colorTransform.greenMultiplier = 0;
			colorTransform.redOffset = rgb >> 16;//16bit右にずらす。
			colorTransform.greenOffset = rgb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
			colorTransform.blueOffset = rgb & 0xff;//下位8bitのみを取り出す。
			return colorTransform;
		}
		
		/**
		 * 色の明度を相対的に変える関数。
		 * rgb値と割合を与えて、結果を返す。
		 * rgbは、0xffffff段階の値。
		 * ratioが0の時に0x000000に、1の時にそのまま、2の時には0xffffffになる。
		 * 相対的に、ちょっと暗くしたい時には、ratioを0.8に、ちょっと明るくしたい時にはratioを1.2などに設定する。
		 * 
		 * @param	rgb
		 * @param	ratio
		 * @return
		 */
		static public function rgbBrightness(rgb:int,ratio:Number):int{
			if(ratio < 0 || 2 < ratio){ratio = 1;trace("function rgbBrightness 範囲外")}
			var _r:int = rgb >> 16;//16bit右にずらす。
			var _g:int = rgb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
			var _b:int = rgb & 0xff;//下位8bitのみを取り出す。
			if(ratio <= 1){
				_r *= ratio;
				_g *= ratio;
				_b *= ratio;
			}else{
				_r = (255 - _r)*(ratio-1)+_r;
				_g = (255 - _g)*(ratio-1)+_g;
				_b = (255 - _b)*(ratio-1)+_b;
			}
			return _r<<16 | _g<<8 | _b;
		}

		
	}

}