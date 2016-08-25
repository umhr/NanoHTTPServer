package jp.mztm.umhr.net.httpServer  
{
	import com.hurlant.util.Base64;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class RequestData 
	{
		public var path:String;
		public var extention:String = "";
		public var host:String;
		public var basicID:String;
		public var basicPW:String;
		public var connection:String = "keep-alive";
		public var queryList:Object;
		public var rawString:String;
		public var eTag:String;
		public var rawByteArray:ByteArray;
		public var isDeflate:Boolean;
		public var urlRequestHeaderList:Array/*URLRequestHeader*/;
		public var ifModifiedSince:Date;
		public var isKeepAlive:Boolean;
		public var remoteAddress:String;
		public var remotePort:uint;
		
		public function RequestData(value:ByteArray) 
		{
			if (value) {
				rawByteArray = value;
				
				//rawString = value.readMultiByte(value.length, "iso-8859-1");
				//rawString = value.readMultiByte(value.length, "utf-8");
				rawString = value.toString();
				parse(rawString);
				trace(rawByteArray.length, rawString.length);
			}
		}
		
		private function parse(value:String):void 
		{
			//trace(value);
			//Log.clear();
			//Log.trace(value.replace(/\r/g, ""));
			//Log.trace("//////////////////////////");
			
			var list:Array/*String*/ = value.split("\r\n");
			var request:String = list[0];
			var requestList:Array/*String*/ = list[0].split(" ");
			var method:String = requestList[0].toLowerCase();
			urlRequestHeaderList = [];
			
			setQuery(requestList[1]);
			
			if(path && path.lastIndexOf(".") > -1){
				extention = path.substr(path.lastIndexOf("."));
			}
			
			var position:uint = value.indexOf("\r\n\r\n") + 4;
			var messageBody:String = value.substr(value.indexOf("\r\n\r\n"));
			trace(messageBody.length);
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (i > 0) {
					var index:int = list[i].indexOf(": ");
					if(index > 0){
						var name:String = list[i].substr(0, index);
						var val:String = list[i].substr(index + 2);
						urlRequestHeaderList.push(new URLRequestHeader(name, val));
						//trace(name, value);
						switch (name) 
						{
							case "Accept-Encoding":
								isDeflate = list[i].indexOf("deflate", index) > -1;
								break;
							case "Authorization":
								if (list[i].substr(index + 2, "Basic ".length) == "Basic ") {
									var basic:String = Base64.decode(list[i].substr(index + 2 + "Basic ".length));
									basicID = basic.split(":")[0];
									basicPW = basic.split(":")[1];
								}
								break;
							case "Connection":
								connection = val;
								break;
							case "Content-Type":
								if (list[i].indexOf("boundary=") > -1) {
									var boundary:String = list[i].substr(list[i].indexOf("boundary=") + "boundary=".length);
									setPosted(boundary, messageBody, position);
								}
								break;
							case "If-None-Match":
								eTag = val;
								break;
							case "If-Modified-Since":
								ifModifiedSince = HTTPDateTimeFormatter.dateByString(val);
								break;
							case "Host":
								host = list[i].substr(index + 2);
								break;
							default:
						}
						
					}
				}
				
			}
			
			isKeepAlive = connection == "keep-alive";
			
			//trace(requestList[1]);
		}
		
		public function hasQuery(query:String):Boolean {
			if (queryList == null) {
				return false;
			}else {
				return queryList[query] != null;
			}
		}
		private function setPosted(boundary:String, messageBody:String, position:uint):void {
			var dataList:Array/*String*/ = messageBody.split("--" + boundary);
			var startPosition:uint = position;
			var endPosition:uint;
			var n:int = dataList.length - 1;
			if (2 > n) {
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
		public var postList:Object;
		public function toCGIString():String {
			var result:String = "";
			var p:String;
			if (postList) {
				for (p in postList) {
					result += p + "=" + postList[p] + "&";
				}
			}else if (queryList) {
				for (p in queryList) {
					result += p + "=" + queryList[p] + "&";
				}
			}
			
			if (result.length > 0) {
				result = result.substr(0, result.length - 1);
			}
			
			return result;
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
			trace(valueList.length);
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
					
					if (valueList[2].indexOf("application/octet-stream") > -1 ) {
						trace("空っぽ?");
					}else if (valueList[2].indexOf("text/plain") > -1 ) {
						//var len:uint = endPosition - startPosition;
						trace(startPosition, endPosition, endPosition - startPosition);
						var ba:ByteArray = new ByteArray();
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
						var baj:ByteArray = new ByteArray();
						baj.writeBytes(rawByteArray, startPosition, endPosition - startPosition);
						new SaveFile().save(baj, "de_" + filename);
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
		
		private function parceForm2(value:String):String {
			
			value = value.substr('Content-Disposition: form-data; name="'.length + 2);
			var name:String = value.substr(0, value.indexOf('"'));
			var valueList:Array/*String*/ = value.split("\r\n");
			
			if (valueList[0].indexOf('filename="') > -1) {
				var fileName:String = valueList[0].substring(valueList[0].indexOf('filename="') + 'filename="'.length, valueList[0].lastIndexOf('"'));
				value = fileName;
				var contentTypeLine:String = valueList[1];
				trace("contentType", contentTypeLine);
				if (contentTypeLine.indexOf("image/jpeg") > -1 ) {
					// jpgの場合にエンコードする
				}else if (contentTypeLine.indexOf("text/plain") > -1 ) {
					
				}
			}else{
				value = valueList[2];
			}
			
			if (postList == null) {
				postList = { };
			}
			
			postList[name] = value;
			return name+"=" + encodeURI(value.replace(/ /g, "+"));
		}
		
		private function setQuery(value:String):void 
		{
			var postion:int = value.search(/\?/);
			if (postion == -1) {
				setPath(value);
				return;
			}
			var queryString:String = value.substr(postion + 1);
			var queryStrList:Array/*String*/ = queryString.split("&");
			
			path = value.substr(0, postion);
			
			var n:int = queryStrList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var pos:int = queryStrList[i].search(/=/);
				if (pos == -1) {
					continue;
				}
				if (!queryList) {
					queryList = { };
				}
				var key:String = queryStrList[i].substr(0, pos);
				var str:String = queryStrList[i].substr(pos + 1);
				queryList[key] = str;
			}
			
			//Log.dump(queryList);
		}
		
		private function setPath(value:String):void 
		{
			if (value && value.length > 0 && value.substr(value.length - 1) == "/") {
				path = value+"index.html";
			}else {
				path = value;
			}
		}
		
		public function clone():RequestData {
			var result:RequestData = new RequestData(null);
			result.path = path;
			result.extention = extention;
			result.host = host;
			result.basicID = basicID;
			result.basicPW = basicPW;
			var p:String;
			for (p in postList) { 
				result.postList[p] = postList[p];
			}
			for (p in queryList) { 
				result.queryList[p] = queryList[p];
			}
			result.postList
			result.rawString = rawString;
			return result;
		}
		
		public function toString():String {
			var result:String = "RequestData:{";
			result += "remote:" + remoteAddress + ":" + remotePort;
			result += ", path:" + path;
			//if(extention.length > 0){
				//result += ", extention:" + extention;
			//}
			result += ", host:" + host;
			if(basicID != null){
				result += ", basicID:" + basicID;
			}
			if(basicPW != null){
				result += ", basicPW:" + basicPW;
			}
			
			if(postList != null){
				result += ", postList:{";
				var str:String = "";
				var p:String;
				for (p in postList) { 
					if (str.length > 0) {
						str += " ,";
					}
					str += p + ":" + postList[p];
				}
				result += str + "}";
			}
			
			if(queryList != null){
				result += ", queryList:{";
				str = "";
				for (p in queryList) { 
					if (str.length > 0) {
						str += " ,";
					}
					str += p + ":" + queryList[p];
				}
				result += str + "}";
			}
			result += "}";
			return result;
		}
		
	}
	
}