import Toybox.Application;

class BrushTimerApp extends Application.AppBase {
    function initialize() {
        Application.AppBase.initialize();
    }

    function getInitialView() {
        var view = new BrushTimerView();
        return [view, new BrushTimerDelegate(view)];
    }
}

