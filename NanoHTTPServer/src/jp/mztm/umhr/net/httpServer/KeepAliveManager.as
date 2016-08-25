package jp.mztm.umhr.net.httpServer
{
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	/**
	 * todo
	 * 対応するヘッダーをつける？
	 * ...
	 * @author umhr
	 */
	public class KeepAliveManager
	{
		static private var _instanceList:Object = {};
		
		public function KeepAliveManager(block:Block, socket:Socket, key:String)
		{
			_socket = socket;
			_key = key;
			init();
		}
		
		public static function getInstance(key:String, socket:Socket):KeepAliveManager
		{
			if (_instanceList[key] == null)
			{
				_instanceList[key] = new KeepAliveManager(new Block(), socket, key);
			}else {
				trace("リセット", key);
				var timer:Timer = _instanceList[key]._timer as Timer;
				timer.reset();
				timer.start();
			}
			return _instanceList[key];
		}
		
		private var _timer:Timer = new Timer(1000, 1);
		private var _socket:Socket;
		private var _key:String;
		private function init():void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerComplete);
			_timer.start();
		}
		
		private function timer_timerComplete(e:TimerEvent):void
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_timerComplete);
			_timer = null;
			if (_socket)
			{
				trace("timer_timerComplete", _key, _socket.connected);
				if(_socket.connected){
					_socket.close();
				}
				_socket = null;
				_instanceList[_key] = null
				
			}
		}
	}

}

class Block
{
}
;