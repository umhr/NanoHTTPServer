package jp.mztm.umhr.net.httpServer 
{
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author umhr
	 */
	public class SocketCloser 
	{
		private var _timer:Timer = new Timer(1000 * 10, 1);
		private var _socket:Socket;
		public function SocketCloser(socket:Socket) 
		{
			_socket = socket;
			init();
		}
		
		private function init():void 
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerComplete);
			_timer.start();
		}
		
		private function timer_timerComplete(e:TimerEvent):void 
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_timerComplete);
			_timer = null;
			if(_socket){
				trace("timer_timerComplete");
				_socket.close();
				_socket = null;
			}
		}
		
		public function get running():Boolean {
			if (_timer == null) {
				
			}
			return _timer.running;
		}
		
	}

}