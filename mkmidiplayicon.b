implement MkMidiPlayIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkMidiPlayIcon: module
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

	# Faint staff lines.
	staff := display.rgb(186, 190, 200);
	for(i := 0; i < 4; i++) {
		y := 7 + i*5;
		icon.draw(Rect(Point(3,y), Point(25,y+1)), staff, nil, Point(0,0));
	}

	note := display.rgb(30, 60, 150);
	# Two beamed eighth notes: heads, stems, beam.
	icon.fillellipse(Point(9,20), 3, 2, note, Point(0,0));
	icon.fillellipse(Point(19,17), 3, 2, note, Point(0,0));
	icon.draw(Rect(Point(11,7),  Point(13,20)), note, nil, Point(0,0));	# left stem
	icon.draw(Rect(Point(21,5),  Point(23,17)), note, nil, Point(0,0));	# right stem
	icon.draw(Rect(Point(11,5),  Point(23,8)),  note, nil, Point(0,0));	# beam

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!MidiPlay/icons/!MidiPlay.bit",  icon);
	writeimg("/usr/inferno/!MidiPlay/icons/!MidiPlay.mask", mask);
	sys->print("wrote !MidiPlay\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
