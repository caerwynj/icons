implement MkBounceIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkBounceIcon: module
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
	bg := display.rgb(222, 226, 232);
	icon.draw(all, bg, nil, Point(0,0));

	dots := display.rgb(140, 146, 158);
	ball := display.rgb(220, 60, 56);
	hi   := display.rgb(250, 150, 146);
	gnd  := display.rgb(90, 96, 108);

	# Dotted bounce trajectory: a parabola y = a*(x-14)^2 + 5.
	for(x := 3; x <= 25; x += 2) {
		dx := x - 14;
		y := 5 + (dx*dx)*16/121;	# ~16 at edges, 5 at apex
		icon.draw(Rect(Point(x,y), Point(x+1,y+1)), dots, nil, Point(0,0));
	}

	# Ground line.
	icon.draw(Rect(Point(2,24), Point(26,26)), gnd, nil, Point(0,0));

	# Ball part-way down the right side of the arc.
	bc := Point(21,15);
	icon.fillellipse(bc, 4, 4, ball, Point(0,0));
	icon.fillellipse(Point(bc.x-1,bc.y-1), 1, 1, hi, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Bounce/icons/!Bounce.bit",  icon);
	writeimg("/usr/inferno/!Bounce/icons/!Bounce.mask", mask);
	sys->print("wrote !Bounce\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
