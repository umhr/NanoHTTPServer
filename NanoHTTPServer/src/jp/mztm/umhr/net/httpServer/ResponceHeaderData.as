package jp.mztm.umhr.net.httpServer 
{
	import flash.net.URLRequestHeader;
	
	/**
	 * ディレクティブ
	 * ...
	 * @author umhr
	 */
	public class ResponceHeaderData 
	{
		public var responceHeaders:Array/*URLRequestHeader*/ = [];
		public var statusLine:String;
		public function ResponceHeaderData() 
		{
			
		}
		
		public function setHeader(name:String, val:String):void {
			responceHeaders.push(new URLRequestHeader(name, val));
		}
		
		public function clone():ResponceHeaderData {
			var result:ResponceHeaderData = new ResponceHeaderData();
			
			return result;
		}
		
		public function toString():String {
			
			var result:String = statusLine+"\r\n";
			var n:int = responceHeaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var urlRequestHeader:URLRequestHeader = responceHeaders[i];
				result += urlRequestHeader.name+": " + urlRequestHeader.value + "\r\n";
			}
			result += "\r\n";
			//trace(result);
			return result;
		}
		
	}
	
}