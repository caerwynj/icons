implement MkEditIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkEditIcon: module
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
	bg := display.rgb(210, 214, 222);
	icon.draw(all, bg, nil, Point(0,0));

	# Document page.
	icon.draw(Rect(Point(5,3),  Point(22,25)), display.rgb(80,80,80), nil, Point(0,0));
	icon.draw(Rect(Point(6,4),  Point(21,24)), display.white, nil, Point(0,0));
	# Text lines.
	line := display.rgb(120, 130, 150);
	for(i := 0; i < 5; i++) {
		y := 7 + i*3;
		w := 13;
		if(i == 4) w = 8;
		icon.draw(Rect(Point(8,y), Point(8+w,y+1)), line, nil, Point(0,0));
	}

	# Pencil across the page (handle, wood tip, graphite, eraser).
	wood  := display.rgb(240, 196, 60);
	tip   := display.rgb(230, 210, 170);
	lead  := display.rgb(40, 40, 40);
	erase := display.rgb(230, 110, 140);
	icon.line(Point(9,25), Point(23,8), Draw->Endsquare, Draw->Endsquare, 2, wood, Point(0,0));
	icon.line(Point(21,11), Point(24,6), Draw->Endsquare, Draw->Endsquare, 2, tip, Point(0,0));
	icon.line(Point(23,8), Point(25,5), Draw->Endsquare, Draw->Endsquare, 1, lead, Point(0,0));
	icon.line(Point(8,26), Point(10,23), Draw->Endsquare, Draw->Endsquare, 2, erase, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Edit/icons/!Edit.bit",  icon);
	writeimg("/usr/inferno/!Edit/icons/!Edit.mask", mask);
	sys->print("wrote !Edit\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
