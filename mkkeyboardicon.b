implement MkKeyboardIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkKeyboardIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) { sys->fprint(sys->fildes(2), "no display: %r\n"); return; }

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);
	bg := display.rgb(216, 220, 228);
	icon.draw(all, bg, nil, Point(0,0));

	case_ := display.rgb(60, 64, 72);
	keytop := display.rgb(220, 224, 232);

	# Keyboard body.
	icon.draw(Rect(Point(2,7),  Point(26,23)), case_, nil, Point(0,0));

	# Three rows of keys (8/8 keys).
	for(row := 0; row < 2; row++) {
		y := 9 + row*4;
		for(col := 0; col < 8; col++) {
			x := 3 + col*3;
			icon.draw(Rect(Point(x,y), Point(x+2,y+3)), keytop, nil, Point(0,0));
		}
	}
	# Wider spacebar.
	icon.draw(Rect(Point(7,17), Point(21,20)), keytop, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Keyboard/icons/!Keyboard.bit",  icon);
	writeimg("/usr/inferno/!Keyboard/icons/!Keyboard.mask", mask);
	sys->print("wrote !Keyboard\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
