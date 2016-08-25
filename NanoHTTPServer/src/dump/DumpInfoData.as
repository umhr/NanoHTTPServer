package dump
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class DumpInfoData extends StructData
	{
		public var nativePath:String;
		public var extension:String;
		public var contentType:String;
		public var width:int;
		public var height:int;
		public var swfVersion:uint;
		public var frameRate:Number;
		public var actionScriptVersion:uint;
		public var bytesTotal:uint;
		public var hash:String;
		public var string:String;
		public var onComp:Function = function():void { };
		private var paramList:Array = [];
		public function DumpInfoData() 
		{
		}
		
		public function dispose():void {
			nativePath = null;
			extension = null;
			contentType = null;
			hash = null;
			string = null;
			onComp = null;
			paramList = null;
			//this = null;
		}
		
		public function loadBytes(byteArray:ByteArray, nativePath:String, extension:String):void {
			this.nativePath = nativePath;
			this.extension = extension;
			bytesTotal = byteArray.length;
			paramList = ["nativePath", "bytesTotal"];
			
			switch (extension) 
			{
				case "swf":
					swfLoadBytes(byteArray);
				break;
				case "xml":
				case "html":
					stringByByteArray(byteArray);
				break;
				case "jpg":
				case "png":
					imageByByteArray(byteArray);
				break;
			default:
				objectByByteArray(byteArray);
			}
			
		}
		
		private function objectByByteArray(byteArray:ByteArray):void {
			byteArray.compress();
			hash = CryptoCreater.getHash(byteArray.length + byteArray.toString());
			paramList.push("hash");
			onComp();
		}
		
		private function imageByByteArray(byteArray:ByteArray):void {
			var loader:Loader = new Loader();
			loader.loadBytes(byteArray, new LoaderContext());
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgloader_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imgloader_ioError);
		}
		private function imgloader_ioError(event:IOErrorEvent):void 
		{
			trace("imgloader_ioError");
			event.target.removeEventListener(Event.COMPLETE, imgloader_complete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, imgloader_ioError);
			onComp();
		}
		private function imgloader_complete(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, imgloader_complete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, imgloader_ioError);
			
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			width = loaderInfo.width;
			height = loaderInfo.height;
			hash = CryptoCreater.getHash(loaderInfo.bytes.toString());
			//trace(width, height);
			
			//loaderInfo.bytes
			
			paramList.push("width", "height", "hash");
			onComp();
		}
		
		
		
		private function stringByByteArray(byteArray:ByteArray):void {
			string = byteArray.readMultiByte(byteArray.length, "utf-8");
			//bytesTotal = byteArray.length;
			hash = CryptoCreater.getHash(string);
			
			paramList.push("string", "hash");
			//trace(toStr());
			onComp();
		}
		
		private function swfLoadBytes(byteArray:ByteArray):void {
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			loaderContext.applicationDomain = new ApplicationDomain();
			loaderContext.allowLoadBytesCodeExecution = true;
			var loader:Loader = new Loader();
			loader.loadBytes(byteArray, loaderContext);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
		}
		
		private function loader_ioError(event:IOErrorEvent):void 
		{
			trace("loader_ioError");
			event.target.removeEventListener(Event.COMPLETE, loader_complete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			onComp();
		}
		
		private function loader_complete(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, loader_complete);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			
			contentType = loaderInfo.contentType;
			width = loaderInfo.width;
			height = loaderInfo.height;
			swfVersion = loaderInfo.swfVersion;
			frameRate = loaderInfo.frameRate;
			actionScriptVersion = loaderInfo.actionScriptVersion;
			//bytesTotal = loaderInfo.bytesTotal;
			//loaderInfo.bytes.compress();
			hash = CryptoCreater.getHash(loaderInfo.bytes.toString());
			
			//trace(toString());
			paramList.push("contentType", "width", "height", "swfVersion", "frameRate", "actionScriptVersion", "hash");
			//trace(toStr());
			onComp();
		}
		
		public function toStr():String {
			var result:String = "DumpInfoData:{";
			
			if (paramList == null) {
				result += "}";
				return result;
			}	
			
			var n:int = paramList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (i > 0) {
					result += ", ";
				}
				var name:String = paramList[i];
				result += name +":" + this[name];
			}
			result += "}";
			return result;
		}
		
	}
	
}