implement MkOwenSchedIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkOwenSchedIcon: module
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

	# Gantt-style schedule: stacked horizontal job bars with a "now" marker.
	track := display.rgb(150, 156, 168);
	green := display.rgb(70, 180, 100);	# done
	blue  := display.rgb(70, 130, 220);	# running
	amber := display.rgb(238, 180, 60);	# queued
	now   := display.rgb(220, 60, 56);

	# Three job rows, each with a faint track and a coloured bar of varying span.
	for(i := 0; i < 3; i++) {
		y := 6 + i*6;
		icon.draw(Rect(Point(3,y),  Point(25,y+1)), track, nil, Point(0,0));
	}
	icon.draw(Rect(Point(4,5),  Point(18,9)),  green, nil, Point(0,0));
	icon.draw(Rect(Point(8,11), Point(22,15)), blue,  nil, Point(0,0));
	icon.draw(Rect(Point(15,17),Point(24,21)), amber, nil, Point(0,0));

	# "Now" indicator: a vertical red line across the rows.
	icon.draw(Rect(Point(14,3), Point(15,23)), now, nil, Point(0,0));
	# Top arrow head for the now marker.
	icon.draw(Rect(Point(13,3), Point(16,4)), now, nil, Point(0,0));
	icon.draw(Rect(Point(12,2), Point(17,3)), now, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!OwenSched/icons/!OwenSched.bit",  icon);
	writeimg("/usr/inferno/!OwenSched/icons/!OwenSched.mask", mask);
	sys->print("wrote !OwenSched\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
