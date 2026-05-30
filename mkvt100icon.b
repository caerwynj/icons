implement MkVt100Icon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkVt100Icon: module
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
	bg := display.rgb(214, 218, 226);
	icon.draw(all, bg, nil, Point(0,0));

	beige := display.rgb(206, 196, 168);	# beige CRT case
	bezel := display.rgb(160, 150, 122);
	crt   := display.rgb(20, 28, 22);
	green := display.rgb(80, 220, 110);

	# CRT case with screen bezel.
	icon.draw(Rect(Point(2,3),  Point(26,21)), bezel, nil, Point(0,0));
	icon.draw(Rect(Point(3,4),  Point(25,20)), beige, nil, Point(0,0));
	icon.draw(Rect(Point(5,6),  Point(23,18)), crt,   nil, Point(0,0));

	# Stand and base.
	icon.draw(Rect(Point(11,21), Point(17,24)), bezel, nil, Point(0,0));
	icon.draw(Rect(Point(6,24),  Point(22,26)), beige, nil, Point(0,0));

	# Green text lines + cursor block.
	f := Font.open(display, "/fonts/misc/ascii.5x7.font");
	if(f != nil)
		icon.text(Point(6,8), green, Point(0,0), f, "VT100");
	icon.draw(Rect(Point(6,15),  Point(15,16)), green, nil, Point(0,0));
	icon.draw(Rect(Point(16,14), Point(20,17)), green, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!VT100/icons/!VT100.bit",  icon);
	writeimg("/usr/inferno/!VT100/icons/!VT100.mask", mask);
	sys->print("wrote !VT100\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
