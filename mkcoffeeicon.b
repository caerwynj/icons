implement MkCoffeeIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkCoffeeIcon: module
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

	outline := display.rgb(70, 70, 78);
	cup     := display.white;
	coffee  := display.rgb(110, 66, 30);
	steam   := display.rgb(180, 188, 200);

	# Steam wisps above the cup.
	for(i := 0; i < 3; i++) {
		x := 9 + i*4;
		icon.draw(Rect(Point(x,3),   Point(x+1,6)), steam, nil, Point(0,0));
		icon.draw(Rect(Point(x+1,6), Point(x+2,9)), steam, nil, Point(0,0));
	}

	# Mug body with outline.
	icon.draw(Rect(Point(6,11),  Point(20,24)), outline, nil, Point(0,0));
	icon.draw(Rect(Point(7,12),  Point(19,23)), cup,     nil, Point(0,0));
	# Coffee surface.
	icon.draw(Rect(Point(8,12),  Point(18,15)), coffee,  nil, Point(0,0));

	# Handle (ring on the right).
	icon.ellipse(Point(20,17), 3, 3, 1, outline, Point(0,0));

	# Saucer.
	icon.fillellipse(Point(13,25), 11, 2, outline, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Coffee/icons/!Coffee.bit",  icon);
	writeimg("/usr/inferno/!Coffee/icons/!Coffee.mask", mask);
	sys->print("wrote !Coffee\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
