implement MkManualIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkManualIcon: module
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

	edge  := display.rgb(70, 70, 78);
	page  := display.white;
	spine := display.rgb(120, 130, 150);
	text  := display.rgb(120, 130, 150);

	# Open book: two facing pages with an outline.
	icon.draw(Rect(Point(2,5),  Point(26,24)), edge, nil, Point(0,0));
	icon.draw(Rect(Point(3,6),  Point(13,23)), page, nil, Point(0,0));
	icon.draw(Rect(Point(15,6), Point(25,23)), page, nil, Point(0,0));
	# Centre spine.
	icon.draw(Rect(Point(13,5), Point(15,24)), spine, nil, Point(0,0));

	# Text lines on each page.
	for(i := 0; i < 5; i++) {
		y := 9 + i*3;
		icon.draw(Rect(Point(5,y),  Point(12,y+1)), text, nil, Point(0,0));
		icon.draw(Rect(Point(16,y), Point(23,y+1)), text, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Manual/icons/!Manual.bit",  icon);
	writeimg("/usr/inferno/!Manual/icons/!Manual.mask", mask);
	sys->print("wrote !Manual\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
