package 
{
	/**
	 * ...
	 * @author umhr
	 */
	public class Logs 
	{
		private var _linkList:LinkedList = new LinkedList();
		private var _maxLength:int;
		public function Logs(maxLength:int = 1000) 
		{
			_maxLength = maxLength;
		}
		
		public function setLog(date:Date, remote:String, log:String, rawString:String):void {
			_linkList.push( { "date":date, "remote":remote, "log":log, "rawString":rawString } );
			
			if (_linkList.length > _maxLength) {
				_linkList.shift();
			}
		}
		
		public function toLogString():String {
			var result:String = "";
			var n:int = _linkList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var obj:Object = _linkList.getByIndex(i);
				result += "date:" + String(obj.date);
				result += ", log:" + String(obj.log);
				result += "\n";
			}
			return result;
		}
		
		public function toRawString():String {
			var result:String = "";
			var n:int = _linkList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var obj:Object = _linkList.getByIndex(i);
				result += "date:" + String(obj.date);
				result += ", remote:" + String(obj.remote);
				result += ", rawString:" + String(obj.rawString);
				result += "\n";
			}
			return result;
		}
		
	}

}