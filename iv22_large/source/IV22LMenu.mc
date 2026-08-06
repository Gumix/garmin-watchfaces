import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Properties;

// Display names and values of the "color" property.
// Keep in sync with "settings.xml".
const COLOR_NAMES as Array<String> = [
    "Natural", "White", "Light Gray", "Dark Gray", "Light Red",
    "Red", "Dark Red", "Orange Red", "Orange", "Dark Orange",
    "Yellow", "Yellow Green", "Mint Green", "Lime", "Chartreuse",
    "Malachite", "Green", "Dark Green", "Olive Green", "Baby Blue",
    "Pang", "Blue Green", "Crystal Blue", "Neon Blue", "Heliotrope",
    "Pink", "Light Purple", "Purple",
];

const COLOR_VALUES as Array<Number> = [
    0x000000, 0xFFFFFF, 0xAAAAAA, 0x555555, 0xEBC2AF,
    0xFF0000, 0xAA0000, 0xFF5500, 0xFFAA00, 0xAA5500,
    0xFFD800, 0xFFFF00, 0x98FF98, 0xCCFF00, 0x7FFF00,
    0x0BDA51, 0x00FF00, 0x00AA00, 0x889F4A, 0xB3E5FF,
    0xC7FFEC, 0x89EFD2, 0x4FC3FF, 0x0000FF, 0xDF73FF,
    0xFF00FF, 0xCCCCFF, 0xAA00FF,
];

// Display names of the "seconds_mode" property.
// Keep in sync with "settings.xml".
const SECONDS_NAMES as Array<String> = [ "Off", "Dot", "Ring" ];

// Look up the display name for a value in a (names, values) pair.
function listValueName(names as Array<String>, values as Array<Number>,
                       value as Number) as String {
    var index = values.indexOf(value);
    return index >= 0 ? names[index] : names[0];
}

// The app settings menu.
class IV22LMenu extends WatchUi.Menu2 {

    (:disable_tint)
    private function addColorItem() as Void {
        Menu2.addItem(new WatchUi.MenuItem(
            "Color", "Not supported", null, null));
    }

    (:enable_tint)
    private function addColorItem() as Void {
        var color = Properties.getValue("color") as Number;
        var name = listValueName(COLOR_NAMES, COLOR_VALUES, color);
        Menu2.addItem(new WatchUi.MenuItem("Color", name, "color", null));
    }

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

        addColorItem();
        addSecondsItem();
    }
}

// Input handler for the app settings menu.
class IV22LMenuDelegate extends WatchUi.Menu2InputDelegate {

    private function pushListMenu(title as String, propertyId as String,
                                  names as Array<String>,
                                  values as Array<Number>,
                                  parentItem as MenuItem) as Void {
        WatchUi.pushView(
            new IV22LListMenu(title, propertyId, names, values),
            new IV22LListMenuDelegate(propertyId, names, values, parentItem),
            WatchUi.SLIDE_IMMEDIATE);
    }

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // Handle a menu item being selected.
    function onSelect(menuItem as MenuItem) as Void {
        var id = menuItem.getId();
        if (id == null) {
            return;
        }
        if (id.equals("color")) {
            pushListMenu("Color", "color", COLOR_NAMES, COLOR_VALUES, menuItem);
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

// A generic single-choice picker submenu, used for the color setting.
class IV22LListMenu extends WatchUi.Menu2 {

    function initialize(title as String, propertyId as String,
                        names as Array<String>, values as Array<Number>) {
        Menu2.initialize({:title => title});

        var color = Properties.getValue(propertyId) as Number;
        for (var i = 0; i < values.size(); i++) {
            var sub_label = values[i] == color ? "Current" : null;
            Menu2.addItem(new WatchUi.MenuItem(names[i], sub_label, values[i], null));
        }
    }
}

// Input handler for IV22LListMenu.
class IV22LListMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var propertyId as String;
    private var names as Array<String>;
    private var values as Array<Number>;
    // The menu item in the main settings menu, updated after a selection.
    private var parentItem as MenuItem;

    function initialize(propertyId as String, names as Array<String>,
                        values as Array<Number>, parentItem as MenuItem) {
        Menu2InputDelegate.initialize();
        self.propertyId = propertyId;
        self.names = names;
        self.values = values;
        self.parentItem = parentItem;
    }

    function onSelect(menuItem as MenuItem) as Void {
        var value = menuItem.getId() as Number;
        Properties.setValue(propertyId, value);
        parentItem.setSubLabel(listValueName(names, values, value));
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
