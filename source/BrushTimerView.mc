import Toybox.Attention;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class BrushTimerView extends WatchUi.View {
    private var _model;
    private var _timer;
    private var _timerRunning;
    private var _lastDisplayedSecond;

    function initialize() {
        WatchUi.View.initialize();
        _model = new BrushTimerModel();
        _timer = new Timer.Timer();
        _timerRunning = false;
        _lastDisplayedSecond = null;
    }

    function onShow() {
        if (_model.isRunning()) {
            handleTimerEvent(_model.update(System.getTimer()));
            startTimer();
        }
    }

    function onHide() {
        stopTimer();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var state = _model.getState();
        var heading;
        var hint;

        if (state == BRUSH_STATE_IDLE) {
            heading = "READY";
            hint = "PRESS START";
        } else if (state == BRUSH_STATE_PAUSED) {
            heading = "PAUSED";
            hint = "START TO RESUME";
        } else if (state == BRUSH_STATE_FINISHED) {
            heading = "DONE";
            hint = "START AGAIN";
        } else {
            heading = "ZONE " + _model.getZoneNumber() + " / " + BRUSH_ZONE_COUNT;
            hint = "TOTAL " + formatTime(_model.getTotalRemainingSeconds());
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 31, Graphics.FONT_MEDIUM, heading, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            68,
            Graphics.FONT_NUMBER_HOT,
            _model.getZoneRemainingSeconds().toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 139, Graphics.FONT_SMALL, "SECONDS", Graphics.TEXT_JUSTIFY_CENTER);

        drawZoneIndicators(dc, centerX, 184);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 210, Graphics.FONT_TINY, hint, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function toggleTimer() {
        var nowMs = System.getTimer();

        if (_model.isRunning()) {
            handleTimerEvent(_model.pause(nowMs));
            stopTimer();
        } else {
            _model.start(nowMs);
            startTimer();
        }

        _lastDisplayedSecond = null;
        WatchUi.requestUpdate();
    }

    function resetIfActive() {
        if (!_model.isActive()) {
            return false;
        }

        stopTimer();
        _model.reset();
        _lastDisplayedSecond = null;
        WatchUi.requestUpdate();
        return true;
    }

    function onTimerTick() {
        var event = _model.update(System.getTimer());
        handleTimerEvent(event);

        if (!_model.isRunning()) {
            stopTimer();
        }

        var displayedSecond = _model.getZoneRemainingSeconds();
        if (event != BRUSH_EVENT_NONE || displayedSecond != _lastDisplayedSecond) {
            _lastDisplayedSecond = displayedSecond;
            WatchUi.requestUpdate();
        }
    }

    private function startTimer() {
        if (_timerRunning) {
            return;
        }
        _timer.start(method(:onTimerTick), 200, true);
        _timerRunning = true;
    }

    private function stopTimer() {
        if (!_timerRunning) {
            return;
        }
        _timer.stop();
        _timerRunning = false;
    }

    private function handleTimerEvent(event) {
        if (event == BRUSH_EVENT_ZONE_CHANGED) {
            vibrateZoneChange();
        } else if (event == BRUSH_EVENT_FINISHED) {
            vibrateFinished();
        }
    }

    private function vibrateZoneChange() {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(85, 220)
            ]);
        }
    }

    private function vibrateFinished() {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(100, 180),
                new Attention.VibeProfile(0, 120),
                new Attention.VibeProfile(100, 360)
            ]);
        }
    }

    private function drawZoneIndicators(dc, centerX, y) {
        var firstX = centerX - 63;
        var completedZones = _model.getCompletedZoneCount();
        var currentZoneIndex = _model.getZoneNumber() - 1;

        for (var index = 0; index < BRUSH_ZONE_COUNT; index += 1) {
            var x = firstX + (index * 25);
            if (index < completedZones) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 6);
            } else if (_model.getState() != BRUSH_STATE_FINISHED && index == currentZoneIndex) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 7);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, 6);
            }
        }
    }

    private function formatTime(totalSeconds) {
        var minutes = totalSeconds / 60;
        var seconds = totalSeconds % 60;
        var result = minutes + ":";
        if (seconds < 10) {
            result += "0";
        }
        return result + seconds;
    }
}

