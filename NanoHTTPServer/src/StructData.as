package 
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class StructData 
	{
		private var _typeInfoName:String;
		private var _variableList:Object = { };
		private var _variableObjectList:Array/*Object*/ = [];
		public function StructData() 
		{
			
		}
		
		public function setProperty(targetXML:XML, propertyName:String, type:String = null, xmlElementName:String = null):int {
			if (type == null) {
				if (_typeInfoName == null) {
					_setVariableList();
				}
				type = _variableList[propertyName];
			}
			if (xmlElementName == null) {
				xmlElementName = propertyName;
			}
			//trace(propertyName,);
			if (_hasXMLElement(targetXML, xmlElementName)) {
				var str:String;
				var date:Date;
				if (type == "int") {
					this[propertyName] = parseInt(targetXML[xmlElementName]);
					return 0;
				}else if (type == "uint") {
					this[propertyName] = parseInt(targetXML[xmlElementName]);
					return 0;
				}else if (type == "String") {
					this[propertyName] = String(targetXML[xmlElementName]);
					return 0;
				}else if (type == "Boolean") {
					this[propertyName] = String(targetXML[xmlElementName]) == "true";
					return 0;
				}else if (type == "Number") {
					this[propertyName] = parseFloat(targetXML[xmlElementName]);
					return 0;
				}else if (type == "Array") {
					this[propertyName] = String(targetXML[xmlElementName]).split(",");
					return 0;
				}else if (type == "__AS3__.vec::Vector.<int>") {
					this[propertyName] = Vector.<int>(String(targetXML[xmlElementName]).split(","));
					return 0;
				}else if (type == "__AS3__.vec::Vector.<uint>") {
					this[propertyName] = Vector.<uint>(String(targetXML[xmlElementName]).split(","));
					return 0;
				}else if (type == "__AS3__.vec::Vector.<String>") {
					this[propertyName] = Vector.<String>(String(targetXML[xmlElementName]).split(","));
					return 0;
				}else if (type == "__AS3__.vec::Vector.<Number>") {
					this[propertyName] = Vector.<Number>(String(targetXML[xmlElementName]).split(","));
					return 0;
				}else if (type == "yyyyMMdd") {
					str = String(targetXML[xmlElementName]);
					date = new Date(null);
					date.setFullYear(parseInt(str.substr(0, 4)), parseInt(str.substr(4, 2)) - 1, parseInt(str.substr(6, 2)));
					this[propertyName] = date;
					return 0;
				}else if (type == "hhmm") {
					str = String(targetXML[xmlElementName]);
					date = new Date(null);
					date.setHours(parseInt(str.substr(0, 2)), parseInt(str.substr(2, 2)));
					this[propertyName] = date;
					return 0;
				}else if (type == "yyyy-mm-ddThh:MM") {
					str = String(targetXML[xmlElementName]);
					date = new Date(null);
					date.setFullYear(parseInt(str.substr(0, 4)), parseInt(str.substr(5, 2)) - 1, parseInt(str.substr(8, 2)));
					date.setHours(parseInt(str.substr(11, 2)), parseInt(str.substr(14, 2)));
					this[propertyName] = date;
					return 0;
				}else if (type == "yyyy-mm-ddThh:MM:ss") {
					str = String(targetXML[xmlElementName]);
					date = new Date(null);
					date.setFullYear(parseInt(str.substr(0, 4)), parseInt(str.substr(5, 2)) - 1, parseInt(str.substr(8, 2)));
					date.setHours(parseInt(str.substr(11, 2)), parseInt(str.substr(14, 2)), parseInt(str.substr(17, 2)));
					this[propertyName] = date;
					return 0;
				}else {
					trace(propertyName, type);
				}
			}
			return -1;
		}
		
		private function _hasXMLElement(targetXML:XML, xmlElementName:String):Boolean {
			return String(targetXML[xmlElementName]).length > 0;
		}
		
		private function _setVariableList():void {
			// クラスの要素についてループ
			// http://level0.kayac.com/2011/01/describetype_foreach.php
			// http://help.adobe.com/ja_JP/FlashPlatform/reference/actionscript/3/flash/utils/package.html#describeType()
			var typeInfo:XML = describeType(this);
			_typeInfoName = typeInfo.@name;
			//trace(typeInfo);
			var n:int;
			var i:int;
			var name:String;
			var type:String;
			var value:int;
			
			n = typeInfo.variable.length();
			for (i = 0; i < n; i++) 
			{
				name= typeInfo.variable[i].@name;
				type = typeInfo.variable[i].@type;
				value = typeInfo.variable[i].metadata.arg.@value;
				_variableList[name] = type;
				_variableObjectList.push( { name:name, type:type, value:value } );
			}
			
			n = typeInfo.accessor.length();
			for (i = 0; i < n; i++) {
				name = typeInfo.accessor[i].@name;
				type = typeInfo.accessor[i].@type;
				value = typeInfo.accessor[i].metadata[0].arg.@value;
				_variableList[name] = type;
				_variableObjectList.push( { name:name, type:type, value:value } );
			}
			
			_variableObjectList.sortOn("value", Array.NUMERIC);
			
			//var p:String;
			//n = _variableObjectList.length;
			//for (i = 0; i < n; i++) 
			//{
				//for (p in _variableObjectList[i]) { 
					//trace(p + ":" + _variableObjectList[i][p]);
				//}
			//}
			
		}
		
		public function clone():Object {
			if (_typeInfoName == null) {
				_setVariableList();
			}
			var ClassReference:Class = getDefinitionByName(_typeInfoName) as Class;
			var result:Object = new ClassReference(null);
			// public プロパティは自動
			var n:int = _variableObjectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var name:String = _variableObjectList[i].name;
				var type:String = _variableObjectList[i].type;
				if (type == "Array" && this[name] != null) {
					result[name] = arrayCopy(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<int>" && this[name] != null) {
					result[name] = intVectorCopy(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<uint>" && this[name] != null) {
					result[name] = uintVectorCopy(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<String>" && this[name] != null) {
					result[name] = stringVectorCopy(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<Number>" && this[name] != null) {
					result[name] = numberVectorCopy(this[name]);
				}else {
					result[name] = this[name];
				}
			}
			return result;
		}
		
		private function intVectorCopy(list:Vector.<int>):Vector.<int> {
			var result:Vector.<int> = new Vector.<int>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		private function uintVectorCopy(list:Vector.<uint>):Vector.<uint> {
			var result:Vector.<uint> = new Vector.<uint>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		private function stringVectorCopy(list:Vector.<String>):Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		private function numberVectorCopy(list:Vector.<Number>):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result[i] = list[i];
			}
			return result;
		}
		
		private function arrayCopy(list:Array):Array {
			var result:Array = [];
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (list[i] is Array) {
					result[i] = arrayCopy(list[i]);
				}else {
					result[i] = list[i];
				}
			}
			return result;
		}
		
		public function toString():String {
			if (_typeInfoName == null) {
				_setVariableList();
			}
			
			var result:String = _typeInfoName+":{";
			
			var n:int = _variableObjectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (i > 0) {
					result += ", ";
				}
				var name:String = _variableObjectList[i].name;
				if (_variableObjectList[i].type == "Array" && this[name] != null) {
					result += name+":" + _stringFromList(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<int>" && this[name] != null) {
					result += name+":" + _stringFromList(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<uint>" && this[name] != null) {
					result += name+":" + _stringFromList(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<String>" && this[name] != null) {
					result += name+":" + _stringFromList(this[name]);
				}else if (_variableObjectList[i].type == "__AS3__.vec::Vector.<Number>" && this[name] != null) {
					result += name+":" + _stringFromList(this[name]);
				}else {
					result += name+":" + this[name];
				}
			}
			result += "}";
			return result;
		}
		
		private function _stringFromList(list:*):String {
			var result:String = "[";
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (i > 0) {
					result += ", ";
				}
				if (list[i] is Array) {
					result += _stringFromList(list[i]);
				}else{
					result += list[i];
				}
			}
			return result + "]";
		}
	}
	
}