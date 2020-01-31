package kbuf;

import haxe.io.FPHelper;
import haxe.Int64;
import haxe.io.BytesInput;
import haxe.io.BytesBuffer;
import haxe.io.BytesData;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class Buffer {
	var buf:BytesData; // Array<U8>;

	var writeOffset:U32 = 0;
	var readOffset:U32 = 0;

	public var LE:Bool = true;

	public function new() {
        #if cs 
        var b = Bytes.alloc(256);
        buf = b.getData();
        #else
        buf = new BytesData();
        #end
	}

	public function setData(buf:BytesData) {
		this.buf = buf;
	}

	public function getData():BytesData {
		return buf;
	}

	// function getByteStr():String {
	// 	var strBuf = new BytesOutput();
	// 	strBuf.writeString('0');
	// 	// strBuf.getBytes().toHex();

	// 	if (LE) {
    //         var i:I64 = 0;
    //         while(i < strBuf.length){

    //             i++;
    //         }
    //     } else {

    //     }

	// 	return strBuf.getBytes().toHex();
	// }

	public function writeString(val:String) {
        for(i in 0...val.length) writeInt8(val.charCodeAt(i));
    }

	public function writeInt8(val:I8) {
		if (LE) {
			var i:U32 = 0;
			var mask:U32 = 0;
			while (i < 1) {
                #if cs 
                buf[writeOffset] = val >> mask;
                #else
                buf.push(val >> mask);
                #end
				i++;
                mask += 8;
                writeOffset +=1;
			}
		} else {}

		
	}

	public function writeInt16(val:I16) {
		if (LE) {
			var i:U32 = 0;
			var mask:U32 = 0;
			while (i < 2) {
                #if cs 
                buf[writeOffset] = val >> mask;
                #else
                buf.push(val >> mask);
                #end
				i++;
                mask += 8;
                writeOffset += 1;
			}
		} else {}
	}

	public function writeInt32(val:I32) {
		if (LE) {
			var i:U32 = 0;
			var mask:U32 = 0;
			while (i < 4) {
                #if cs 
                buf[writeOffset] = val >> mask;
                #else
                buf.push(val >> mask);
                #end
				i++;
                mask += 8;
                writeOffset += 1;
			}
		} else {}
	}

	public function writeInt64(val:I64) {
		if (LE) {
			var i:U32 = 0;
			var mask = 0;
			while (i < 8) {
                #if cpp
				var v:U8 = untyped __cpp__('static_cast<unsigned char>({0} >> {1})', val, mask);
                buf.push(v);
                #elseif cs 
                var v:U8 =  untyped __cs__('(byte)({0} >> {1})', val, mask);
                buf[writeOffset] = v;
                #end
				i++;
                mask += 8;
                writeOffset += 1;
			}
		} else {}	
    }
    
    public function writeFloat(val:Float) {
        var v:I32 = FPHelper.floatToI32(val);
        writeInt32(v);
    }

    public function writeDouble(val:Float) {
        var v:I64 = FPHelper.doubleToI64(val);
        writeInt64(v);
    }

	// public function writeUInt8(val:U8) {}
	// public function writeUInt16(val:U16) {}
	// public function writeUInt32(val:U32) {}
	// public function writeUInt64(val:U64) {}

	public function readInt8():I8 {
		var n = buf[readOffset++];
		if (n >= 128)
			return cast(n - 256);
		return cast n;
	}

	public function readInt16():I16 {
		var ch1 = buf[readOffset++];
		var ch2 = buf[readOffset++];
		var n = !LE ? ch2 | (ch1 << 8) : ch1 | (ch2 << 8);
		if (n & 0x8000 != 0)
			return cast (n - 0x10000);
		return cast n;
	}

	public function readInt32():I32 {
		var ch1 = buf[readOffset++];
		var ch2 = buf[readOffset++];
		var ch3 = buf[readOffset++];
		var ch4 = buf[readOffset++];
		return !LE ? ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24) : ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
    }
    
    public function readFloat():Float {
        var v = readInt32();
        return FPHelper.i32ToFloat(v);
    }

	public function readInt64():I64 {
		var ch1 = buf[readOffset++];
		var ch2 = buf[readOffset++];
		var ch3 = buf[readOffset++];
		var ch4 = buf[readOffset++];
		var ch5 = buf[readOffset++];
		var ch6 = buf[readOffset++];
		var ch7 = buf[readOffset++];
		var ch8 = buf[readOffset++];

		if (LE) {
			#if cpp
			var val:I64 = untyped __cpp__('static_cast<long long>({0}) |
            static_cast<long long>({1}) << 8 |
            static_cast<long long>({2}) << 16 |
            static_cast<long long>({3}) << 24 |
            static_cast<long long>({4}) << 32 |
            static_cast<long long>({5}) << 40 |
            static_cast<long long>({6}) << 48 |
            static_cast<long long>({7}) << 56', ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8);
			return cast val;
			#elseif cs
			var val:I64 = untyped __cs__('(long)({0}) |
            (long)({1}) << 8 |
            (long)({2}) << 16 |
            (long)({3}) << 24 |
            (long)({4}) << 32 |
            (long)({5}) << 40 |
            (long)({6}) << 48 |
            (long)({7}) << 56', ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8);
			return cast val;
			#end
		} else {
			return 0;
		}
    }
    
    public function readDouble():Float {
        var v:I64 = readInt64();
        return FPHelper.i64ToDouble(v.low, v.high);
    }

    public function readString():String {
        var len = buf.length - readOffset;
        if (readOffset + len > buf.length)
            return "Buffer out of range (provided length greater than buffer size)";

        var s = "";
        for(i in 0...len){
            var code = readInt8();
            s += String.fromCharCode(code);   
        }
        readOffset += len;
        return s;
    }
}
