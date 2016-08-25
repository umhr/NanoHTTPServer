package jp.mztm.umhr.net.httpServer
{
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeNameStyle;
	/**
	 * 参考
	 * Web API:The Good Parts オライリー
	 * ...
	 * @author umhr
	 */
	public class HTTPDateTimeFormatter 
	{
		static private var monthNames:Vector.<String> = new DateTimeFormatter("EN_us").getMonthNames(DateTimeNameStyle.SHORT_ABBREVIATION);
		public function HTTPDateTimeFormatter() 
		{
			
		}
		/**
		 * 
		 * @param	date
		 * @return	"EEE, DD MMM YYYY JJ:NN:SS"で返す。
		 */
		static public function stringByDate(date:Date):String {
			var result:String = "";
			var dateList:Array = date.toUTCString().split(" ");
			result += dateList[0] + ", ";
			result += dateList[2] + " ";
			result += dateList[1] + " ";
			result += dateList[4] + " ";
			result += dateList[3] + " ";
			result += "GMT";
			return result;
			
			// UTCでの換算が面倒
			//var df:DateTimeFormatter = new DateTimeFormatter("EN_us");
			//df.setDateTimePattern("EEE',' dd MMM yyyy HH:mm:ss 'GMT'");
			//return df.format(date);
		}
		
		static public function dateByString(str:String):Date {
			var list:Array/*String*/ = str.split(" ");
			if (str.substr( -3) == "GMT") {
				if (list.length == 6) {
					return rfc1123(list);
				}else if (list.length == 4) {
					return rfc850(list);
				}
			}else if(list.length == 5){
				return ansiCasctime(list);
			}
			return null;
		}
		
		/**
		 * RFC822（RFC1123で修正）
		 * Sat, 21 May 2016 16:19:01  GMT
		 * @param	str
		 * @return	
		 */
		static private function rfc1123(list:Array/*String*/):Date {
			var result:Date = new Date(null);
			result.setUTCFullYear(parseInt(list[3]));
			result.setUTCMonth(monthNames.indexOf(list[2]));
			result.setUTCDate(parseInt(list[1]));
			result.setUTCHours.apply(null, list[4].split(":"));
			return result;
		}
		/**
		 * RFC850（RFC1036で廃止）
		 * @param	list
		 * @return
		 */
		static private function rfc850(list:Array/*String*/):Date {
			var result:Date = new Date(null);
			var dateList:Array/*String*/ = list[1].split("-");
			result.setUTCFullYear(2000 + parseInt(dateList[2]));
			result.setUTCMonth(monthNames.indexOf(dateList[1]));
			result.setUTCDate(parseInt(dateList[0]));
			result.setUTCHours.apply(null, list[2].split(":"));
			return result;
		}
		/**
		 * ANSI Cのasctime()形式
		 * Sun Nov 6 08:49:37 1994
		 * @param	str
		 * @return
		 */
		static private function ansiCasctime(list:Array/*String*/):Date {
			var result:Date = new Date(null);
			//var list:Array/*String*/ = str.split(" ");
			result.setUTCFullYear(parseInt(list[4]));
			result.setUTCMonth(monthNames.indexOf(list[1]));
			result.setUTCDate(parseInt(list[2]));
			result.setUTCHours.apply(null, list[3].split(":"));
			return result;
		}
		
	}

}