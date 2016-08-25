package jp.mztm.umhr.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	[Event(name="complete",type="flash.events.Event")]
	/**
	 * ...
	 * @author umhr
	 */
	public class GetLocalAddress extends EventDispatcher
	{
		private var _datagramSocket:DatagramSocket;
		private var _localAddress:String = "";
		public function GetLocalAddress() 
		{
			
		}
		/**
		 * useNetworkInfoがtrueの場合、NetworkInfoから取得を試みます。
		 * NetworkInfoからでは、VirtualBoxなどの仮想マシンがインストールされた環境では、意図しないアドレスが取れてしまう可能性があります。
		 * 不可視アプリでは、_datagramSocket.connectからのアドレス取得ができないので、trueにして、NetworkInfoから取得します。
		 * 
		 * @param	useNetworkInfo
		 */
		public function start(useNetworkInfo:Boolean = false):void {
			
			if (useNetworkInfo) {
				_localAddress = byNetworkInfo();
			}
			
			if(_localAddress == ""){
				byDatagramSocket();
			}else {
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
		}
		private function byDatagramSocket():void {
			_datagramSocket = new DatagramSocket();
			_datagramSocket.addEventListener(IOErrorEvent.IO_ERROR, commandSock_ioError);
			_datagramSocket.addEventListener(Event.ACTIVATE, commandSock_activate);
			try
			{
				_datagramSocket.connect("192.168.0.254", 50000 );
			}
			catch ( e:Error )
			{
				trace( e.message );
			}
		}
		
		private function byNetworkInfo():String {
			
			if (NetworkInfo.isSupported) {
				var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				var n:int = interfaces.length;
				for (var i:int = 0; i < n; i++) 
				{
					var networkInterface:NetworkInterface = interfaces[i];
					var addresses:Vector.<InterfaceAddress> = networkInterface.addresses;
					var m:int = addresses.length;
					for (var j:int = 0; j < m; j++) 
					{
						var interfaceAddress:InterfaceAddress = addresses[j];
						if (interfaceAddress.address.substr(0, "192.168.".length) == "192.168.") {
							return interfaceAddress.address;
						}
						
					}
					
				}
			}
			return "";
		}
		
		private function commandSock_ioError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
			close();
		}
		
		private function commandSock_activate(e:Event):void 
		{
			_localAddress = _datagramSocket.localAddress;
			close();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get localAddress():String {
			return _localAddress;
		}
		
		private function close():void {
			_datagramSocket.removeEventListener( IOErrorEvent.IO_ERROR, commandSock_ioError);
			_datagramSocket.removeEventListener(Event.ACTIVATE, commandSock_activate);
			_datagramSocket.close();
			_datagramSocket = null;
		}
		
	}

}