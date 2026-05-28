implement MkMemoryIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkMemoryIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "mkmemoryicon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	bg := display.rgb(214, 218, 226);
	icon.draw(all, bg, nil, Point(0,0));

	# RAM module: green PCB.
	pcb  := display.rgb(34, 138, 70);
	edge := display.rgb(20, 96, 48);
	icon.draw(Rect(Point(2,7),  Point(26,21)), edge, nil, Point(0,0));
	icon.draw(Rect(Point(3,8),  Point(25,20)), pcb,  nil, Point(0,0));

	# Black memory chips along the board.
	chip := display.rgb(28, 28, 32);
	for(i := 0; i < 3; i++) {
		x := 5 + i*7;
		icon.draw(Rect(Point(x,10), Point(x+5,16)), chip, nil, Point(0,0));
	}

	# Gold contact pins along the bottom edge, with a keying notch.
	gold := display.rgb(224, 184, 64);
	for(p := 0; p < 11; p++) {
		x := 4 + p*2;
		if(x == 14)	# notch gap
			continue;
		icon.draw(Rect(Point(x,20), Point(x+1,21)), gold, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Memory/icons/!Memory.bit",  icon);
	writeimg("/usr/inferno/!Memory/icons/!Memory.mask", mask);
	sys->print("wrote !Memory\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkmemoryicon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
