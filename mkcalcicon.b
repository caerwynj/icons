implement MkCalcIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkCalcIcon: module
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
		sys->fprint(sys->fildes(2), "mkcalcicon: no display: %r\n");
		return;
	}

	W := 28;
	H := 28;
	all := Rect(Point(0,0), Point(W,H));

	# Colours (replicated source images).
	body   := display.rgb(56, 64, 92);	# dark blue-grey case
	bezel  := display.rgb(96, 104, 132);	# lighter edge highlight
	screen := display.rgb(176, 214, 168);	# pale LCD green
	btn    := display.rgb(208, 208, 214);	# light grey keys
	eq     := display.rgb(240, 150, 40);	# orange "=" key

	# --- the .bit (CMAP8 colour image) ---
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	# case with a 1px lighter bezel
	icon.draw(Rect(Point(2,1), Point(26,27)), bezel, nil, Point(0,0));
	icon.draw(Rect(Point(3,2), Point(25,26)), body,  nil, Point(0,0));

	# LCD screen
	icon.draw(Rect(Point(5,4), Point(23,10)), screen, nil, Point(0,0));

	# 3x3 key grid; bottom-right key is the orange "="
	xs := array[] of {5, 12, 19};
	ys := array[] of {13, 18, 23};
	for(r := 0; r < 3; r++)
		for(c := 0; c < 3; c++) {
			col := btn;
			if(r == 2 && c == 2)
				col = eq;
			p0 := Point(xs[c], ys[r]);
			p1 := Point(xs[c]+4, ys[r]+3);
			icon.draw(Rect(p0, p1), col, nil, Point(0,0));
		}

	# --- the .mask (GREY1: white = opaque) ---
	mask := display.newimage(all, draw->GREY1, 0, draw->Black);
	mask.draw(Rect(Point(2,1), Point(26,27)), display.white, nil, Point(0,0));

	writeimg("/usr/inferno/!Calc/icons/!Calc.bit",  icon);
	writeimg("/usr/inferno/!Calc/icons/!Calc.mask", mask);
	sys->print("wrote !Calc.bit and !Calc.mask\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkcalcicon: create %s: %r\n", path);
		return;
	}
	if(display.writeimage(fd, img) < 0)
		sys->fprint(sys->fildes(2), "mkcalcicon: writeimage %s: %r\n", path);
}
