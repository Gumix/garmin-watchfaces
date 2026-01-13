import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Application.Properties;

class IV22LApp extends Application.AppBase {

    // Constructor.
    public function initialize() {
        AppBase.initialize();
    }

    // Called on application startup.
    public function onStart(state as Dictionary?) as Void {
    }

    // Called on application shutdown.
    public function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of the application.
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new IV22LView()];
    }

    // Return the settings view and delegate.
    public function getSettingsView() {
        return [new IV22LMenu(), new IV22LMenuDelegate()];
    }

    // Called when the settings have been changed by Garmin Connect Mobile.
    public function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}

function getApp() as IV22LApp {
    return Application.getApp() as IV22LApp;
}
