import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Properties;

// The app settings menu
class IV22MMenu extends WatchUi.Menu2 {

    function initialize() {
        var app_name = WatchUi.loadResource(Rez.Strings.AppName) as String;
        Menu2.initialize({:title => app_name});

        var device = System.getDeviceSettings();
        if (device.screenWidth > 360 && device.screenHeight > 360) {
            var item_id = "show_seconds";
            var is_enabled = Properties.getValue(item_id);
            Menu2.addItem(new WatchUi.ToggleMenuItem("Show seconds", null,
                                                     item_id, is_enabled, null));
            item_id = "seconds_as_dot";
            is_enabled = Properties.getValue(item_id);
            Menu2.addItem(new WatchUi.ToggleMenuItem("Single dot vs.",
                                                     "progress bar",
                                                     item_id, is_enabled, null));
        }
    }
}

// Input handler for the app settings menu
class IV22MMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // Handle a menu item being selected
    function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof ToggleMenuItem) {
            Properties.setValue(menuItem.getId() as String, menuItem.isEnabled());
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
