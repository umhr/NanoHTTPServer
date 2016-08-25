package  
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * Array.join()のドキュメント、デフォルト値の表記が間違っているような。
	 * Array.slice()コード補完で出てくるパラメーターがドキュメントと違うような。
	 * 
	 * reverseは次のページの三番目を参考にした。
	 * http://www.codeproject.com/KB/recipes/ReverseLinkedList.aspx
	 * 一部のコード（last = first;）は元ネタには無い。
	 * これは元ネタが（last,tail）を持たない構造だからかも。
	 * 
	 * sortOnはフィールド二つまで対応。
	 * 
	 * @author umhr
	 */
	internal class LinkedList
	{
		/**
		 * LinkedList クラスのソートメソッドに対して、大文字と小文字を区別しないソートを指定します。
		 */
		public static const CASEINSENSITIVE:uint = 1;
		/**
		 * LinkedList クラスのソートメソッドに対して、降順でのソートを指定します。
		 */
		public static const DESCENDING:uint = 2;
		/**
		 * LinkedList クラスのソートメソッドに対して、一意性ソート要件を指定します。
		 */
		public static const UNIQUESORT:uint = 4;
		/**
		 * ソート結果として、配列インデックスで構成される配列を返すことを指定します。
		 */
		public static const RETURNINDEXEDARRAY:uint = 8;
		/**
		 * LinkedList クラスのソートメソッドに対して、文字ストリングではなく数値によるソートを指定します。
		 */
		public static const NUMERIC:uint = 16;
		
		public var first:Element;
		public var last:Element;
		private var _length:uint = 0;
		/**
		 * length プロパティを変更できるかどうかを指定します。
		 */
		public var fixed:Boolean;
		public function LinkedList(length:uint = 0, fixed:Boolean = false) 
		{
			this.length = length;
			this.fixed = fixed;
		}
		/**
		 * access演算子の代わり。
		 * @param	index
		 * @return
		 */
		public function getByIndex(index:int):*{
			var n:int = _length;
			var i:int;
			var element:Element;
			element = first;
			if (index < n * 0.5) {
				element = first;
				for (i = 0; i < n; i++) 
				{
					if (i == index) {
						return element.data;
					}
					element = element.next;
				}
			}else {
				element = last;
				for (i = n - 1; i >= 0; i--)
				{
					if (i == index) {
						return element.data;
					}
					element = element.prev;
				}
			}
			return null;
		}
		/**
		 * access演算子の代わり。
		 * @param	index
		 * @param	thisObject
		 * @return
		 */
		public function setByIndex(index:int, thisObject:*):Object {
			if (_length <= index) {
				if (fixed) { return null };
				length = index;
			}
			
			var n:int = _length;
			var i:int;
			var element:Element;
			element = first;
			if (index < n * 0.5) {
				element = first;
				for (i = 0; i < n; i++) 
				{
					if (i == index) {
						element.data = thisObject;
						return thisObject;
					}
					element = element.next;
				}
			}else {
				element = last;
				for (i = n - 1; i >= 0; i--)
				{
					if (i == index) {
						element.data = thisObject;
						return thisObject;
					}
					element = element.prev;
				}
			}
			return thisObject;
		}
		/**
		 * 複製を作ります。
		 * @return
		 */
		public function clone():LinkedList {
			var result:LinkedList = new LinkedList();
			var element:Element = first;
			while (element)
			{
				result.push(element.data);
				element = element.next;
			}
			return result;
		}
		/**
		 * linkedListを後ろに結合
		 * @param	linkedList
		 * @return
		 */
		private function append(linkedList:LinkedList):int {
			if (last) {
				linkedList.first.prev = last;
				last.next = linkedList.first;
				last = linkedList.last;
			}else {
				first = linkedList.first;
				last = linkedList.last;
			}
			_length += linkedList.length;
			return _length;
		}
		
		/**
		 * パラメータで指定されたエレメントを配列内のエレメントと連結して、新しい配列を作成します。
		 * @param	... args
		 * @return
		 */
		public function concat(... args):LinkedList {
			var result:LinkedList = this.clone();
			var element:Element;
			var n:int = args.length;
			for (var i:int = 0; i < n; i++) 
			{
				element = args[i].first;
				while (element)
				{
					result.push(element.data);
					element = element.next;
				}
			}
			return result;
		}
		/**
		 * 指定された関数について false を返すアイテムに達するまで、配列内の各アイテムにテスト関数を実行します。
		 * @param	callback
		 * @param	thisObject
		 * @return
		 */
		public function every(callback:Function, thisObject:* = null):Boolean {
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				if (!callback.call(thisObject, element.data, i, this)) {
					return false;
				}
				element = element.next;
			}
			return true;
		}
		/**
		 * 配列内の各アイテムについてテスト関数を実行し、指定された関数について true を返すすべてのアイテムを含む新しい配列を作成します。
		 * @param	callback
		 * @param	thisObject
		 * @return
		 */
		public function filter(callback:Function, thisObject:* = null):LinkedList {
			var result:LinkedList = new LinkedList();
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				if (callback.call(thisObject, element.data, i, this)) {
					result.push(element.data);
				}
				element = element.next;
			}
			return result;
		}
		
		/**
		 * 配列内の各アイテムについて関数を実行します。
		 * @param	callback
		 * @param	thisObject
		 */
		public function forEach(callback:Function, thisObject:* = null):void {
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				callback.call(thisObject, element.data, i, this);
				element = element.next;
			}
		}
		/**
		 * 厳密な等価（===）を使用して配列内のアイテムを検索し、アイテムのインデックス位置を返します。
		 * @param	searchElement
		 * @param	fromIndex
		 * @return
		 */
		public function indexOf(searchElement:*, fromIndex:int = 0):int {
			if (_length <= fromIndex) {
				return -1;
			}
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				if (fromIndex <= i && element.data === searchElement) {
					return i;
				}
				element = element.next;
			}
			return -1;
		}
		/**
		 * 配列内のエレメントをストリングに変換し、指定されたセパレータをエレメント間に挿入し、エレメントを連結して、その結果をストリングとして返します。
		 * @param	sep
		 * @return
		 */
		public function join(sep:String = null):String {
			if (sep == null) {
				sep = ",";
			}
			var result:String = "";
			var element:Element = first;
			var limit:int = _length - 1;
			for (var i:int = 0; i < _length; i++) {
				result += element.data.toString() + sep;
				element = element.next;
			}
			result = result.substr(0, result.length - sep.length);
			return result;
		}
		/**
		 * 配列内のアイテムを、最後のアイテムから先頭に向かって検索し、厳密な等価（===）を使用して、一致したアイテムのインデックス位置を返します。
		 * @param	searchElement
		 * @param	fromIndex
		 * @return
		 */
		public function lastIndexOf(searchElement:*, fromIndex:int = 0x7fffffff):int {
			fromIndex = Math.min(fromIndex, _length - 1);
			var element:Element = last;
			var n:int = _length;
			for (var i:int = n - 1; i >= 0; i--) {
				if (i <= fromIndex && element.data === searchElement) {
					return i;
				}
				element = element.prev;
			}
			return -1;
		}
		
		/**
		 * 配列内の各アイテムについて関数を実行し、元の配列の各アイテムに対する関数の結果に対応するアイテムから成る新しい配列を作成します。
		 * @param	callback
		 * @param	thisObject
		 * @return
		 */
		public function map(callback:Function, thisObject:* = null):LinkedList {
			var result:LinkedList = new LinkedList();
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				result.push(callback.call(thisObject, element.data, i, this));
				element = element.next;
			}
			return result;
		}
		
		/**
		 * 配列の最後のエレメントを削除して、そのエレメントの値を返します。
		 * @return
		 */
		public function pop():Object {
			if (fixed) { return null };
			var result:Object;
			if (last) {
				result = last.data;
				if(last.prev){
					last = last.prev;
					last.next = null;
				}else {
					first = last = null;
				}
				_length --;
			}
			return result;
		}
		/**
		 * エレメントを配列の最後に追加して、追加後の配列の長さを返します。
		 * @param	data
		 * @return	新しい配列の長さを表す整数です。
		 */
		public function push(... args):uint {
			if (fixed) { return null };
			var n:int = args.length;
			for (var i:int = 0; i < n; i++) 
			{
				var element:Element = new Element(args[i]);
				if (last) {
					last.next = element;
					element.prev = last;
					last = element;
				}else {
					first = last = element;
				}
			}
			_length += n;
			return _length;
		}
		/**
		 * 配列の並びを反転させます。
		 * @return
		 */
		public function reverse():LinkedList {
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) 
			{
				var temp:Element = element.next;
				element.next = element.prev;
				element.prev = temp;
				if (element.prev == null) {
					last = first;
					first = element;
				}else{
					element = element.prev;
				}
			}
			return this;
		}
		/**
		 * 配列の最初のエレメントを削除して、そのエレメントを返します。残りの配列エレメントは、元の位置 i から i-1 に移動されます。
		 * @return
		 */
		public function shift():Object {
			if (fixed) { return null };
			var result:Object;
			if (first) {
				result = first.data;
				if (first.next) {
					first = first.next;
					first.prev = null;
				}else {
					first = last = null;
				}
				_length --;
			}
			return result;
		}
		
		/**
		 * 元の配列から一連のエレメントを取り出して、新しい配列を返します。元の配列は変更されません。
		 * @param	startIndex
		 * @param	endIndex
		 * @return
		 */
		public function slice(startIndex:int = 0, endIndex:int = 16777215):LinkedList {
			if (startIndex < 0) {
				startIndex += _length;
			}
			if (endIndex < 0) {
				endIndex += _length;
			}
			var result:LinkedList = new LinkedList();
			var element:Element = first;
			var n:int = Math.min(_length, endIndex);
			for (var i:int = 0; i < n; i++) {
				if (startIndex <= i && i < endIndex) {
					result.push(element.data);
				}
				element = element.next;
			}
			return result;
		}
		/**
		 * true を返すアイテムに達するまで、配列内の各アイテムにテスト関数を実行します。 
		 * @param	callback
		 * @param	thisObject
		 * @return
		 */
		public function some(callback:Function, thisObject:* = null):Boolean {
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				if (callback.call(thisObject, element.data, i, this)) {
					return false;
				}
				element = element.next;
			}
			return true;
		}
		/**
		 * 配列内のエレメントをソートします。
		 * @param	... args
		 * @return
		 */
		public function sort(... args):LinkedList {
			
			var sortOptions:Object = { };
			if (args.length > 0) {
				sortOptions["CASEINSENSITIVE"] = (args[0] & 1) == 1;
				sortOptions["DESCENDING"] = (args[0] & 2) == 2;
				sortOptions["UNIQUESORT"] = (args[0] & 4) == 4;
				sortOptions["RETURNINDEXEDARRAY"] = (args[0] & 8) == 8;
				sortOptions["NUMERIC"] = (args[0] & 16) == 16;
			}
			
			if (sortOptions.UNIQUESORT) {
				if (!uniqueCheck()) {
					return null;
				}
			}
			
			if (sortOptions.RETURNINDEXEDARRAY) {
				return getIndexLinkedList(margeSort(this.clone(), null, sortOptions));
			}else {
				margeSort(this, null, sortOptions);
			}
			return this;
		}
		
		private function getIndexLinkedList(target:LinkedList):LinkedList {
			var result:LinkedList = new LinkedList();
			var element:Element = target.first;
			while (element)
			{
				result.push(getUniqueIndex(result, element.data));
				element = element.next;
			}
			return result;
		}
		/**
		 * ユニークなIndex番号
		 * @param	result
		 * @param	data
		 * @param	startIndex
		 * @return
		 */
		private function getUniqueIndex(result:LinkedList, data:Object, startIndex:int = 0):int {
			startIndex = this.indexOf(data, startIndex);
			if (result.indexOf(startIndex) > -1) {
				startIndex = getUniqueIndex(result, data, startIndex + 1);
			}
			return startIndex;
		}
		
		private function uniqueCheck():Boolean {
			var dictionary:Dictionary = new Dictionary();
			var element:Element = first;
			while (element)
			{
				dictionary[element.data] = true;
				element = element.next;
			}
			var counter:int;
			for (var p:* in dictionary) { 
				counter++;
			}
			return counter == _length;
		}
		
		private function margeSort(target:LinkedList, fieldName:String = null, sortOptions:Object = null):LinkedList {
			var n:int = target.length
			if (n == 1) {
				
			}else if (n == 2) {
				var boolean:Boolean;
				//数値の場合
				
				var firstData:*;
				var lastData:*;
				if(fieldName){
					firstData = target.first.data[fieldName];
					lastData = target.last.data[fieldName];
				}else{
					firstData = target.first.data;
					lastData = target.last.data;
				}
				
				if (sortOptions && sortOptions.NUMERIC) {
					boolean = Number(firstData) > Number(lastData);
				}else {
					if (sortOptions && sortOptions.CASEINSENSITIVE) {
						boolean = String(firstData).toLowerCase() > String(lastData).toLowerCase();
					}else{
						boolean = String(firstData) > String(lastData);
					}
				}
				if (sortOptions && sortOptions.DESCENDING) {
					boolean = !boolean;
				}
				
				if (boolean) {
					target.reverse();
				}
			}else if(n > 2){
				var result:LinkedList = target.splice(int(n * 0.5), n);
				return marge(margeSort(target, fieldName, sortOptions), margeSort(result, fieldName, sortOptions), fieldName, sortOptions);
			}
			return target;
		}
		
		private function marge(target:LinkedList, sub:LinkedList, fieldName:String = null, sortOptions:Object = null):LinkedList {
			var result:LinkedList = new LinkedList();
			while (target.length >0 && sub.length > 0)
			{
				var boolean:Boolean;
				var targetData:*;
				var subData:*;
				
				if(fieldName){
					targetData = target.first.data[fieldName];
					subData = sub.first.data[fieldName];
				}else{
					targetData = target.first.data;
					subData = sub.first.data;
				}
				
				if (sortOptions && sortOptions.NUMERIC) {
					boolean = Number(targetData) > Number(subData);
				}else {
					if (sortOptions && sortOptions.CASEINSENSITIVE) {
						boolean = String(targetData).toLowerCase() > String(subData).toLowerCase();
					}else{
						boolean = String(targetData) > String(subData);
					}
				}
				if (sortOptions && sortOptions.DESCENDING) {
					boolean = !boolean;
				}
				
				if (boolean) {
					result.push(sub.shift());
				}else {
					result.push(target.shift());
				}
			}
			if (target.length > 0) {
				//result = result.concat(target.splice(0, target.length));
				//result.append(target);
				result.append(target.splice(0, target.length));
			}else if (sub.length > 0) {
				//result = result.concat(sub);
				result.append(sub);
			}
			target.length = 0;
			target.append(result);
			
			//trace(target.length)
			
			return target;
		}
		/**
		 * 配列内のフィールド（フィールド二つまで可能）に基づいて、配列内のエレメントをソートします。
		 * @param	fieldName
		 * @param	options
		 * @return
		 */
		public function sortOn(fieldName:Object, options:Object = null):LinkedList {
			var fieldNameList:Array = [];
			if ((typeof fieldName) == "string") {
				fieldNameList[0] = (fieldName as String);
			}else {
				fieldNameList = (fieldName as Array);
			}
			var optionsList:Array = [];
			if ((typeof options) == "string") {
				optionsList[0] = (options as String);
			}else {
				optionsList = (options as Array);
			}
			
			margeSort(this, fieldNameList[0], optionsList?optionsList[0]:null);
			
			if(fieldName.length > 1){
				var result:LinkedList = new LinkedList();
				var element:Element = this.first;
				while (element)
				{
					var prop:*;
					if (element.next) {
						prop = element.next.data[fieldNameList[0]];
					}else if (element.prev){
						prop = element.prev.data[fieldNameList[0]];
					}
					
					if (prop == element.data[fieldNameList[0]]) {
						if (element.prev) {
							if (element.prev.data[fieldNameList[0]] != element.data[fieldNameList[0]]) {
								result.push(new LinkedList());
							}
						}else {
							result.push(new LinkedList());
						}
					}else {
						result.push(new LinkedList());
					}
					result.last.data.push(element.data);
					element = element.next;
				}
				length = 0;
				element = result.first;
				while (element)
				{
					this.append(margeSort(LinkedList(element.data), fieldNameList[1], optionsList?optionsList[1]:null));
					element = element.next;
				}
			}
			return this;
		}
		/**
		 * 配列のエレメントを追加および削除します。このメソッドは、コピーを作成しないで、配列を変更します。
		 * @param	startIndex
		 * @param	deleteCount
		 * @param	... values
		 * @return
		 */
		public function splice(startIndex:int, deleteCount:uint, ... values):LinkedList {
			if (deleteCount != values.length) {
				if (fixed) { return null };
			}
			if (startIndex < 0) {
				startIndex += _length;
			}
			
			var endIndex:int = Math.min(startIndex + deleteCount, _length);
			var result:LinkedList = new LinkedList();
			var temp:Element;
			var element:Element = first;
			var n:int = Math.min(_length, startIndex + deleteCount + 1);
			
			if (values.length > 0 && (startIndex != 0 || n != _length)) {
				var addition:LinkedList = new LinkedList();
				addition.push.apply(null, values);
			}
			
			for (var i:int = 0; i < n; i++) {
				if (startIndex - 1 == i) {
					var nextElement:Element;
					if (n == endIndex) {
						if (values.length > 0) {
							nextElement = element.next;
							element.next = addition.first;
							addition.first.prev = element;
							last = addition.last;
							element = nextElement;
							_length += values.length;
						}else {
							last = element;
							if(element.next){
								element = element.next;
								if(element.prev){
									element.prev.next = null;
								}
							}
						}
					}else {
						if (values.length > 0) {
							nextElement = element.next;
							element.next = addition.first;
							addition.first.prev = element;
							temp = addition.last;
							element = nextElement;
							_length += values.length;
						}else {
							temp = element;
							element = element.next;
						}
					}
				}else if (startIndex <= i && i < endIndex) {
					element.prev = null;
					result.push(element.data);
					element.data = null;
					if(element.next){
						element = element.next;
						if(element.prev){
							element.prev.next = null;
						}
					}
					_length --;
				}else if (i == endIndex) {
					element.prev = null;
					if (0 == startIndex) {
						if (values.length > 0) {
							first = addition.first;
							addition.last.next = element;
							element.prev = addition.last;
							_length += addition.length;
						}else{
							first = element;
						}
					}else {
						temp.next = element;
						element.prev = temp;
						temp = null;
					}
					element = element.next;
				}else {
					element = element.next;
				}
			}
			
			format();
			result.format();
			if (_length == 0) {
				if (values.length > 0) {
					this.push.apply(null, values);
				}
			}
			return result;
		}
		/**
		 * 指定された配列内のエレメントを表すストリングを返します。
		 * @return
		 */
		public function toLocaleString():String {
			return toString();
		}
		/**
		 * 指定された配列内のエレメントを表すストリングを返します。
		 * @return
		 */
		public function toString():String {
			var result:String = "";
			var element:Element = first;
			var n:int = _length;
			for (var i:int = 0; i < n; i++) {
				trace(i, element.data);
				result += element.data.toString();
				element = element.next;
				if (i < n - 1) {
					result += ",";
				}
			}
			return result;
		}
		/**
		 * エレメントを配列の先頭に追加して、配列の新しい長さを返します。配列内の他のエレメントは、元の位置 i から i+1 に移動されます。
		 * @param	... args
		 * @return
		 */
		public function unshift(... args):uint {
			if (fixed) { return null };
			var n:int = args.length;
			for (var i:int = 0; i < n; i++) 
			{
				var element:Element = new Element(args[n - i - 1]);
				if (first) {
					first.prev = element;
					element.next = first;
					first = element;
				}else {
					first = last = element;
				}
			}
			_length += n;
			return _length;
		}
		/**
		 * 使用できる有効なインデックスの範囲です。
		 */
		public function get length():uint { return _length; };
		public function set length(value:uint):void 
		{
			if (fixed) { return };
			if (value < 0) { return };
			if (value < _length) {
				splice(value, _length);
			}else{
				var n:int = value - _length;
				for (var i:int = 0; i < n; i++) 
				{
					push(undefined);
				}
			}
			format();
		}
		private function format():void {
			if(first){
				first.prev = null;
			}
			if(last){
				last.next = null;
			}
			if (_length == 0) {
				first = last = null;
			}
		}
	}

}
class Element {
	public var prev:Element;
	public var next:Element;
	public var data:Object;
	public function Element(data:Object) {
		this.data = data;
	}
}