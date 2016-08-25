package jp.mztm.umhr.net 
{
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author umhr
	 */
	public class SharedObjectManager 
	{
		static private var _instanceList:Object = { };
		public function SharedObjectManager(block:Block){init();};
		public static function getInstance(key:String):SharedObjectManager{
			if ( _instanceList[key] == null ) { _instanceList[key] = new SharedObjectManager(new Block()); };
			if (_instanceList[key]._key == null) { _instanceList[key]._key = key };
			return _instanceList[key];
		}
		
		private var _key:String;
		private function init():void
		{
			
		}
		
		public function getSharedObject():Object {
			var result:Object;
			var so:SharedObject = SharedObject.getLocal(_key);
			if (so) {
				result = so.data.object;
			}
			return result;
		}
		
		public function setSharedObject(object:Object):void {
			var so:SharedObject = SharedObject.getLocal(_key);
			if (so) {
				so.data.object = object;
			}
		}
		
		public function clear():void {
			var so:SharedObject = SharedObject.getLocal(_key);
			if (so) {
				so.clear();
			}
		}
		
	}
	
}
class Block { };