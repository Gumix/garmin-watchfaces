import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Properties;

// Display names of the "seconds_mode" property.
// Keep in sync with "settings.xml".
const SECONDS_NAMES as Array<String> = [ "Off", "Dot", "Ring" ];

// The app settings menu.
class IV22LMenu extends WatchUi.Menu2 {

    (:disable_seconds)
    private function addSecondsItem() as Void {
        Menu2.addItem(new WatchUi.MenuItem(
            "Seconds", "Not supported", null, null));
    }

    (:enable_seconds)
    private function addSecondsItem() as Void {
        var seconds_mode = Properties.getValue("seconds_mode") as Number;
        if (seconds_mode >= SECONDS_NAMES.size()) {
            seconds_mode = 0;
        }
        Menu2.addItem(new WatchUi.MenuItem(
            "Seconds", SECONDS_NAMES[seconds_mode], "seconds_mode", null));
    }

    function initialize() {
        var app_name = WatchUi.loadResource(Rez.Strings.AppName) as String;
        Menu2.initialize({:title => app_name});

        addSecondsItem();
    }
}

// Input handler for the app settings menu.
class IV22LMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // Handle a menu item being selected.
    function onSelect(menuItem as MenuItem) as Void {
        var id = menuItem.getId();
        if (id == null) {
            return;
        }
        if (id.equals("seconds_mode")) {
            var seconds_mode = Properties.getValue("seconds_mode") as Number;
            seconds_mode = (seconds_mode + 1) % SECONDS_NAMES.size();
            menuItem.setSubLabel(SECONDS_NAMES[seconds_mode]);
            Properties.setValue("seconds_mode", seconds_mode);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
