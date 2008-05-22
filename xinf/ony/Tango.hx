/*  Copyright (c) the Xinf contributors.
	see http://xinf.org/copyright for license. */
	
package xinf.ony;

import xinf.ony.type.Paint;

/**
	Provides the colors of the 
	<a href="http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines#Color_Palette">Tango palette</a>
	as static arrays of three
	(in case of Aluminium, 6) shades, plus shortcuts to some common
	simple colors (RED, GREEN, (LIGHT_,DARK_)BLUE, (LIGHT_,DARK_)GRAY,
	YELLOW). 
**/
class Tango {
	
	public static var Butter:Array<Paint> = [ 
		RGBColor(0xfc/0xff,0xe9/0xff,0x4f/0xff),
		RGBColor(0xed/0xff,0xd4/0xff,0x00/0xff),
		RGBColor(0xc4/0xff,0xa0/0xff,0x00/0xff)
	 ];
	public static var YELLOW:Paint = Butter[0];

	public static var Orange:Array<Paint> = [ 
		RGBColor(0xfc/0xff,0xaf/0xff,0x3e/0xff),
		RGBColor(0xf5/0xff,0x79/0xff,0x00/0xff),
		RGBColor(0xce/0xff,0x5c/0xff,0x00/0xff)
	 ];
	public static var ORANGE:Paint = Orange[0];

	public static var Chocolate:Array<Paint> = [ 
		RGBColor(0xe9/0xff,0xb9/0xff,0x6e/0xff),
		RGBColor(0xc1/0xff,0x7d/0xff,0x11/0xff),
		RGBColor(0x8f/0xff,0x59/0xff,0x02/0xff)
	 ];

	public static var Chameleon:Array<Paint> = [ 
		RGBColor(0x8a/0xff,0xe2/0xff,0x34/0xff),
		RGBColor(0x73/0xff,0xd2/0xff,0x16/0xff),
		RGBColor(0x4e/0xff,0x9a/0xff,0x06/0xff)
	 ];
	public static var GREEN:Paint = Chameleon[1];

	public static var SkyBlue:Array<Paint> = [ 
		RGBColor(0x72/0xff,0x9f/0xff,0xcf/0xff),
		RGBColor(0x34/0xff,0x65/0xff,0xa4/0xff),
		RGBColor(0x20/0xff,0x4a/0xff,0x87/0xff)
	 ];
	public static var LIGHT_BLUE:Paint = SkyBlue[0];
	public static var BLUE:Paint = SkyBlue[1];
	public static var DARK_BLUE:Paint = SkyBlue[2];

	public static var Plum:Array<Paint> = [ 
		RGBColor(0xad/0xff,0x7f/0xff,0xa8/0xff),
		RGBColor(0x75/0xff,0x50/0xff,0x7b/0xff),
		RGBColor(0x5c/0xff,0x35/0xff,0x66/0xff)
	 ];

	public static var ScarletRed:Array<Paint> = [ 
		RGBColor(0xef/0xff,0x29/0xff,0x29/0xff),
		RGBColor(0xcc/0xff,0x00/0xff,0x00/0xff),
		RGBColor(0xa4/0xff,0x00/0xff,0x00/0xff)
	 ];
	public static var RED:Paint = ScarletRed[1];

	public static var Aluminium:Array<Paint> = [ 
		RGBColor(0xee/0xff,0xee/0xff,0xec/0xff),
		RGBColor(0xd3/0xff,0xd7/0xff,0xcf/0xff),
		RGBColor(0xba/0xff,0xbd/0xff,0xb6/0xff),
		RGBColor(0x88/0xff,0x8a/0xff,0x85/0xff),
		RGBColor(0x55/0xff,0x57/0xff,0x53/0xff),
		RGBColor(0x2e/0xff,0x34/0xff,0x36/0xff)
	 ];
	public static var LIGHT_GRAY:Paint = Aluminium[1];
	public static var GRAY:Paint = Aluminium[2];
	public static var DARK_GRAY:Paint = Aluminium[4];
#end
}
