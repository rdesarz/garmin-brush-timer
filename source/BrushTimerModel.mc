const BRUSH_STATE_IDLE = 0;
const BRUSH_STATE_RUNNING = 1;
const BRUSH_STATE_PAUSED = 2;
const BRUSH_STATE_FINISHED = 3;

const BRUSH_EVENT_NONE = 0;
const BRUSH_EVENT_ZONE_CHANGED = 1;
const BRUSH_EVENT_FINISHED = 2;

const BRUSH_ZONE_COUNT = 6;
const BRUSH_ZONE_DURATION_MS = 20000;
const BRUSH_TOTAL_DURATION_MS = BRUSH_ZONE_COUNT * BRUSH_ZONE_DURATION_MS;

// Pure timer state. It accepts the current System.getTimer() value so the
// behavior can be tested without waiting for real time to pass.
class BrushTimerModel {
    private var _state;
    private var _elapsedMs;
    private var _lastStartedAtMs;

    function initialize() {
        reset();
    }

    function start(nowMs) {
        if (_state == BRUSH_STATE_RUNNING) {
            return;
        }

        if (_state == BRUSH_STATE_IDLE || _state == BRUSH_STATE_FINISHED) {
            _elapsedMs = 0;
        }

        _lastStartedAtMs = nowMs;
        _state = BRUSH_STATE_RUNNING;
    }

    function pause(nowMs) {
        if (_state != BRUSH_STATE_RUNNING) {
            return BRUSH_EVENT_NONE;
        }

        var event = update(nowMs);
        if (_state == BRUSH_STATE_RUNNING) {
            _state = BRUSH_STATE_PAUSED;
        }
        return event;
    }

    function reset() {
        _state = BRUSH_STATE_IDLE;
        _elapsedMs = 0;
        _lastStartedAtMs = 0;
    }

    function update(nowMs) {
        if (_state != BRUSH_STATE_RUNNING) {
            return BRUSH_EVENT_NONE;
        }

        var previousZone = getZoneNumber();
        _elapsedMs += timerDelta(_lastStartedAtMs, nowMs);
        _lastStartedAtMs = nowMs;

        if (_elapsedMs >= BRUSH_TOTAL_DURATION_MS) {
            _elapsedMs = BRUSH_TOTAL_DURATION_MS;
            _state = BRUSH_STATE_FINISHED;
            return BRUSH_EVENT_FINISHED;
        }

        if (getZoneNumber() != previousZone) {
            return BRUSH_EVENT_ZONE_CHANGED;
        }

        return BRUSH_EVENT_NONE;
    }

    function getState() {
        return _state;
    }

    function isRunning() {
        return _state == BRUSH_STATE_RUNNING;
    }

    function isActive() {
        return _state == BRUSH_STATE_RUNNING || _state == BRUSH_STATE_PAUSED;
    }

    function getElapsedMilliseconds() {
        return _elapsedMs;
    }

    function getZoneNumber() {
        if (_state == BRUSH_STATE_FINISHED) {
            return BRUSH_ZONE_COUNT;
        }
        return (_elapsedMs / BRUSH_ZONE_DURATION_MS) + 1;
    }

    function getCompletedZoneCount() {
        return _elapsedMs / BRUSH_ZONE_DURATION_MS;
    }

    function getZoneRemainingSeconds() {
        if (_state == BRUSH_STATE_FINISHED) {
            return 0;
        }

        var remainingMs = BRUSH_ZONE_DURATION_MS - (_elapsedMs % BRUSH_ZONE_DURATION_MS);
        return (remainingMs + 999) / 1000;
    }

    function getTotalRemainingSeconds() {
        var remainingMs = BRUSH_TOTAL_DURATION_MS - _elapsedMs;
        return (remainingMs + 999) / 1000;
    }

    // System.getTimer() is a signed 32-bit counter. This keeps a brushing
    // session correct even if that counter rolls over during its two minutes.
    function timerDelta(startMs, endMs) {
        if (endMs >= startMs) {
            return endMs - startMs;
        }

        var maxTimer = 0x7fffffff;
        var minTimer = -2147483647 - 1;
        return (maxTimer - startMs) + (endMs - minTimer) + 1;
    }
}

