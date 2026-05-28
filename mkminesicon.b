implement MkMinesIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkMinesIcon: module
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
		sys->fprint(sys->fildes(2), "mkminesicon: no display: %r\n");
		return;
	}

	W := 28;
	H := 28;
	all := Rect(Point(0,0), Point(W,H));

	# Colours (replicated source images).
	face   := display.rgb(192, 192, 192);	# classic minesweeper grey
	hi     := display.rgb(248, 248, 248);	# top/left raised bevel
	lo     := display.rgb(112, 112, 112);	# bottom/right shadow bevel
	black  := display.rgb(0, 0, 0);		# mine body / spikes
	white  := display.white;		# specular highlight on the mine

	# --- the .bit (CMAP8 colour image) ---
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	# Raised button tile: face, then a 3px highlight on top/left and
	# a 3px shadow on bottom/right.
	icon.draw(all, face, nil, Point(0,0));
	icon.draw(Rect(Point(0,0),  Point(W,3)),   hi, nil, Point(0,0));	# top
	icon.draw(Rect(Point(0,0),  Point(3,H)),   hi, nil, Point(0,0));	# left
	icon.draw(Rect(Point(0,H-3),Point(W,H)),   lo, nil, Point(0,0));	# bottom
	icon.draw(Rect(Point(W-3,0),Point(W,H)),   lo, nil, Point(0,0));	# right

	# Spiky mine, centred.
	c := Point(14, 14);
	rs := 10;	# spike reach
	spikes := array[] of {
		Point( 0, -rs), Point( 0, rs),		# N / S
		Point(-rs, 0),  Point( rs, 0),		# W / E
		Point(-7, -7),  Point( 7,  7),		# NW / SE
		Point( 7, -7),  Point(-7,  7),		# NE / SW
	};
	for(i := 0; i < len spikes; i++)
		icon.line(c, Point(c.x+spikes[i].x, c.y+spikes[i].y),
			Draw->Endsquare, Draw->Endsquare, 1, black, Point(0,0));

	# Mine body and a small white highlight.
	icon.fillellipse(c, 6, 6, black, Point(0,0));
	icon.fillellipse(Point(11, 11), 2, 2, white, Point(0,0));

	# --- the .mask (GREY1: white = opaque). The tile is a full square. ---
	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Mines/icons/!Mines.bit",  icon);
	writeimg("/usr/inferno/!Mines/icons/!Mines.mask", mask);
	sys->print("wrote !Mines.bit and !Mines.mask\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkminesicon: create %s: %r\n", path);
		return;
	}
	if(display.writeimage(fd, img) < 0)
		sys->fprint(sys->fildes(2), "mkminesicon: writeimage %s: %r\n", path);
}
