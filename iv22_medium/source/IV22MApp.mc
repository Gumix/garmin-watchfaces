import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Storage;

class IV22MApp extends Application.AppBase {

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
        return [new IV22MView()];
    }

    // Return the settings view and delegate
    public function getSettingsView() {
        return [new IV22MMenu(), new IV22MMenuDelegate()];
    }
}

function getApp() as IV22MApp {
    return Application.getApp() as IV22MApp;
}

function getSetting(id as String, default_value as Boolean) as Boolean {
    if (Storage.getValue(id) == null) {
        return default_value;
    }
    return Storage.getValue(id);
}
