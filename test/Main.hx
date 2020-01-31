package test;

import kbuf.Buffer;

/**
	@author Damilare Akinlaja
**/
class Main {
	public static function main() {
		new Main();
	}

	public function new() {
		var buf = new Buffer();

		buf.writeInt8(cast 64);
		buf.writeInt16(cast -32768);
		buf.writeInt32(-2147483648);
		
		var val:I64 = 0;
		#if cpp
		val = untyped __cpp__('(long long)-9223372036854775808ll');
		#elseif cs 
		val = untyped __cs__('(long)-9223372036854775808L');
		#end
	
		buf.writeInt64(val);
		buf.writeFloat(3.4e+38);
		buf.writeDouble(1.7e+308);
		buf.writeString("Hello world");

		
		trace(buf.readInt8());
		trace(buf.readInt16());
		trace(buf.readInt32());
		trace(buf.readInt64());
		trace(buf.readFloat());
		trace(buf.readDouble());
		trace(buf.readString());
		
	}
}