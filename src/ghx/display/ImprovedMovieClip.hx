package ghx.display;

import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.media.Sound;
import openfl.media.SoundTransform;

import starling.animation.IAnimatable;
import starling.events.Event;
import starling.textures.Texture;

@:meta(Event(name="complete", type="starling.events.Event"))

class ImprovedMovieClip extends Image implements IAnimatable {
    private var __frames:Array<MovieClipFrame>;
    private var __defaultFrameDuration:Float;
    private var __currentTime:Float;
    private var __currentFrameID:Int;
    private var __loop:Bool;
    private var __playing:Bool;
    private var __muted:Bool;
    private var __wasStopped:Bool;
    private var __soundTransform:SoundTransform;
    private var __framePool:Array<MovieClipFrame>;

    public function new(textures:Array<Texture>, fps:Float = 12) {
        if (textures.length > 0) {
            super(textures[0]);
            init(textures, fps);
        } else {
            throw new ArgumentError("Empty texture array");
        }
    }

    private function init(textures:Array<Texture>, fps:Float):Void {
        if (fps <= 0) throw new ArgumentError("Invalid fps: " + fps);

        var numFrames:Int = textures.length;
        __defaultFrameDuration = 1.0 / fps;
        __loop = true;
        __playing = true;
        __currentTime = 0.0;
        __currentFrameID = 0;
        __wasStopped = true;
        __frames = new Array<MovieClipFrame>();
        __framePool = [];

        for (i in 0...numFrames) {
            __frames[i] = createFrame(textures[i], __defaultFrameDuration, __defaultFrameDuration * i);
        }
    }

    private function createFrame(texture:Texture, duration:Float, startTime:Float = 0):MovieClipFrame {
        if (__framePool.length > 0) {
            var frame:MovieClipFrame = __framePool.pop();
            frame.texture = texture;
            frame.duration = duration;
            frame.startTime = startTime;
            return frame;
        } else {
            return new MovieClipFrame(texture, duration, startTime);
        }
    }

    private function recycleFrame(frame:MovieClipFrame):Void {
        __framePool.push(frame);
    }

    public function addFrame(texture:Texture, sound:Sound = null, duration:Float = -1):Void {
        addFrameAt(numFrames, texture, sound, duration);
    }

    public function addFrameAt(frameID:Int, texture:Texture, sound:Sound = null, duration:Float = -1):Void {
        if (frameID < 0 || frameID > numFrames) throw new ArgumentError("Invalid frame id");
        if (duration < 0) duration = __defaultFrameDuration;

        var frame:MovieClipFrame = createFrame(texture, duration);
        frame.sound = sound;
        __frames.insert(frameID, frame);

        if (frameID == numFrames) {
            var prevStartTime:Float = frameID > 0 ? __frames[frameID - 1].startTime : 0.0;
            var prevDuration:Float = frameID > 0 ? __frames[frameID - 1].duration : 0.0;
            frame.startTime = prevStartTime + prevDuration;
        } else {
            updateStartTimes();
        }
    }

    public function removeFrameAt(frameID:Int):Void {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        if (numFrames == 1) throw new IllegalOperationError("Movie clip must not be empty");

        var removedFrame:MovieClipFrame = __frames.splice(frameID, 1)[0];
        recycleFrame(removedFrame);

        if (frameID != numFrames) updateStartTimes();
    }

    private function updateStartTimes():Void {
        var numFrames:Int = this.numFrames;
        var prevFrame:MovieClipFrame =__frames[0];
        prevFrame.startTime = 0;

        for (i in 1...numFrames) {
            __frames[i].startTime = prevFrame.startTime + prevFrame.duration;
            prevFrame = __frames[i];
        }
    }

    public function setFrameRange(startFrameID:Int, endFrameID:Int, textures:Array<Texture>, fps:Float):Void {
        if (startFrameID < 0 || endFrameID >= numFrames || startFrameID > endFrameID) {
            throw new ArgumentError("Invalid frame range");
        }

        var duration:Float = 1.0 / fps;
        for (i in startFrameID...endFrameID + 1) {
            if (i < textures.length) {
                __frames[i].texture = textures[i - startFrameID];
                __frames[i].duration = duration;
            }
        }
        updateStartTimes();
    }

    public function play():Void {
        __playing = true;
    }

    public function pause():Void {
        __playing = false;
    }

    public function stop():Void {
        __playing = false;
        __wasStopped = true;
        currentFrame = 0;
    }

