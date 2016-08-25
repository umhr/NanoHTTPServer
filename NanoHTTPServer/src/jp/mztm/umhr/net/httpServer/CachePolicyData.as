package jp.mztm.umhr.net.httpServer 
{
	/**
	 * ...
	 * @author umhr
	 */
	public class CachePolicyData 
	{
		static public var CONTROL_NO_CACHE:String = "no-cache";
		static public var CONTROL_NO_STORE:String = "no-store";
		static public var ACCESS_MODIFIER_PUBLIC:String = "public";
		static public var ACCESS_MODIFIER_PRIVATE:String = "private";
		
		private var _cacheControl:String;
		/**
		 * no-cache:キャッシュを使って良いかサーバーに確認をする。
		 * no-store:一切キャッシュしない。
		 */
		public var control:String;
		/**
		 * public:どこでもキャッシュ可能。
		 * private:ユーザーのブラウザのみでキャッシュ可能。CDNではキャッシュできない。
		 * 
		 */
		public var accessModifier:String;
		/**
		 * 単位秒
		 */
		public var maxAge:int = -1;
		
		public var eTag:String;
		public var pragma:String;
		private var _lastModified:String;
		public var lastModifiedDate:Date;
		
		private var _expires:String;
		public var expiresDate:Date;
		
		
		public function CachePolicyData() 
		{
			
		}
		
		public function get cacheControl():String 
		{
			if (_cacheControl == null) {
				if (accessModifier) {
					_cacheControl = accessModifier;
				}
				if (maxAge > -1) {
					if (_cacheControl == null) {
						_cacheControl = "";
					}else {
						_cacheControl += ", ";
					}
					_cacheControl += "max-age=" + maxAge;
				}
				if (control) {
					if (control == CONTROL_NO_STORE) {
						_cacheControl = CONTROL_NO_STORE;
					}else {
						if (_cacheControl == null) {
							_cacheControl = "";
						}else {
							_cacheControl += ", ";
						}
						_cacheControl += control;
					}
				}
				if (_cacheControl == null) {
					if (eTag || lastModified) {
						_cacheControl = CONTROL_NO_CACHE;
					}else {
						_cacheControl = CONTROL_NO_STORE;
					}
				}
			}
			return _cacheControl;
		}
		
		public function set cacheControl(value:String):void 
		{
			_cacheControl = value;
		}
		
		public function get expires():String 
		{
			if (_expires == null && expiresDate) {
				_expires = HTTPDateTimeFormatter.stringByDate(expiresDate);
			}
			return _expires;
		}
		
		public function set expires(value:String):void 
		{
			_expires = value;
		}
		
		public function get lastModified():String 
		{
			if (_lastModified == null && lastModifiedDate) {
				_lastModified = HTTPDateTimeFormatter.stringByDate(lastModifiedDate);
			}
			return _lastModified;
		}
		
		public function set lastModified(value:String):void 
		{
			_lastModified = value;
		}
		
		
		
		
		
	}

}