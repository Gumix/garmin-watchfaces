import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class IV22LView extends WatchUi.WatchFace {
    const DX = 26;
    const DY = 42;

    var digits;
    var aod_textures;

    var x1 as Number = 0;
    var y1 as Number = 0;
    var x2 as Number = 0;
    var y2 as Number = 0;

    /* Always On Display burn-in protection mode */
    var in_aod_mode = false;

    function initialize() {
        WatchFace.initialize();
    }

    private function createTexture(x as Number) {
        var bitmap = Graphics.createBufferedBitmap({:width => 2, :height => 1});
        var dc = bitmap.get().getDc();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        dc.drawPoint(x, 0);
        return new Graphics.BitmapTexture({ :bitmap => bitmap });
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        digits = [
            WatchUi.loadResource(Rez.Drawables.Dig0),
            WatchUi.loadResource(Rez.Drawables.Dig1),
            WatchUi.loadResource(Rez.Drawables.Dig2),
            WatchUi.loadResource(Rez.Drawables.Dig3),
            WatchUi.loadResource(Rez.Drawables.Dig4),
            WatchUi.loadResource(Rez.Drawables.Dig5),
            WatchUi.loadResource(Rez.Drawables.Dig6),
            WatchUi.loadResource(Rez.Drawables.Dig7),
            WatchUi.loadResource(Rez.Drawables.Dig8),
            WatchUi.loadResource(Rez.Drawables.Dig9)
        ] as Array<Graphics.BitmapReference>;
 
        aod_textures = [
            createTexture(0), createTexture(1)
        ] as Array<Graphics.BitmapTexture>;

        var dig_width = digits[0].getWidth();
        var dig_height = digits[0].getHeight();

        x1 = (dc.getWidth() - 2 * dig_width - DX) / 2;
        y1 = (dc.getHeight() - 2 * dig_height - DY) / 2;
        x2 = x1 + dig_width + DX;
        y2 = y1 + dig_height + DY;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
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
        dc.drawBitmap(x1, y1, digits[h1]);
        dc.drawBitmap(x2, y1, digits[h2]);
        dc.drawBitmap(x1, y2, digits[m1]);
        dc.drawBitmap(x2, y2, digits[m2]);

        if (in_aod_mode) {
            var width = 2 * digits[0].getWidth() + DX;
            var height = 2 * digits[0].getHeight() + DY;

            dc.setFill(aod_textures[time.min % 2]);
            dc.fillRectangle(x1, y1, width, height);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        in_aod_mode = false;
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        in_aod_mode = System.getDeviceSettings().requiresBurnInProtection;
        WatchUi.requestUpdate();
    }
}
