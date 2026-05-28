implement MkAcmeIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkAcmeIcon: module
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

	frame := display.rgb(70, 70, 70);
	tag   := display.rgb(150, 215, 220);	# acme cyan tag bar
	body  := display.rgb(255, 255, 226);	# acme pale yellow text area
	text  := display.rgb(90, 90, 90);

	# Window with a tag bar and two columns (acme's signature layout).
	icon.draw(Rect(Point(3,3),  Point(25,25)), frame, nil, Point(0,0));
	icon.draw(Rect(Point(4,4),  Point(24,8)),  tag,   nil, Point(0,0));	# tag bar
	icon.draw(Rect(Point(4,8),  Point(13,24)), body,  nil, Point(0,0));	# left column
	icon.draw(Rect(Point(15,8), Point(24,24)), body,  nil, Point(0,0));	# right column
	# column divider + per-column tag stripes
	icon.draw(Rect(Point(13,8), Point(15,24)), frame, nil, Point(0,0));
	icon.draw(Rect(Point(4,8),  Point(13,10)), tag,   nil, Point(0,0));
	icon.draw(Rect(Point(15,8), Point(24,10)), tag,   nil, Point(0,0));

	# A few text lines.
	for(i := 0; i < 4; i++) {
		y := 12 + i*3;
		icon.draw(Rect(Point(5,y),  Point(12,y+1)), text, nil, Point(0,0));
		icon.draw(Rect(Point(16,y), Point(23,y+1)), text, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Acme/icons/!Acme.bit",  icon);
	writeimg("/usr/inferno/!Acme/icons/!Acme.mask", mask);
	sys->print("wrote !Acme\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
