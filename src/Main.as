package {

import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.media.Camera;
import flash.media.Video;
import flash.net.FileReference;
import flash.text.TextField;
import flash.utils.ByteArray;

import mx.utils.Base64Encoder;

import top.yunp.showcamera.Config;

[SWF(width=550, height=400)]
public class Main extends Sprite {

    private var video:Video;
    private var camera:Camera;
    private var logText:TextField;

    public function Main() {

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        addVideo();
        addLogText();
        showCamera();
        addJsCallbacks();
    }

    private function addJsCallbacks():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("capture", jsCaptureHandler);
        } else {
            log("ExternalInterface is not available");
        }
    }


    private function captureAndGetJpegData():ByteArray {
        var bd:BitmapData = new BitmapData(Config.SCREEN_WIDTH, Config.SCREEN_HEIGHT);
        bd.draw(video);


        return bd.encode(new Rectangle(0, 0, Config.SCREEN_WIDTH, Config.SCREEN_HEIGHT), new JPEGEncoderOptions());
    }

    private function jsCaptureHandler():String {
        var bytes:ByteArray = captureAndGetJpegData();

        var base64Encode:Base64Encoder = new Base64Encoder();
        base64Encode.encodeBytes(bytes);

        return base64Encode.drain();
    }

    private function addLogText():void {
        logText = new TextField();
        logText.width = Config.SCREEN_WIDTH;
        logText.height = Config.SCREEN_HEIGHT;
        logText.selectable = false;
        addChild(logText);

        logText.doubleClickEnabled = true;
        logText.addEventListener(MouseEvent.DOUBLE_CLICK, stage_doubleClickHandler);
    }

    private function addVideo():void {
        video = new Video(Config.SCREEN_WIDTH, Config.SCREEN_HEIGHT);
        addChild(video);
    }

    private function showCamera():void {
        if (Camera.isSupported) {
            var names:Array = Camera.names;
            if (names && names.length) {
                log("We select the first camera " + names[0]);
                var camera:Camera = Camera.getCamera("0");
                camera.setMode(Config.SCREEN_WIDTH, Config.SCREEN_HEIGHT, 30);

                video.attachCamera(camera);
            } else {
                log("There is no camera");
            }
        } else {
            log("Your device dose not support Camera");
        }
    }

    private function log(s:String):void {
        logText.text += s + "\n";
        logText.scrollV = logText.maxScrollV;
    }

    private function stage_doubleClickHandler(event:MouseEvent):void {
        var bytes:ByteArray = captureAndGetJpegData();

        try {
            var fr:FileReference = new FileReference();
            fr.save(bytes, "image.jpg");
        } catch (e:Error) {
            log("Can not save image " + e);
        }
    }
}
}
