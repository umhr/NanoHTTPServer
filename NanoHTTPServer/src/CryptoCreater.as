package
{

	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.*;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.Hex;
	import flash.utils.ByteArray;

	public class CryptoCreater {
		
		/**
		 * コンストラクタ
		 */
		public function CryptoCreater() { }
		
		/**
		 * 
		 * Google as3crypto.swcを利用してハッシュ値を取得する
		 * http://studynet.blog54.fc2.com/blog-entry-9.html
		 */
		
		static public function getMD5Hash(baseStr:String) :String{
				
				//①受け取ったプレーンテキストをHex文字列に変換
				var hexString:String;
				hexString = Hex.fromString(baseStr);
				
				//②①で生成したHex文字列をバイナリデータに変換
				var bainaryString:ByteArray = new ByteArray();
				bainaryString = Hex.toArray(hexString);
				
				//③ハッシュ値生成アルゴリズムにMD5を指定
				var hashString1:IHash;
				hashString1 = Crypto.getHash("md5");
				
				//④②で生成したバイナリデータと③で生成したハッシュ値を元にハッシュ値を生成
				var hashString2:ByteArray;
				hashString2 = hashString1.hash( bainaryString );
				
				//④で生成したバイナリデータをプレーンテキストに変換
				var resultString:String;
				resultString = Hex.fromArray( hashString2 );

				return resultString;
		}
		
		static public function getHash(value:String, type:String = "md5") :String {
			return Hex.fromArray(Crypto.getHash(type).hash(Hex.toArray(Hex.fromString(value))));
		}
		
	}
}