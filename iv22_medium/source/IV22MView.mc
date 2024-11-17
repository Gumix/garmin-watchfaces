import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;

class IV22MView extends WatchUi.WatchFace {

    // Dot images are stored after digit 9
    private enum {
		dot = 10,
		small_dot = 11
	}
    private var digits = new Array<BitmapReference>[12];

    // Positions of hours, minutes and dots
    private var xd as Dictionary<Symbol, Number> = {};
    private var yd as Dictionary<Symbol, Number> = {};

    // Positions of second marks
    private var xs = new Array<Number>[60];
    private var ys = new Array<Number>[60];

    // Dimensions of the drawable area
    private var da_width as Number = 0;
    private var da_height as Number = 0;

    // In low power mode the second marks are not displayed
    private var in_sleep_mode as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        digits[0] = loadResource(Rez.Drawables.Dig0);
        digits[1] = loadResource(Rez.Drawables.Dig1);
        digits[2] = loadResource(Rez.Drawables.Dig2);
        digits[3] = loadResource(Rez.Drawables.Dig3);
        digits[4] = loadResource(Rez.Drawables.Dig4);
        digits[5] = loadResource(Rez.Drawables.Dig5);
        digits[6] = loadResource(Rez.Drawables.Dig6);
        digits[7] = loadResource(Rez.Drawables.Dig7);
        digits[8] = loadResource(Rez.Drawables.Dig8);
        digits[9] = loadResource(Rez.Drawables.Dig9);
        digits[dot] = loadResource(Rez.Drawables.Dot);
        digits[small_dot] = loadResource(Rez.Drawables.SmallDot);

        var dx1 = 16;
        var dx2 = 22;
        var dx3 = 18;
        var dx4 = 54;
        var dy = 22;
        var dc_width = dc.getWidth();
        var dc_height = dc.getHeight();
        var dig_width = digits[0].getWidth();
        var dig_height = digits[0].getHeight();
        var dot_height = digits[dot].getHeight();
        var small_dot_size = digits[small_dot].getHeight();

        da_width = 4 * dig_width + 2 * dx1 + dx4;
        da_height = dig_height;

        var x = (dc_width - da_width) / 2;
        var y = (dc_height - da_height) / 2;

        xd[:h1] = x;
        xd[:h2] = xd[:h1] + dig_width + dx1;
        xd[:d1] = xd[:h2] + dig_width + dx2;
        xd[:d2] = xd[:h2] + dig_width + dx3;
        xd[:m1] = xd[:h2] + dig_width + dx4;
        xd[:m2] = xd[:m1] + dig_width + dx1;

        yd[:h1] = y;
        yd[:h2] = y;
        yd[:d1] = y + dy;
        yd[:d2] = y + da_height - dot_height - dy;
        yd[:m1] = y;
        yd[:m2] = y;

        var xc = (dc_width - small_dot_size) / 2;
        var yc = (dc_height - small_dot_size) / 2;
        var r = xc < yc ? xc : yc;
        for (var s = 0; s < 60; s++) {
            var angle = Math.toRadians(90 - s * 6);
            var cos = Math.cos(angle);
            var sin = Math.sin(angle);
            xs[s] = Math.round(xc + r * cos);
            ys[s] = Math.round(yc - r * sin);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var time = System.getClockTime();
        var hour = time.hour;

        var is_12hour = !System.getDeviceSettings().is24Hour;
        if (is_12hour) {
            hour = hour == 0 ? 12 : hour;
            hour = hour > 12 ? hour - 12 : hour;
        }
        var h1 = hour / 10;
        var h2 = hour % 10;
        var m1 = time.min / 10;
        var m2 = time.min % 10;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (h1 > 0 || getSetting("show_leading_zero", true)) {
            dc.drawBitmap(xd[:h1], yd[:h1], digits[h1]);
        }
        dc.drawBitmap(xd[:h2], yd[:h2], digits[h2]);
        dc.drawBitmap(xd[:d1], yd[:d1], digits[dot]);
        dc.drawBitmap(xd[:d2], yd[:d2], digits[dot]);
        dc.drawBitmap(xd[:m1], yd[:m1], digits[m1]);
        dc.drawBitmap(xd[:m2], yd[:m2], digits[m2]);

        // Do not show second marks on small screens, because they will overlap
        // the digits.
        var show_seconds = !in_sleep_mode
                           && dc.getWidth() > 360
                           && dc.getHeight() > 360
                           && getSetting("show_seconds", true);
        if (show_seconds) {
            if (getSetting("seconds_as_dot", true)) {
                // Show seconds as a single dot.
                dc.drawBitmap(xs[time.sec], ys[time.sec], digits[small_dot]);
            } else {
                // Show seconds as a progress bar.
                for (var s = 0; s <= time.sec; s++) {
                    dc.drawBitmap(xs[s], ys[s], digits[small_dot]);
                }
            }
        }

        // In AOD mode, if any pixel is on for longer than 3 minutes, the system
        // will shut off the screen. Use alternating line pattern for masking.
        var in_aod_mode = in_sleep_mode
                          && System.getDeviceSettings().requiresBurnInProtection;
        if (in_aod_mode) {
            for (var i = 0; i < da_width; i += 2) {
                var x = xd[:h1] + i + time.min % 2;
                dc.drawLine(x, yd[:h1], x, yd[:h1] + da_height);
            }
        }
    }

    // The user has just looked at their watch. Timers and animations may be
    // started here.
    function onExitSleep() as Void {
        in_sleep_mode = false;
        requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        in_sleep_mode = true;
        requestUpdate();
    }

    // Called when this View is brought to the foreground. Restore the state of
    // this View and prepare it to be shown. This includes loading resources
    // into memory.
    function onShow() as Void {
    }

    // Called when this View is removed from the screen. Save the state of
    // this View here. This includes freeing resources from memory.
    function onHide() as Void {
    }
}
