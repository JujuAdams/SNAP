var _count = 1000;
var _t = get_timer();
repeat(_count) SnapMD5(struct);
draw_text(10, 10, string((get_timer() - _t) / 1000) + "us");