implement MkDebuggerIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkDebuggerIcon: module
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

	black := display.rgb(24, 24, 28);
	red   := display.rgb(212, 40, 40);

	# Legs (drawn first, behind the body).
	for(i := 0; i < 3; i++) {
		y := 11 + i*4;
		icon.line(Point(13,y), Point(4, y-2), Draw->Endsquare, Draw->Endsquare, 1, black, Point(0,0));
		icon.line(Point(15,y), Point(24, y-2), Draw->Endsquare, Draw->Endsquare, 1, black, Point(0,0));
	}

	# Ladybird body (red) and head (black).
	icon.fillellipse(Point(14,16), 8, 9, red, Point(0,0));
	icon.fillellipse(Point(14,7), 4, 3, black, Point(0,0));
	# Antennae.
	icon.line(Point(12,5), Point(10,2), Draw->Endsquare, Draw->Endsquare, 0, black, Point(0,0));
	icon.line(Point(16,5), Point(18,2), Draw->Endsquare, Draw->Endsquare, 0, black, Point(0,0));

	# Wing split line and spots.
	icon.draw(Rect(Point(14,9), Point(15,24)), black, nil, Point(0,0));
	icon.fillellipse(Point(10,14), 1, 1, black, Point(0,0));
	icon.fillellipse(Point(18,14), 1, 1, black, Point(0,0));
	icon.fillellipse(Point(10,19), 1, 1, black, Point(0,0));
	icon.fillellipse(Point(18,19), 1, 1, black, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Debugger/icons/!Debugger.bit",  icon);
	writeimg("/usr/inferno/!Debugger/icons/!Debugger.mask", mask);
	sys->print("wrote !Debugger\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
