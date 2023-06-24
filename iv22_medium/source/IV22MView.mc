import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class IV22MView extends WatchUi.WatchFace {
    // The dot image is stored after digit 9
    private enum {dot = 10}
    private var digits = new Array<BitmapReference>[11];

    // The position of hours, minutes and dots
    private var xd as Dictionary<Symbol, Number> = {};
    private var yd as Dictionary<Symbol, Number> = {};

    // Dimensions of the drawable area
    private var da_width as Number = 0;
    private var da_height as Number = 0;

    // Always On Display burn-in protection mode
    private var in_aod_mode as Boolean = false;

    // In AOD mode, if any pixel is on for longer than 3 minutes, the system
    // will shut off the screen. Use these 4 layers for masking.
    private var mask_layers = new Array<Layer>[4];

    // Allocate a new layer and fill it with a pattern
    private function initMaskLayer(n as Number) {
        var bitmap = Graphics.createBufferedBitmap({:width=>2, :height=>2});
        var dc = bitmap.get().getDc();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        dc.drawPoint((n >> 1) & 1, n & 1);
        var texture = new Graphics.BitmapTexture({:bitmap=>bitmap});

        var layer = new Layer({:locX=>xd[:h1], :locY=>yd[:h1], :width=>da_width,
                               :height=>da_height, :visibility=>false});
        addLayer(layer);
        mask_layers[n] = layer;
        layer.getDc().setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        layer.getDc().setFill(texture);
        layer.getDc().fillRectangle(0, 0, da_width, da_height);
    }

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

        var dx1 = 16;
        var dx2 = 22;
        var dx3 = 18;
        var dx4 = 54;
        var dy = 22;
        var dig_width = digits[0].getWidth();
        var dig_height = digits[0].getHeight();
        var dot_height = digits[dot].getHeight();

        da_width = 4 * dig_width + 2 * dx1 + dx4;
        da_height = dig_height;

        var x = (dc.getWidth() - da_width) / 2;
        var y = (dc.getHeight() - da_height) / 2;

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
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // This is ridiculous, but you can't draw on a layer in onLayout(),
        // for this reason mask_layers are initialized here.
        if (mask_layers[0] == null) {
            for (var i = 0; i < mask_layers.size(); i++) {
                initMaskLayer(i);
            }
        }
        for (var i = 0; i < mask_layers.size(); i++) {
            mask_layers[i].setVisible(false);
        }

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
        dc.drawBitmap(xd[:h1], yd[:h1], digits[h1]);
        dc.drawBitmap(xd[:h2], yd[:h2], digits[h2]);
        dc.drawBitmap(xd[:d1], yd[:d1], digits[dot]);
        dc.drawBitmap(xd[:d2], yd[:d2], digits[dot]);
        dc.drawBitmap(xd[:m1], yd[:m1], digits[m1]);
        dc.drawBitmap(xd[:m2], yd[:m2], digits[m2]);

        if (in_aod_mode) {
            mask_layers[time.min % mask_layers.size()].setVisible(true);
        }
    }

    // The user has just looked at their watch. Timers and animations may be
    // started here.
    function onExitSleep() as Void {
        in_aod_mode = false;
        requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        in_aod_mode = System.getDeviceSettings().requiresBurnInProtection;
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
