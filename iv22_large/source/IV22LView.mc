import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application.Properties;

class IV22LView extends WatchUi.WatchFace {

    // The dot image is stored after digit 9.
    private enum {dot = 10}

    // Bitmap references for digits 0-9 and the dot, stored in 2 formats:
    // 24-bit RGB (Natural Color) and 8-bit GrayScale (for tinting).
    private var images_nc as Array<BitmapReference> = new Array<BitmapReference>[11];
    private var images_gs as Array<BitmapReference> = new Array<BitmapReference>[11];

    // Positions of hour and minute digits.
    private var xd as Array<Number> = new Array<Number>[2];
    private var yd as Array<Number> = new Array<Number>[2];

    // Positions of second marks.
    private var xs as Array<Number> = new Array<Number>[60];
    private var ys as Array<Number> = new Array<Number>[60];

    // Dimensions of the drawable area.
    private var da_width as Number = 0;
    private var da_height as Number = 0;

    // In low power mode the second marks are not displayed.
    private var in_sleep_mode as Boolean = false;

    // PNG packing format is not supported by some devices.
    (:disable_tint)
    function drawBitmap(dc as Dc, x as Number, y as Number, bmp_id as Number,
                        color as Number) as Void {
        dc.drawBitmap(x, y, images_nc[bmp_id]);
    }

    (:enable_tint)
    function drawBitmap(dc as Dc, x as Number, y as Number, bmp_id as Number,
                        color as Number) as Void {
        if (color == 0x000000) {
            // Natural color (no tint).
            dc.drawBitmap(x, y, images_nc[bmp_id]);
        } else {
            dc.drawBitmap2(x, y, images_gs[bmp_id], {:tintColor => color});
        }
    }

    function initialize() {
        WatchFace.initialize();
    }

    // Load resources and precompute the positions.
    function onLayout(dc as Dc) as Void {
        images_nc[0] = loadResource(Rez.Drawables.Dig0NC);
        images_nc[1] = loadResource(Rez.Drawables.Dig1NC);
        images_nc[2] = loadResource(Rez.Drawables.Dig2NC);
        images_nc[3] = loadResource(Rez.Drawables.Dig3NC);
        images_nc[4] = loadResource(Rez.Drawables.Dig4NC);
        images_nc[5] = loadResource(Rez.Drawables.Dig5NC);
        images_nc[6] = loadResource(Rez.Drawables.Dig6NC);
        images_nc[7] = loadResource(Rez.Drawables.Dig7NC);
        images_nc[8] = loadResource(Rez.Drawables.Dig8NC);
        images_nc[9] = loadResource(Rez.Drawables.Dig9NC);
        images_nc[dot] = loadResource(Rez.Drawables.DotNC);

        images_gs[0] = loadResource(Rez.Drawables.Dig0GS);
        images_gs[1] = loadResource(Rez.Drawables.Dig1GS);
        images_gs[2] = loadResource(Rez.Drawables.Dig2GS);
        images_gs[3] = loadResource(Rez.Drawables.Dig3GS);
        images_gs[4] = loadResource(Rez.Drawables.Dig4GS);
        images_gs[5] = loadResource(Rez.Drawables.Dig5GS);
        images_gs[6] = loadResource(Rez.Drawables.Dig6GS);
        images_gs[7] = loadResource(Rez.Drawables.Dig7GS);
        images_gs[8] = loadResource(Rez.Drawables.Dig8GS);
        images_gs[9] = loadResource(Rez.Drawables.Dig9GS);
        images_gs[dot] = loadResource(Rez.Drawables.DotGS);

        var dc_width = dc.getWidth();
        var dc_height = dc.getHeight();
        var dig_width = images_nc[0].getWidth();
        var dig_height = images_nc[0].getHeight();
        var dot_size = images_nc[dot].getWidth();
        var dx = 26;
        var dy = 42;
        da_width = 2 * dig_width + dx;
        da_height = 2 * dig_height + dy;

        xd[0] = (dc_width - da_width) / 2;
        yd[0] = (dc_height - da_height) / 2;
        xd[1] = xd[0] + dig_width + dx;
        yd[1] = yd[0] + dig_height + dy;

        var xc = (dc_width - dot_size) / 2;
        var yc = (dc_height - dot_size) / 2;
        var r = xc < yc ? xc : yc;
        for (var s = 0; s < 60; s++) {
            var angle = Math.toRadians(90 - s * 6);
            var cos = Math.cos(angle);
            var sin = Math.sin(angle);
            xs[s] = Math.round(xc + r * cos);
            ys[s] = Math.round(yc - r * sin);
        }
    }

    // Update the view.
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

        var color = Properties.getValue("color") as Number;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        drawBitmap(dc, xd[0], yd[0], h1, color);
        drawBitmap(dc, xd[1], yd[0], h2, color);
        drawBitmap(dc, xd[0], yd[1], m1, color);
        drawBitmap(dc, xd[1], yd[1], m2, color);

        // Do not show second marks on small screens, because they will overlap
        // the digits.
        var show_seconds = !in_sleep_mode
                           && dc.getWidth() > 390
                           && dc.getHeight() > 390
                           && Properties.getValue("show_seconds");
        if (show_seconds) {
            if (Properties.getValue("seconds_as_dot")) {
                // Show seconds as a single dot.
                drawBitmap(dc, xs[time.sec], ys[time.sec], dot, color);
            } else {
                // Show seconds as a progress bar.
                for (var s = 0; s <= time.sec; s++) {
                    drawBitmap(dc, xs[s], ys[s], dot, color);
                }
            }
        }

        // In AOD mode, if any pixel is on for longer than 3 minutes, the system
        // will shut off the screen. Use alternating line pattern for masking.
        var in_aod_mode = in_sleep_mode
                          && System.getDeviceSettings().requiresBurnInProtection;
        if (in_aod_mode) {
            for (var i = 0; i < da_width; i += 2) {
                var x = xd[0] + i + time.min % 2;
                dc.drawLine(x, yd[0], x, yd[0] + da_height);
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
