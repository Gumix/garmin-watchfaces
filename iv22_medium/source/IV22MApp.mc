import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Storage;

class IV22MApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new IV22MView() ] as Array<Views or InputDelegates>;
    }

    // Return the settings view and delegate
    function getSettingsView() {
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
