/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */

import cptr.CPtr;

class TestCPtr extends haxe.unit.TestCase {
	function testInt() {
		var n:Int = 1024;
		var ptr = CPtr.int_alloc(n);
		
		for( i in 0...n ) {
			CPtr.int_set(ptr,i,i*10);
		}
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.int_get(ptr,i) );
		}
	}

	function testUInt() {
		var n:Int = 1024;
		var ptr = CPtr.uint_alloc(n);
		
		for( i in 0...n ) {
			CPtr.uint_set(ptr,i,i*10);
		}
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.uint_get(ptr,i) );
		}
	}

	function testShort() {
		var n:Int = 1024;
		var ptr = CPtr.short_alloc(n);
		
		for( i in 0...n ) {
			CPtr.short_set(ptr,i,i*10);
		}
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.short_get(ptr,i) );
		}
	}

	function testUShort() {
		var n:Int = 1024;
		var ptr = CPtr.ushort_alloc(n);
		
		for( i in 0...n ) {
			CPtr.ushort_set(ptr,i,i*10);
		}
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.ushort_get(ptr,i) );
		}
	}

	function testChar() {
		var n:Int = -128;
		var m:Int = 128;
		var ptr = CPtr.char_alloc(m-n);
		
		for( i in n...m ) {
			CPtr.char_set(ptr,i-n,i);
		}
		for( i in n...m ) {
			assertEquals( i, CPtr.char_get(ptr,i-n) );
		}
	}
	
	function testUChar() {
		var n:Int = 0;
		var m:Int = 255;
		var ptr = CPtr.uchar_alloc(m-n);
		
		for( i in n...m ) {
			CPtr.uchar_set(ptr,i-n,i);
		}
		for( i in n...m ) {
			assertEquals( i, CPtr.uchar_get(ptr,i-n) );
		}
	}
	
	function testFloat() {
		var n:Int = 1024;
		var ptr = CPtr.float_alloc(n);
		
		for( i in 0...n ) {
			CPtr.float_set(ptr,i,i*10);
		}
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.float_get(ptr,i) );
		}
	}

	function testDouble() {
		var n:Int = 1024;
		var ptr = CPtr.double_alloc(n);
		
		for( i in 0...n ) {
			CPtr.double_set(ptr,i,i/10);
		}
		for( i in 0...n ) {
			assertEquals( i/10, CPtr.double_get(ptr,i) );
		}
	}
	
	function testIntFromArray() {
		var n:Int = 32;
		var ptr = CPtr.int_alloc(n);
		var a = new Array<Int>();
		
		for( i in 0...n ) {
			a[i] = i*10;
		}
		CPtr.int_from_array( ptr, untyped a.__a );
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.int_get(ptr,i) );
		}
	}
	
	function testIntToArray() {
		var n:Int = 1024;
		var ptr = CPtr.int_alloc(n);
		var a:Array<Int>;
		
		for( i in 0...n ) {
			CPtr.int_set(ptr,i,i*10);
		}
		a = CPtr.int_to_array( ptr, 0, n );
		for( i in 0...n ) {
			assertEquals( i*10, a[i] );
		}
	}

	function testFloatFromArray() {
		var n:Int = 32;
		var ptr = CPtr.float_alloc(n);
		var a = new Array<Float>();
		
		for( i in 0...n ) {
			a[i] = i*10;
		}
		CPtr.float_from_array( ptr, untyped a.__a );
		for( i in 0...n ) {
			assertEquals( i*10, CPtr.float_get(ptr,i) );
		}
	}
	
	function testFloatToArray() {
		var n:Int = 1024;
		var ptr = CPtr.float_alloc(n);
		var a:Array<Int>;
		
		for( i in 0...n ) {
			CPtr.float_set(ptr,i,i*10);
		}
		a = CPtr.float_to_array( ptr, 0, n );
		for( i in 0...n ) {
			assertEquals( i*10, a[i] );
		}
	}

	function testIndexOutOfBounds() {
		var ptr = CPtr.double_alloc(2);
		try {
			CPtr.double_set( ptr, 3, 1 );
		} catch( e:String ) {
			assertEquals( "cptr overflow", e );
			return;
		}
		try {
			CPtr.double_set( ptr, -1, 1 );
		} catch( e:String ) {
			assertEquals( "cptr overflow", e );
			return;
		}
		assertTrue( false );
	}

	function testCast() {
		var ptr = CPtr.uint_alloc(1);
		CPtr.uint_set( ptr, 0, 0xffffffff );
		
		for( i in 0...4 ) {
			assertEquals( 0xff, CPtr.uchar_get(ptr,i) );
		}
	}

	function testAsString() {
		var ptr = CPtr.short_alloc(2);
		CPtr.uchar_set( ptr, 0, 0x41 );
		CPtr.uchar_set( ptr, 1, 0x42 );
		CPtr.uchar_set( ptr, 2, 0x43 );
		CPtr.uchar_set( ptr, 3, 0x44 );
		
		assertEquals( "ABCD", neko.Lib.nekoToHaxe( ptr ) );
	}

	function testFromString() {
		var ptr = neko.Lib.haxeToNeko("ABCD");
		
		assertEquals( 0x41, CPtr.uchar_get(ptr,0) );
		assertEquals( 0x42, CPtr.uchar_get(ptr,1) );
		assertEquals( 0x43, CPtr.uchar_get(ptr,2) );
		assertEquals( 0x44, CPtr.uchar_get(ptr,3) );
	}
}

class App {
	public static function main() {
		var r = new haxe.unit.TestRunner();
		r.add( new TestCPtr() );
		r.run();
	}
}
