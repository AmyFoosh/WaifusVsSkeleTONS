package {

	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.desktop.SystemIdleMode;
	import flash.display.StageOrientation;

	public class DocumentClass extends Sprite {

		// ---------------------------------------

		// -- SCREEN RESOLUTION --

		public static var scaled: Number;
		public static var screenW: int;
		public static var screenH: int;

		// ---------------------------------------

		// -- GAME FPS --

		private var fps: int;

		// ---------------------------------------

		// -- SCREEN MANAGEMENT --

		private var screenController: ScreenController;

		// ---------------------------------------

		public function DocumentClass() {

			init();
		}

		private function init(): void {

			// ---------------------------------------

			configureGame();
			addListeners();

			// ---------------------------------------

			SaveManager.loadSaveContent();

			// ---------------------------------------

			screenController = new ScreenController();
			addChild(screenController);

			// ---------------------------------------
		}

		private function configureGame(): void {

			// ---------------------------------------

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// ---------------------------------------

			stage.quality = StageQuality.LOW;

			// ---------------------------------------

			scaled = (stage.stageWidth / 1280) + (stage.stageHeight / 720);
			scaled /= 2;

			// ---------------------------------------

			screenW = stage.stageWidth;
			screenH = stage.stageHeight;

			// ---------------------------------------

			fps = 60;
			stage.frameRate = fps;

			// ---------------------------------------

			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			// ---------------------------------------
		}

		private function addListeners(): void {

			// ---------------------------------------

			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, preventDefaultExit, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, inactive, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, active, false, 0, true);

			// ---------------------------------------

			addEventListener(Event.ENTER_FRAME, checkDeviceOrientation, false, 0, true);

			// ---------------------------------------
		}

		private function preventDefaultExit(event: KeyboardEvent): void {

			if (event.keyCode == Keyboard.BACK) event.preventDefault();
		}

		private function inactive(event: Event): void {

			stage.frameRate = fps;
		}

		private function active(event: Event): void {

			stage.frameRate = fps;
		}

		private function checkDeviceOrientation(event: Event): void {

			// ---------------------------------------

			// This will check if the device is rotated left or right.
			// If rotated right, we adjust the content to left and the opposite.

			switch (stage.deviceOrientation) {

				case StageOrientation.ROTATED_RIGHT:
					stage.setOrientation(StageOrientation.ROTATED_LEFT);
					break;

				case StageOrientation.ROTATED_LEFT:
					stage.setOrientation(StageOrientation.ROTATED_RIGHT);
					break;
			}

			// ---------------------------------------
		}



	}
}