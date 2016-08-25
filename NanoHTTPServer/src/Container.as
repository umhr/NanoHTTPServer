package 
{
	import dump.FileDump;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import jp.mztm.umhr.logging.Log;
	import jp.mztm.umhr.net.GetLocalAddress;
	import jp.mztm.umhr.net.httpServer.NanoHTTPServer;
	import jp.mztm.umhr.net.httpServer.RequestData;
	import jp.mztm.umhr.net.httpServer.ResponceData;
	/**
	 * ...
	 * @author umhr
	 */
	public class Container extends Sprite 
	{
		private var _getLocalAddress:GetLocalAddress;
		private var _nanoHTTPServer:NanoHTTPServer;
		private var _logs:Logs = new Logs();
		public function Container() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			addChild(new Log());
			
			trace(Main.settingData.clone());
			
			if(Main.settingData.ipAddress == null){
				_getLocalAddress = new GetLocalAddress();
				_getLocalAddress.addEventListener(Event.COMPLETE, getLocalAddress_complete);
				_getLocalAddress.start(true);
			}else {
				setServer(Main.settingData.ipAddress, Main.settingData.port);
			}
		}
		
		private function getLocalAddress_complete(e:Event):void 
		{
			setServer(_getLocalAddress.localAddress, Main.settingData.port);
		}
		private function setServer(localAddress:String, port:int):void {
			
			Log.trace(localAddress, port);
			
			_nanoHTTPServer = new NanoHTTPServer();
			if (Main.settingData.basePath && Main.settingData.basePath.length > 0) {
				_nanoHTTPServer.basePath = Main.settingData.basePath;
				//_nanoHTTPServer.nativePath = Main.settingData.basePath;
			}
			_nanoHTTPServer.bind(port, localAddress);
			_nanoHTTPServer.onRequest = onRequest;
			_nanoHTTPServer.onRequestAsync = onRequestAsync;
			_nanoHTTPServer.onMessage = onMessage;
			//_nanoHTTPServer.isFileDump = true;
			
			if(NativeWindow.isSupported){
				var window:NativeWindow = stage.nativeWindow;// new NativeWindow(new NativeWindowInitOptions());
				window.title = NanoHTTPServer.serverName + " (http://" + localAddress + ":" + port + ")";
			}
		}
		
		private function onRequest(requestData:RequestData):ByteArray {
			//trace(Utils.returnDump(requestData.postList));
			_logs.setLog(new Date(), requestData.remoteAddress+":"+requestData.remotePort, requestData.toString(), requestData.rawString.replace(/\r\n/g, "; "));
			var html:String;
			
			if (requestData.path == "/" && requestData.hasQuery("proxy")) {
				return null;
			}
			if (requestData.path == "/requestHeaders.html") {
				html = "<html><body><pre>" + requestData.rawString + "</pre></body></html>";
				return new ResponceData().writeUTFBytes(html).toByteArray(".html", null, requestData.isDeflate);
			}
			
			if (requestData.path == "/logs.html") {
				html = "<html><body><pre>" + _logs.toLogString() + "</pre></body></html>";
				return new ResponceData().writeUTFBytes(html).toByteArray(".html", null, requestData.isDeflate);
			}
			
			if (requestData.path == "/rawlogs.html") {
				html = "<html><body><pre>" + _logs.toRawString() + "</pre></body></html>";
				return new ResponceData().writeUTFBytes(html).toByteArray(".html", null, requestData.isDeflate);
			}
			
			if (requestData.path == "/hoge.txt") {
				html = "<html><body><a href='/hoge.png'>hoge.png</a></body></html>";
				return new ResponceData().writeUTFBytes(html).toByteArray(".html", null, requestData.isDeflate);
			}
			
			if (requestData.path == "/hoge.png") {
				var bp:BitmapData = new BitmapData(100, 100, false, 0xFFFF0000);
				var byteArray:ByteArray = bp.encode(new Rectangle(0, 0, 100, 100), new PNGEncoderOptions());
				return new ResponceData().setByteArray(byteArray).toByteArray(".png", "hoge.png", requestData.isDeflate);
			}
			
			
			return null;
		}
		
		private function onRequestAsync(requestData:RequestData, socket:Socket):Boolean {
			
			if (requestData.hasQuery("proxy") && requestData.queryList["proxy"].length > 6) {
				new ProxyLoader(socket, requestData);
				return true;
			}else if (requestData.path == "/dump.text") {
				var fileDump:FileDump = new FileDump(socket);
				fileDump.dump(Main.settingData.basePath);
				return true;
			}
			
			return false;
		}
		
		private function onMessage(message:String):void {
			Log.trace(message);
			_logs.setLog(new Date(), "0.0.0.0:0", message, message);
			return;
		};
	}
	
}