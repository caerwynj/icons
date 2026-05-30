implement MkPenIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkPenIcon: module
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

	body   := display.rgb(40, 70, 140);	# navy barrel
	silver := display.rgb(200, 200, 210);
	nib    := display.rgb(60, 60, 70);
	ink    := display.rgb(20, 20, 24);

	# Fountain pen at a diagonal: barrel, silver section, and nib tip.
	icon.line(Point(5,23),  Point(20,8),  Draw->Endsquare, Draw->Endsquare, 2, body,   Point(0,0));
	icon.line(Point(20,8),  Point(23,5),  Draw->Endsquare, Draw->Endsquare, 2, silver, Point(0,0));
	icon.line(Point(23,5),  Point(25,3),  Draw->Endsquare, Draw->Endsquare, 1, nib,    Point(0,0));

	# Ink stroke under the pen tip suggesting writing.
	for(x := 3; x <= 14; x++) {
		y := 26 - ((x-3)/3);
		icon.draw(Rect(Point(x,y), Point(x+1,y+1)), ink, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Pen/icons/!Pen.bit",  icon);
	writeimg("/usr/inferno/!Pen/icons/!Pen.mask", mask);
	sys->print("wrote !Pen\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
