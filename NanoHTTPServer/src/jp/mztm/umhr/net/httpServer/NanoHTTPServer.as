package jp.mztm.umhr.net.httpServer
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	[Event(name="connect",type="flash.events.ServerSocketConnectEvent")]
	/**
	 * RequestDataでBase64を使うので、as3crypto.swcをライブラリに追加すること。
	 * 参考
	 * http://help.adobe.com/ja_JP/FlashPlatform/reference/actionscript/3/flash/net/ServerSocket.html#includeExamplesSummary
	 * ...
	 * @author umhr
	 */
    public class NanoHTTPServer extends EventDispatcher
    {
		static public var serverName:String = "NanoHTTPServer";
		static public var deflateList:Vector.<String> = Vector.<String>(["text/html", "text/plain", "text/xml", "text/javascript", "text/css"]);
		
		public var basePath:String = File.applicationDirectory.nativePath + "/html";
        private var serverSocket:ServerSocket = new ServerSocket();
		/**
		 * function onRequest(requestData:RequestData):ByteArray{ return null };
		 * 同期処理です。返り値がnullだと非同期処理の確認をします。同期処理を行う場合はここで適切なByteArrayを返します。
		 * 
		 */
		public var onRequest:Function = function(requestData:RequestData):ByteArray { return null };
		/**
		 * function(requestData:RequestData, socket:Socket):Boolean { return false };
		 * 非同期処理です。返り値がfalseだとファイルを探しにいきます。非同期処理を行う場合はここに記述します。
		 */
		public var onRequestAsync:Function = function(requestData:RequestData, socket:Socket):Boolean { return false };
		public var onMessage:Function = function(message:String):void { return };
		//private var _timer:Timer = new Timer(1000*10, 1);
		private var requestData:RequestData;
		/**
		 * RequestDataでBase64を使うので、as3crypto.swcをライブラリに追加すること。
		 */
        public function NanoHTTPServer()
        {
			
        }
		
        public function bind(port:int = 80, ip:String = "127.0.0.1"):void
        {
            if ( serverSocket.bound ) { return };
            serverSocket.bind( port, ip );
            serverSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
            serverSocket.listen();
			
			onMessage("Bind to http://" + ip + ":" + port);
        }
		public function get boundTo():String {
			return serverSocket.localAddress + ":" + serverSocket.localPort;
		}
		
        private function onConnect( event:ServerSocketConnectEvent ):void
        {
            var socket:Socket = event.socket;
            socket.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData );
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			dispatchEvent(new Event(ServerSocketConnectEvent.CONNECT));
            //Log.clear();
			
			onMessage( "Connection from " + socket.remoteAddress + ":" + socket.remotePort);
        }
		
		private function onError(e:Event):void 
		{
			onMessage(e.type);
		}
        
		public function dispose():void {
			//trace("NanoHTTPServer.dispose");
			if(serverSocket){
				serverSocket.close();
				serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
				serverSocket = null;
			}
			onRequest = null;
			onMessage = null;
			requestData = null;
		}
        
		public function close():void {
			serverSocket.close();
		}
		
		private var _socket:Socket;
        private function onClientSocketData( event:ProgressEvent ):void
        {
			try
			{
				var bytes:ByteArray = new ByteArray();
				var socket:Socket = event.target as Socket;
				/*
				var str:String = socket.readMultiByte(socket.bytesAvailable, "us-ascii");
				*/
				socket.readBytes(bytes);
				requestData = new RequestData(bytes);
				requestData.remoteAddress = socket.remoteAddress;
				requestData.remotePort = socket.remotePort;
				//trace(requestData);
				if (requestData) {
					var byteArray:ByteArray = onRequest(requestData);
					if (byteArray) {
						socket.writeBytes(byteArray);
					}else if (onRequestAsync(requestData, socket)) {
						return;
					}else {
						socket.writeBytes(getFile(requestData));
					}
				}else {
					socket.writeBytes(new ResponceData(400).toByteArray());
				}
				socket.flush();
				
				if(requestData.isKeepAlive){
					KeepAliveManager.getInstance(requestData.remoteAddress + requestData.remotePort, socket);
				}else{
					socket.close();
				}
			}
			catch (error:Error)
			{
				onMessage("NanoHTTPServer.onClientSocketData:" + error.errorID + " " + error.message);
			}
		}
		
		
		/**
		 * requestDataで指定されたファイルを取得し、ByteArrayで返します。
		 * @param	requestData
		 * @return
		 */
		private function getFile(requestData:RequestData):ByteArray {
			var filePath:String = basePath + requestData.path;
			var file:File = File.applicationStorageDirectory.resolvePath(filePath);
			if (file.isDirectory) {
				var location:String = "http://" + requestData.host + requestData.path + "/";
				return new ResponceData(301).setLocation(location).toByteArray();
			}else if (file.exists) {
					trace(requestData.rawString);
				var content:ByteArray = new ByteArray();
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				stream.readBytes(content);
				stream.close();
				var responceData:ResponceData = new ResponceData(200).setByteArray(content).setRequestData(requestData);
				responceData.cachePolicyData.eTag = '"' + content.length.toString(16) + "-" + file.modificationDate.time.toString(16) + '"';
				responceData.cachePolicyData.lastModifiedDate = file.modificationDate;
				return responceData.toByteArray(requestData.extention, null, requestData.isDeflate);
				//return new ResponceData(200).setByteArray(content, file.modificationDate).setRequestData(requestData).toByteArray(requestData.extention, null, requestData.isDeflate);
			}else {
				return new ResponceData(404).toByteArray();
			}
			
		};
		
		
    }
}