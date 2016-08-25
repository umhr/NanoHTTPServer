package 
{
	/**
	 * http://level0.kayac.com/2011/01/describetype_foreach.php
	 * ...
	 * @author umhr
	 */
	public class SettingData extends StructData
	{
		public var basePath:String;
		public var ipAddress:String;
		public var port:uint = 80;
		public function SettingData(settingXML:XML) 
		{
			if (settingXML) {
				fromXML(settingXML);
			}
		}
		
		public function fromXML(settingXML:XML):int {
			var valid:int = 0;
			valid += setProperty(settingXML, "ipAddress");
			valid += setProperty(settingXML, "port");
			valid += setProperty(settingXML, "basePath");
			return valid;
		}
		
	}
	
}