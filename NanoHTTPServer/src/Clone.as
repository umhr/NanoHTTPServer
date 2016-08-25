package 
{
	/**
	 * ...
	 * @author umhr
	 */
	public class Clone 
	{
		
		public function Clone() 
		{
			
		}
		static public function intVector(list:Vector.<int>):Vector.<int> {
			var result:Vector.<int> = new Vector.<int>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		
		static public function uintVector(list:Vector.<uint>):Vector.<uint> {
			var result:Vector.<uint> = new Vector.<uint>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		
		static public function stringVector(list:Vector.<String>):Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		
		static public function numberVector(list:Vector.<Number>):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		
		static public function array(list:Array):Array {
			var result:Array = [];
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				// todo Objectの場合
				if (list[i] is Array) {
					result[i] = array(list[i]);
				}else {
					result[i] = list[i];
				}
			}
			return result;
		}
		
		static public function object(obj:Object):Object {
			var result:Object = { };
			for (var p:String in obj) {
				// todo ArrayやObjectの場合
				result[p] = obj[p]);
			}
			return result;
		}
		
		
		
		
	}

}