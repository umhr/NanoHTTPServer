package jp.mztm.umhr.net
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.system.LoaderContext;
	[Event(name="complete",type="flash.events.Event")]
	/**
	 * ...
	 * @author umhr
	 */
	public class FetchFile extends EventDispatcher 
	{
		public var content:Object;
		public var type:String;
		private var _file:File;
		public var nativePath:String;
		public function FetchFile(target:flash.events.IEventDispatcher=null) 
		{
			super(target);
		}
		public function browse(typeFilter:Array = null):void{
			_file = new File();
			_file.addEventListener(Event.SELECT, atSelect);
			_file.browse(typeFilter);
		}
		private function atSelect(event:Event):void {
			_file.removeEventListener(Event.SELECT, atSelect);
			_file.addEventListener(Event.COMPLETE, atFileComplete);
			nativePath = _file.nativePath;
			_file.load();
		}
		private function atFileComplete(event:Event):void {
			_file.removeEventListener(Event.COMPLETE, atFileComplete);
			type = _file.type;
			if (isByteArray(type)) {
				loaderStart();
			}else {
				urlLoaderStart();
			}
		}
		/**
		 * 拡張子が指定の場合はByteArrayとする。
		 * @param	type
		 * @return
		 */
		private function isByteArray(type:String):Boolean {
			var list:Array/*String*/ = [".jpg", ".png", ".gif"];
			for each (var extention:String in list) {
				if (extention == type.toLowerCase()) {
					return true;
				}
			}
			return false;
		}
		
		private function urlLoaderStart():void {
			content = _file.data;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function loaderStart():void {
			var loader:Loader = new Loader();
			loader.loadBytes(_file.data, new LoaderContext());
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, atBytesComplete);
		}
		
		private function atBytesComplete(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, atBytesComplete);
			content = event.target.content;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}