import Toybox.WatchUi;

class BrushTimerDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        WatchUi.BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        _view.toggleTimer();
        return true;
    }

    function onBack() {
        // First BACK press cancels an active session. When already idle or
        // finished, return false so the watch handles its normal app exit.
        return _view.resetIfActive();
    }
}

