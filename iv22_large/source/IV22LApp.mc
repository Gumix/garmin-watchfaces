import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Storage;

class IV22LApp extends Application.AppBase {

    // Constructor
    public function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application startup
    public function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called on application shutdown
    public function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of the application
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new IV22LView()];
    }

    // Return the settings view and delegate
    public function getSettingsView() {
        return [new IV22LMenu(), new IV22LMenuDelegate()];
    }
}

function getApp() as IV22LApp {
    return Application.getApp() as IV22LApp;
}

function getSetting(id as String, default_value as Boolean) as Boolean {
    if (Storage.getValue(id) == null) {
        return default_value;
    }
    return Storage.getValue(id);
}
