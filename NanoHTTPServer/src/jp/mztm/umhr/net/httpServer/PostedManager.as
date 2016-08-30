package jp.mztm.umhr.net.httpServer 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author umhr
	 */
	public class PostedManager 
	{
		static private var _instanceList:Object = { };
		public function PostedManager(block:Block){init();};
		public static function getInstance(key:String = "theOne"):PostedManager{
			if ( _instanceList[key] == null ) {_instanceList[key] = new PostedManager(new Block());};
			return _instanceList[key];
		}
		
		
		private function init():void
		{
			
		}
		
		public var boundary:String;
		public var messageBody:String;
		public var rawByteArray:ByteArray;
		public var rawString:String;
		public var postList:Object;
		public var position:uint;
		public function primary(boundary:String, messageBody:String, position:uint, rawByteArray:ByteArray, rawString:String, postList:Object):void
		{
			trace("PostedManager.decode", boundary, boundary.length);
			this.boundary = boundary;
			this.messageBody = messageBody;
			this.position = position;
			this.rawByteArray = rawByteArray;
			this.rawString = rawString;
			this.postList = postList;
			setPosted();
		}
		
		private function setPosted():void {
			var dataList:Array/*String*/ = messageBody.split("--" + boundary);
			var startPosition:uint = position;
			var endPosition:uint;
			var n:int = dataList.length - 1;
			
			trace("RequestData.setPosted n = ", n);
			trace("RequestData.setPosted dataList[n]", dataList[n].length, dataList[n] == "--\r\n");
			if (n <= 1) {
				return;
			}
			
			var stdin:String = "";
			for (var i:int = 1; i < n; i++) 
			{
				startPosition += ("--" + boundary).length;
				endPosition = startPosition + dataList[i].length;
				stdin += parceForm(dataList[i], startPosition, endPosition);
				if (i < n - 1) {
					stdin += "&";
				}
				startPosition = endPosition;
			}
			//Log.trace(stdin);
		}
		
		public function secondary(messageBody:String, rawByteArray:ByteArray, rawString:String):void {
			trace("PostedManager.secondary");
			trace(this.messageBody.length, messageBody.length);
			this.messageBody += messageBody;
			trace(this.messageBody.length);
			
			//trace("rawByteArray.length", this.rawByteArray.position, rawByteArray.position);
			trace(this.rawByteArray.length, rawByteArray.length);
			this.rawByteArray.position = this.rawByteArray.length;
			this.rawByteArray.writeBytes(rawByteArray);
			trace(this.rawByteArray.length);
			this.rawString += rawString;
			
			setPosted();
		}
		
		
		private function parceForm(value:String, startPosition:uint, endPosition:uint):String {
			var name:String = "";
			var filename:String = "";
			var postedValue:String = "";
			
			// よくこむこと
			// https://wiki.suikawiki.org/n/multipart%2Fform-data
			
			var valueList:Array/*String*/ = value.split("\r\n");
			//trace(valueList[0]);// 空行
			//trace(valueList[1]);// Content-Disposition
			//trace(valueList[2]);// Content-Typeがある場合のみ挿入される。
			//trace(valueList[3]);// 空行
			//trace(valueList[4]);// data
			//trace(valueList[5]);// 空行
			
			var n:int = valueList.length;
			for (var i:int = 0; i < n; i++) 
			{
				trace(i, valueList[i].length);
			}
			
			trace("valueList.length", valueList.length);
			if (valueList.length > 4) {
				var contentDispositionList:Array/*String*/ = valueList[1].split("; ");
				if (contentDispositionList.length > 1 && contentDispositionList[0].indexOf("Content-Disposition: form-data") > -1) {
					if (contentDispositionList[1].indexOf('name="') > -1) {
						name = contentDispositionList[1].substring('name="'.length, contentDispositionList[1].lastIndexOf('"'));
					}
					if (contentDispositionList.length > 2 && contentDispositionList[2].indexOf('filename="') > -1) {
						filename = contentDispositionList[2].substring('filename="'.length, contentDispositionList[2].lastIndexOf('"'));
					}
				}
				
				if (valueList.length > 5 && valueList[2].indexOf("Content-Type: ") > -1) {
					startPosition += valueList[0].length + 2;
					startPosition += valueList[1].length + 2;
					startPosition += valueList[2].length + 2;
					startPosition += valueList[3].length + 2;
					endPosition -= 2;
					var ba:ByteArray;
					trace(valueList[2]);
					if (valueList[2].indexOf("application/octet-stream") > -1 ) {
						trace("octet-stream");
					}else if (valueList[2].indexOf("text/plain") > -1 ) {
						//var len:uint = endPosition - startPosition;
						trace(startPosition, endPosition, endPosition - startPosition);
						ba = new ByteArray();
						ba.writeBytes(rawByteArray, startPosition, endPosition - startPosition);
						//rawByteArray.readBytes(ba, 0, len);
						ba.position = 0;
						trace(rawByteArray.length, ba.length);
						ba.position = 0;
						trace(ba.toString());
						new SaveFile().save(ba, "ba_" + filename);
						//new SaveFile().saveFromString(value.substring(value.indexOf("\r\nContent-Type: text/plain\r\n\r\n") + "\r\nContent-Type: text/plain\r\n\r\n".length, value.length - 2), "hoge" + filename);
					}else if (valueList[2].indexOf("image/jpeg") > -1 ) {
						// jpgの場合にエンコードする
						// 複数の添付があるとき、filenName等で日本語が使われたときが未検討
						endPosition += rawByteArray.length - rawString.length;
						//endPosition += 42;//Frog.jpg補正
						trace("jpg?");
						ba = new ByteArray();
						ba.writeBytes(rawByteArray, startPosition, endPosition - startPosition);
						new SaveFile().save(ba, "de_" + filename);
					}else if (valueList[2].indexOf("image/png") > -1 ) {
						endPosition += rawByteArray.length - rawString.length;
						trace("png?");
						ba = new ByteArray();
						ba.writeBytes(rawByteArray, startPosition, endPosition - startPosition);
						new SaveFile().save(ba, "de_" + filename);
					}else {
						endPosition += rawByteArray.length - rawString.length;
						trace("?");
						ba = new ByteArray();
						ba.writeBytes(rawByteArray, startPosition, endPosition - startPosition);
						new SaveFile().save(ba, "de_" + filename);
					}
				}else{
					postedValue = valueList[3];
				}
			}else {
				
			}
			
			if (postList == null) {
				postList = { };
			}
			
			postList[name] = postedValue;
			return name+"=" + encodeURI(postedValue.replace(/ /g, "+"));
			
		}
		
	}
	
}
class Block { };