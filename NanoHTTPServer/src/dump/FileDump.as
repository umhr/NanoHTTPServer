package dump 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.Socket;
	import jp.mztm.umhr.net.httpServer.ResponceData;
	/**
	 * ...
	 * @author umhr
	 */
	public class FileDump extends EventDispatcher
	{
		//static public var path:String = "/dump.text";
		private var _socket:Socket;
		private var _dumpInfoDataList:Array/*DumpInfoData*/ = [];
		private var _count:int = 0;
		public var string:String = "";
		public var pathString:String = "";
		public var dumpString:String = "";
		//private var _fileCount:int = 0;
		private var _fileList:Array/*File*/ = [];
		public var nativePath:String;
		public function FileDump(socket:Socket) 
		{
			_socket = socket;
		}
		public function dump(nativePath:String = null):void 
		{
			if (nativePath == null) {
				nativePath = File.applicationDirectory.nativePath;
			}
			var file:File = new File(nativePath);
			var directoryListing:Array/*File*/ = file.getDirectoryListing();
			//trace(file.url);
			//directoryListing.sortOn("nativePath");
			
			getDir(directoryListing);
			loadFile();
			
		}
		
		private function loadFile():void {
			var n:int = _fileList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var file:File = _fileList[i]
				file.addEventListener(Event.COMPLETE, file_complete);
				file.addEventListener(IOErrorEvent.IO_ERROR, file_ioError);
				file.load();
				//trace(file.url);
			}
		}
		
		private function getDir(directoryListing:Array/*File*/):void {
			directoryListing.sortOn("nativePath", Array.CASEINSENSITIVE);
			var n:int = directoryListing.length;
			for (var i:int = 0; i < n; i++) 
			{
				var file:File = directoryListing[i];
				if (file.isDirectory) {
					getDir(file.getDirectoryListing());
				}else {
					pathString += "path:" + file.nativePath;
					pathString += ", creationDate:" + file.creationDate;
					pathString += ", modificationDate:" + file.modificationDate;
					pathString += ", size:" + file.size;
					pathString += "\n";
					
					_fileList.push(file);
					//file.addEventListener(Event.COMPLETE, file_complete);
					//file.addEventListener(IOErrorEvent.IO_ERROR, file_ioError);
					//file.load();
				}
			}
		}
		
		private function file_ioError(e:IOErrorEvent):void 
		{
			trace("file_ioError");
			var file:File = e.target as File;
			file.removeEventListener(Event.COMPLETE, file_complete);
			file.removeEventListener(IOErrorEvent.IO_ERROR, file_ioError);
			//_fileCount --;
		}
		
		private function file_complete(e:Event):void 
		{
			//trace("file_complete", _dumpInfoDataList.length,_fileList.length);
			var file:File = e.target as File;
			file.removeEventListener(Event.COMPLETE, file_complete);
			file.removeEventListener(IOErrorEvent.IO_ERROR, file_ioError);
			//trace("comp",file.url);
			
			var dumpInfo:DumpInfoData = new DumpInfoData();
			_dumpInfoDataList.push(dumpInfo);//loadBytesよりも前に記述する。追加するより前にonCompが走ることがあるので。
			dumpInfo.onComp = onComp;
			dumpInfo.loadBytes(file.data, file.nativePath, file.extension);
			//trace(dumpInfo.nativePath);
		}
		
		private function onComp():void {
			_count ++;
			//trace(_count, _fileList.length, _dumpInfoDataList.length );
			
			if (_fileList.length != _count) {
				return;
			}
			
			_dumpInfoDataList.sortOn("nativePath", Array.CASEINSENSITIVE);
			
			var n:int = _dumpInfoDataList.length;
			for (var i:int = 0; i < n; i++) 
			{
				//trace(_dumpInfoDataList[i].toStr());
				dumpString += _dumpInfoDataList[i].toStr();
				dumpString += "\n";
				_dumpInfoDataList[i].dispose();
				
			}
			
			
			string += "Create at:" + new Date().toString();
			string += "\n\n";
			string += "===============\n";
			string += "hash:" + CryptoCreater.getHash(pathString);
			string += "\n\n";
			string += pathString;
			string += "\n";
			string += "===============\n";
			string += "hash:" + CryptoCreater.getHash(dumpString);
			string += "\n\n";
			string += dumpString;
			string += "\n";
			string += "===============\n";
			
			_socket.writeBytes(new ResponceData().writeUTFBytes(string).toByteArray(".text"));
			_socket.flush();
			_socket.close();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}