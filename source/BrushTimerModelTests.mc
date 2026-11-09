import Toybox.Test;

(:test)
function startsWithFullFirstZone(logger) {
    var model = new BrushTimerModel();
    model.start(1000);

    return model.getState() == BRUSH_STATE_RUNNING
        && model.getZoneNumber() == 1
        && model.getZoneRemainingSeconds() == 20
        && model.getTotalRemainingSeconds() == 120;
}

(:test)
function changesZoneAtTwentySeconds(logger) {
    var model = new BrushTimerModel();
    model.start(1000);

    var beforeBoundary = model.update(20999);
    var boundary = model.update(21000);

    return beforeBoundary == BRUSH_EVENT_NONE
        && boundary == BRUSH_EVENT_ZONE_CHANGED
        && model.getZoneNumber() == 2
        && model.getZoneRemainingSeconds() == 20;
}

(:test)
function finishesAtExactlyTwoMinutes(logger) {
    var model = new BrushTimerModel();
    model.start(5000);

    var event = model.update(125000);

    return event == BRUSH_EVENT_FINISHED
        && model.getState() == BRUSH_STATE_FINISHED
        && model.getElapsedMilliseconds() == 120000
        && model.getTotalRemainingSeconds() == 0;
}

(:test)
function pauseDoesNotConsumeTime(logger) {
    var model = new BrushTimerModel();
    model.start(1000);
    model.pause(6000);

    model.start(50000);
    model.update(55000);

    return model.getElapsedMilliseconds() == 10000
        && model.getZoneRemainingSeconds() == 10;
}

(:test)
function handlesSystemTimerRollover(logger) {
    var model = new BrushTimerModel();
    var elapsed = model.timerDelta(2147483600, -2147483500);

    return elapsed == 196;
}

