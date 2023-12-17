import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

// The app settings menu
class IV22MMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "IV-22 Medium"});

        var item_id = "seconds_on";
        var is_enabled = getSetting(item_id, true);
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show seconds", null,
                                                 item_id, is_enabled, null));
        item_id = "seconds_as_dot";
        is_enabled = getSetting(item_id, true);
        Menu2.addItem(new WatchUi.ToggleMenuItem("Single dot vs.",
                                                 "progress bar",
                                                 item_id, is_enabled, null));
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
            Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