    public function advanceTime(passedTime:Float):Void {
        if (!__playing) return;

        var frame:MovieClipFrame = __frames[__currentFrameID];

        if (__wasStopped) {
            __wasStopped = false;
            frame.playSound(__soundTransform);

            if (frame.action != null) {
                frame.executeAction(this, __currentFrameID);
                advanceTime(passedTime);
                return;
            }
        }

        if (currentTime == totalTime) {
            if (loop) {
                currentTime = 0.0;
                __currentFrameID = 0;
                frame = __frames[0];
                frame.playSound(__soundTransform);
                texture = frame.texture;

                if (frame.action != null) {
                    frame.executeAction(this, __currentFrameID);
                    advanceTime(passedTime);
                    return;
                }
            } else return;
        }

        var finalFrameID:Int = __frames.length - 1;
        var dispatchCompleteEvent:Bool = false;
        var frameAction:Function = null;
        var previousFrameID:Int = __currentFrameID;
        var restTimeInFrame:Float = 0;
        var changedFrame:Bool;

        while (currentTime + passedTime >= frame.endTime) {
            changedFrame = false;
            restTimeInFrame = frame.duration - currentTime + frame.startTime;
            passedTime -= restTimeInFrame;
            __currentTime = frame.startTime + frame.duration;

            if (__currentFrameID == finalFrameID) {
                if (hasEventListener("complete")) {
                    dispatchCompleteEvent = true;
                } else if (loop) {
                    __currentTime = 0;
                    __currentFrameID = 0;
                    changedFrame = true;
                } else return;
            } else {
                __currentFrameID += 1;
                changedFrame = true;
            }

            frame = __frames[__currentFrameID];
            frameAction = frame.action;

            if (changedFrame) frame.playSound(soundTransform);

            if (dispatchCompleteEvent) {
                texture = frame.texture;
                dispatchEventWith("complete");
                advanceTime(passedTime);
                return;
            } else if (frameAction != null) {
                texture = frame.texture;
                frame.executeAction(this, __currentFrameID);
                advanceTime(passedTime);
                return;
            }
        }

        if (previousFrameID != __currentFrameID) texture = __frames[__currentFrameID].texture;

        currentTime += passedTime;
    }

    public var numFrames(get, never):Int;
    private function get_numFrames():Int { return __frames.length; }

    public var totalTime(get, never):Float;
    private function get_totalTime():Float {
        var lastFrame:MovieClipFrame = __frames[__frames.length - 1];
        return lastFrame.startTime + lastFrame.duration;
    }

    public var currentTime(get, set):Float;
    private function get_currentTime():Float { return __currentTime; }
    private function set_currentTime(value:Float):Float {
        if (value < 0 || value > totalTime) throw new ArgumentError("Invalid time: " + value);

        var lastFrameID:Int = __frames.length - 1;
        __currentTime = value;
        __currentFrameID = 0;

        while (__currentFrameID < lastFrameID && __frames[__currentFrameID + 1].startTime <= value) ++__currentFrameID;

        var frame:MovieClipFrame = __frames[__currentFrameID];
        texture = frame.texture;
        return value;
    }

    public var loop(get, set):Bool;
    private function get_loop():Bool { return __loop; }
    private function set_loop(value:Bool):Bool { return __loop = value; }

    public var muted(get, set):Bool;
    private function get_muted():Bool { return __muted; }
    private function set_muted(value:Bool):Bool { return __muted = value; }

    public var soundTransform(get, set):SoundTransform;
    private function get_soundTransform():SoundTransform { return __soundTransform; }
    private function set_soundTransform(value:SoundTransform):SoundTransform { return __soundTransform = value; }

    public var currentFrame(get, set):Int;
    private function get_currentFrame():Int { return __currentFrameID; }
    private function set_currentFrame(value:Int):Int {
        if (value < 0 || value >= numFrames) throw new ArgumentError("Invalid frame id");
        currentTime = __frames[value].startTime;
        return value;
    }

    public var fps(get, set):Float;
    private function get_fps():Float { return 1.0 / __defaultFrameDuration; }
    private function set_fps(value:Float):Float {
        if (value <= 0) throw new ArgumentError("Invalid fps: " + value);

        var newFrameDuration:Float = 1.0 / value;
        var acceleration:Float = newFrameDuration / __defaultFrameDuration;
        currentTime *= acceleration;
        __defaultFrameDuration = newFrameDuration;

        for (i in 0...numFrames) __frames[i].duration *= acceleration;

        updateStartTimes();
        return value;
    }

    public var isPlaying(get, never):Bool;
    private function get_isPlaying():Bool {
        if (__playing) return loop || currentTime < totalTime;
        else return false;
    }

    public var isComplete(get, never):Bool;
    private function get_isComplete():Bool {
        return !loop && currentTime >= totalTime;
    }
}

private class MovieClipFrame {
    public function new(texture:Texture, duration:Float = 0.1, startTime:Float = 0) {
        this.texture = texture;
        this.duration = duration;
        this.startTime = startTime;
    }

    public var texture:Texture;
    public var sound:Sound;
    public var duration:Float;
    public var startTime:Float;
    public var action:Function;

    public function playSound(transform:SoundTransform):Void {
        if (sound != null) sound.play(0, 0, transform);
    }

    public function executeAction(movie:ImprovedMovieClip, frameID:Int):Void {
        if (action != null) {
            #if flash
            var numArgs:Int = untyped action.length;
            #elseif neko
            var numArgs:Int = untyped ($nargs)(action);
            #elseif cpp
            var numArgs:Int = untyped action.__ArgCount();
            #else
            var numArgs:Int = 2;
            #end

            if (numArgs == 0) action();
            else if (numArgs == 1) action(movie);
            else if (numArgs == 2) action(movie, frameID);
            else throw new Error("Frame actions support zero, one or two parameters: " +
                    "movie:ImprovedMovieClip, frameID:int");
        }
    }

    public var endTime(get, never):Float;
    private function get_endTime():Float { return startTime + duration; }
}
