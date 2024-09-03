import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class IV22SApp extends Application.AppBase {

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
        return [new IV22SView()];
    }

}

function getApp() as IV22SApp {
    return Application.getApp() as IV22SApp;
}
