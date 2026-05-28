implement MkTaskManagerIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkTaskManagerIcon: module
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

	# Monitor panel (dark) with a border.
	icon.draw(Rect(Point(2,3),  Point(26,25)), display.rgb(60,64,72), nil, Point(0,0));
	icon.draw(Rect(Point(3,4),  Point(25,24)), display.rgb(24,28,36), nil, Point(0,0));

	# Activity bars of varying height (CPU/usage graph).
	green := display.rgb(70, 210, 110);
	hs := array[] of {6, 11, 8, 14, 10, 17, 12};
	for(i := 0; i < len hs; i++) {
		x := 5 + i*3;
		h := hs[i];
		icon.draw(Rect(Point(x,23-h), Point(x+2,23)), green, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!TaskManager/icons/!TaskManager.bit",  icon);
	writeimg("/usr/inferno/!TaskManager/icons/!TaskManager.mask", mask);
	sys->print("wrote !TaskManager\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
