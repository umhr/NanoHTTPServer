package 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import jp.mztm.umhr.net.httpServer.RequestData;
	import jp.mztm.umhr.net.httpServer.ResponceData;
	/**
	 * ...
	 * @author umhr
	 */
	public class ProxyLoader 
	{
		private var _socket:Socket;
		private var _urlLoader:URLLoader;
		private var _loadSocket:Socket;
		public function ProxyLoader(socket:Socket, requestData:RequestData) 
		{
			_socket = socket;
			
			var url:String = requestData.queryList["proxy"];
			
			for (var p:String in requestData.queryList) {
				if (p != "proxy") {
					url += "&" + p + "=" + requestData.queryList[p];
				}
			}
			
			var request:URLRequest = new URLRequest(url);
			
			var ngList:Array/*String*/= ["Accept-Charset", "Accept-Encoding", "Accept-Ranges", "Age", "Allow", "Allowed", "Authorization", "Charge-To", "Connect", "Connection", "Content-Length", "Content-Location", "Content-Range", "Cookie", "Date", "Delete", "ETag", "Expect", "Get", "Head", "Host", "If-Modified-Since", "Keep-Alive", "Last-Modified", "Location", "Max-Forwards", "Options", "Origin", "Post", "Proxy-Authenticate", "Proxy-Authorization", "Proxy-Connection", "Public", "Put", "Range", "Referer", "Request-Range", "Retry-After", "Server", "TE", "Trace", "Trailer", "Transfer-Encoding", "Upgrade", "URI", "User-Agent", "Vary", "Via", "Warning", "WWW-Authenticate", "x-flash-version"];
			
			var n:int = requestData.urlRequestHeaderList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var urlRequestHeader:URLRequestHeader = requestData.urlRequestHeaderList[i];
				if (ngList.indexOf(urlRequestHeader.name) > -1) {
					//request.requestHeaders.push(urlRequestHeader);
				}
				//
			}
			
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioError);
			_urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);
			_urlLoader.load(request);
		}
		
		private function urlLoader_ioError(e:IOErrorEvent):void 
		{
			
			var html:String = "<html><body><pre>" + "読めませんでした" + "</pre></body></html>";
			_socket.writeBytes(new ResponceData().writeUTFBytes(html).toByteArray());
			_socket.flush();
			_socket.close();
		}
		
		private function urlLoader_complete(e:Event):void 
		{
			_urlLoader.removeEventListener(Event.COMPLETE, urlLoader_complete);
			var data:ByteArray = _urlLoader.data as ByteArray;
			_socket.writeBytes(data);
			_socket.flush();
			_socket.close();
			
		}
		
		
	}

}