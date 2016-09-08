package jp.mztm.umhr.net.httpServer  
{
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class ResponceData 
	{
		private var _location:String;
		private var _status:int;
		public var requestData:RequestData;
		private var _byteArray:ByteArray = new ByteArray();
		//public var modificationDate:Date;
		//public var hash:String;
		public var cachePolicyData:CachePolicyData = new CachePolicyData();
		public function ResponceData(status:int = 200) 
		{
			_status = status;
		}
		
		public function setLocation(location:String):ResponceData {
			_location = location;
			//trace(_location);
			return this;
		}
		
		public function setRequestData(requestData:RequestData):ResponceData {
			this.requestData = requestData;
			return this;
		}
		
		public function setByteArray(byteArray:ByteArray):ResponceData {
			_byteArray = byteArray;
			return this;
		}
		public function writeUTFBytes(utfBytes:String):ResponceData {
			_byteArray.writeUTFBytes(utfBytes);
			return this;
		}
		
		//public function cashPolicy(
		
		/**
		 * HTTPステータスコードを適切に選ぶためのフローチャート : 難しく考えるのをやめよう | インフラ・ミドルウェア | POSTD
		 * http://postd.cc/choosing-an-http-status-code/
		 * @param	extention
		 * @param	fileName
		 * @param	isDeflate
		 * @return
		 */
		public function toByteArray(extention:String = ".html", fileName:String = null, isDeflate:Boolean = false):ByteArray {
			
			var responceHeaderData:ResponceHeaderData = new ResponceHeaderData();
			responceHeaderData.statusLine = "HTTP/1.1 200 OK";
			
			// ステータスライン
			if (_status == 301) {
				responceHeaderData.statusLine = "HTTP/1.1 301 Moved Permanently";
				responceHeaderData.setHeader("Location", _location);
			}else if (_status == 400) {
				responceHeaderData.statusLine = "HTTP/1.1 400 Bad Request";
				_byteArray.writeMultiByte("<html><body><h2>400 Bad Request</h2></body></html>", "utf-8");
			}else if (_status == 401) {
				responceHeaderData.statusLine = "HTTP/1.1 401 Authorization Required";
				_byteArray.writeMultiByte("<html><body><h2>401 Authorization Required</h2></body></html>", "utf-8");
				responceHeaderData.setHeader("WWW-Authenticate", 'Basic realm="SECRET AREA"');
			}else if (_status == 404) {
				responceHeaderData.statusLine = "HTTP/1.1 404 Not Found";
				_byteArray.writeMultiByte("<html><body><h2>404 Not Found</h2></body></html>", "utf-8");
			}else if (_status == 500) {
				responceHeaderData.statusLine = "HTTP/1.1 500 Internal Server Error";
				_byteArray.writeMultiByte("<html><body><h2>500 Internal Server Error</h2></body></html>", "utf-8");
			}
			
			var contentType:String = contentTypeFromExtention(extention);
			responceHeaderData.setHeader("Content-Type", contentType);
			if (isDeflate && NanoHTTPServer.deflateList.indexOf(contentType) > -1) {
				// 圧縮。304で返すときも、このディレクティブはつけてもつけなくてもいいみたい。
				responceHeaderData.setHeader("Content-Encoding", "deflate");
				_byteArray.deflate();
				
				if (cachePolicyData.cacheControl != CachePolicyData.CONTROL_NO_STORE && cachePolicyData.cacheControl != CachePolicyData.CONTROL_NO_CACHE && cachePolicyData.cacheControl != CachePolicyData.ACCESS_MODIFIER_PRIVATE) {
					// CDN向け記述。CDNでキャッシュしない時には、この記述は不要？
					// http://blog.nomadscafe.jp/2011/02/httpplack.html
					responceHeaderData.setHeader("Vary", "Accept-Encoding, User-Agent");
				}
			}
			
			//if(hash == null){
				//hash = CryptoCreater.getHash(_byteArray.length.toString() + _byteArray.toString());
			//}
			
			var isCash:Boolean;
			if (requestData) {
				if (requestData.eTag) {
					isCash = requestData.eTag == cachePolicyData.eTag;
				}else if (requestData.ifModifiedSince && cachePolicyData.lastModifiedDate) {
					cachePolicyData.lastModifiedDate.setMilliseconds(0);
					isCash = requestData.ifModifiedSince.time >= cachePolicyData.lastModifiedDate.time;
				}
				if (requestData.isKeepAlive) {
					responceHeaderData.setHeader("Connection", "Keep-Alive");
					responceHeaderData.setHeader("Keep-Alive", "timeout=1");
				}
			}
			
			if (isCash) {
				responceHeaderData.statusLine = "HTTP/1.1 304 Not Modified";
				_status = 304;
			}else {
				responceHeaderData.setHeader("Content-Length", _byteArray.length.toString());
			}
			
			responceHeaderData.setHeader("Date", HTTPDateTimeFormatter.stringByDate(new Date()));
			responceHeaderData.setHeader("Server", NanoHTTPServer.serverName);
			responceHeaderData.setHeader("Accept-Ranges", "bytes");
			
			if (contentType == "application/json") {
				// IEでコンテンツの自動判別をしないように。
				responceHeaderData.setHeader("X-Content-Type-Options", "nosniff");
				// JSからJsonを取得する場合に必要。
				responceHeaderData.setHeader("Access-Control-Allow-Origin", "*");
			}
			
			if (fileName) {
				// https://www.softel.co.jp/blogs/tech/archives/2393
				// ダウンロードダイアログを表示する
				responceHeaderData.setHeader("Content-Disposition", 'attachment; filename="' + fileName + '"');
				// そのままブラウザ上で開く
				//responceHeaderData.setHeader("Content-Disposition", 'inline; filename="' + fileName + '"');
			}
			
			if (cachePolicyData.eTag) {
				responceHeaderData.setHeader("ETag", cachePolicyData.eTag);
			}else if (cachePolicyData.lastModified) {
				responceHeaderData.setHeader("Last-Modified", cachePolicyData.lastModified);
			}
			if(cachePolicyData.cacheControl){
				responceHeaderData.setHeader("Cache-Control", cachePolicyData.cacheControl);
			}
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(responceHeaderData.toString(), "utf-8");
			
			if (isCash) {
				return byteArray;
			}
			
			byteArray.writeBytes(_byteArray);
			
			return byteArray;
		}
		
		private function contentTypeFromExtention(extention:String):String {
			var result:String;
			var list:Array/*Array*/ = [
				["application/json", ".json"],
				["application/pdf", ".pdf"],
				["application/x-shockwave-flash", ".swf"],
				["application/zip", ".zip"],
				["audio/mg4", ".m4a"],
				["audio/mpeg", ".mp3", ".mpg", ".mpeg"],
				["image/gif", ".gif"],
				["image/jpeg", ".jpg", ".jpeg"],
				["image/png", ".png"],
				["image/x-icon", ".ico"],
				["text/css", ".css"],
				["text/csv", ".csv"],
				["text/html", ".html", ".htm", ".cgi"],
				["text/javascript", ".js"],
				["text/plain; charset=utf-8", ".txt", ".text", ".conf", ".list", ".as", ".log"],
				["text/xml", ".xml"],
				["text/richtext", ".rtx"],
				["video/flv", ".flv"],
				["video/quicktime", ".mov"],
				["video/mp4", ".mp4"],
				["video/x-ms-wmv", ".wmv"]
				];
			var ex:String;
			var n:int = list.length;
			var m:int;
			loop:for (var i:int = 0; i < n; i++) 
			{
				m = list[i].length;
				for (var j:int = 1; j < m; j++) 
				{
					if (list[i][j] == extention) {
						result = list[i][0];
						break loop;
					}
				}
			}
			if (result == null) {
				result = "application/x-unknown";
			}
			return result;
		}
		
		
		public function clone():ResponceData {
			var result:ResponceData = new ResponceData(_status);
			result._byteArray = _byteArray;
			result._location = _location;
			return result;
		}
		public function toString():String {
			var result:String = "ResponceData:{";
			result += "}";
			return result;
		}
		
	}
	
}