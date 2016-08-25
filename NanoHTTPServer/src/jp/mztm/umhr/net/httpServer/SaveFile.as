package jp.mztm.umhr.net.httpServer 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author umhr
	 */
	public class SaveFile 
	{
		
		public function SaveFile() 
		{
			
		}
		
		public function saveFromString(value:String, filename:String):void {
			var byteArray:ByteArray = new ByteArray();
			//byteArray.writeMultiByte(value, "utf-8");
			byteArray.writeUTFBytes(value);
			save(byteArray, filename);
		}
		
		public function save(byteArray:ByteArray, filename:String):void {
			if (filename == null || filename.length == 0) {
				return;
			}
			byteArray.position = 0;
			var file:File = File.desktopDirectory;
			file = file.resolvePath(filename);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(byteArray);
			fileStream.close();
		}
	}

}