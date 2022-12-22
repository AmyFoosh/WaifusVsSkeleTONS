package {

	import playerio.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.events.TouchEvent;
	import com.protobuf.Message;

	public class PlayScreen extends ScreenSuperclass {

		// ---------------------------------------

		// -- MULTIPLAYER VARIABLES --

		private var client: Client;
		private var connection: Connection;

		// ---------------------------------------
		
		// -- LOCAL VARIABLES --
		
		private var myID: int;
		private var playersID: Array;
		private var playersSprites: Array;
		
		private var vCamTarget: int;
		private var vCamMovement: String;
		
		private var entitiesScale: Number;
		
		// ---------------------------------------
		
		// -- DISPLAY CONTENT --
		
		private var bg: AssetSuperclass;
		private var joystick: Joystick;
		private var dashBtn: AssetSuperclass;
		
		private var playerShadow: AssetSuperclass;
		
		// ---------------------------------------

		public function PlayScreen(scaled: Number, screenW: int, screenH: int) {

			super(scaled, screenW, screenH);
			
			multiplayerController();
		}

		private function init(): void {

			initialiseMultiplayerVariables();
			addMultiplayerContent();
			adjustMultiplayerContent();
			// addMultiplayerListeners();
		}
		
		// ---------------------------------------
		
		// -- MULTIPLAYER SETTINGS --
		
		private function multiplayerController(): void {
			
			serverConnection();
		}
		
		private function serverConnection(): void {
			
			// ---------------------------------------
			
			// -- CONNECTING TO SERVER --
			
			PlayerIO.authenticate(
				stage,
				"waifus-vs-skeletons-jend55muwgw0vt2jhdia",
				"public",
				{userId:""},
				null, 
				serverConnectionSuccess,
				serverConnectionError
			);
				
			// ---------------------------------------
		}
		
		private function serverConnectionSuccess(client: Client): void {
			
			// ---------------------------------------
			
			trace("Server connection success.");
			
			this.client = client;
			
			// ---------------------------------------
			
			// -- JOIN A ROOM --
			
			client.multiplayer.createJoinRoom(
				"Room 1",
				"Multiplayer",
				true,
				{},
				{},
				joinRoomSuccess,
				joinRoomError
			);
				
			// ---------------------------------------
		}
		
		private function serverConnectionError(error: PlayerIOError): void {
			
			// ---------------------------------------
			
			trace("Server connection error.");
			
			// ---------------------------------------
		}
		
		private function joinRoomSuccess(connection:Connection): void {
			
			// ---------------------------------------
			
			trace("Join room success.");
			
			this.connection = connection;
			
			// ---------------------------------------
			
			init();
			
			// ---------------------------------------
			
			// -- MESSAGES HANDLER --
			
			connection.addMessageHandler("gameLoop", receiveGameLoop);
			connection.addMessageHandler("myID", receiveMyID);
			connection.addMessageHandler("connected", receiveConnected);
			connection.addMessageHandler("disconnected", receiveDisconnected);
			connection.addMessageHandler("move", receiveMove);
			connection.addMessageHandler("dash", receiveDash);
			
			// ---------------------------------------
			
			connection.send("connected");
			
			// ---------------------------------------
		}
		
		private function joinRoomError(error: PlayerIOError): void {
			
			// ---------------------------------------
			
			trace("Join room error.");
			
			// ---------------------------------------
		}
		
		// ---------------------------------------
		
		// -- MULTIPLAYER MESSAGES HANDLER --
		
		private function receiveGameLoop(m: Message): void {
			
			// trace("Game loop.");
		}
		
		private function receiveMyID(m: Message): void {
			
			// ---------------------------------------
			
			myID = m.getInt(0);
			
			trace("My ID: " + myID);
			
			for (var i: int = 0; i < playersID.length; i++) {
				
				if (myID == playersID[i]) {
					
					// -- ADD VCAM INITIAL POSITION --
					
					vCamTarget = i;
					
					this.scrollRect = new Rectangle(playersSprites[i].x - screenW / 2, playersSprites[i].y - screenH / 2, screenW, screenH);
				
					break;
				}
			}
			
			// ---------------------------------------
			
			trace("VCam moved to player location.");
			trace("VCam target: " + vCamTarget);
			
			// ---------------------------------------
			
			// -- PLAYER SHADOW --
			
			/*playerShadow = new AssetSuperclass(scaled * entitiesScale, new Player2);
			addChild(playerShadow);
			
			playerShadow.x = playersSprites[vCamTarget].x;
			playerShadow.y = playersSprites[vCamTarget].y;*/
			
			this.setChildIndex(playersSprites[vCamTarget], this.numChildren - 1);
			
			// ---------------------------------------
			
			addMultiplayerListeners();
			
			// ---------------------------------------
		}
		
		private function receiveConnected(m: Message): void {
			
			// ---------------------------------------
			
			trace("Player connected.");
			
			// ---------------------------------------
			
			var playerID: int = m.getInt(0);
			playersID.push(playerID);
			
			trace("Player ID: " + playerID);
			
			// ---------------------------------------
			
			var player: AssetSuperclass = new AssetSuperclass(scaled * entitiesScale, new Player1);
			addChild(player);
			
			player.x = m.getNumber(1) * scaled;
			player.y = m.getNumber(2) * scaled;
			
			playersSprites.push(player);
			
			trace("Player X: " + player.x);
			trace("Player Y: " + player.y);
			
			// ---------------------------------------
			
			trace("ID's " +  playersID);
			trace("Players: " + playersSprites);
			
			// ---------------------------------------
		}
		
		private function receiveDisconnected(m: Message): void {
			
			// ---------------------------------------
			
			trace("Player disconnected.");
			
			// ---------------------------------------
			
			var i: int = playersID.length - 1;
			
			while (i > - 1) {
				
				if (playersID[i] == m.getInt(0)) {
					
					playersID.splice(i, 1);
					
					removeChild(playersSprites[i]);
					playersSprites.splice(i, 1);
				}
				
				i--;
			}
			
			// ---------------------------------------
			
			trace("ID's " +  playersID);
			trace("Players: " + playersSprites);
			
			// ---------------------------------------
		}
		
		private function receiveMove(m: Message): void {
			
			// ---------------------------------------
			
			var currentID: int = m.getNumber(0);
			var angle: Number = m.getNumber(1);
			
			// ---------------------------------------
			
			if (myID != currentID) {
				
				for (var i: int = 0; i < playersID.length; i++) {
					
					if (currentID == playersID[i]) {
						
						playersSprites[i].x -= Math.cos(angle) * 4 * scaled;
						playersSprites[i].y -= Math.sin(angle) * 4 * scaled;
						
						// trace("Another player moving.");
					}
				}
				
			} else {
				
				playersSprites[i].x -= Math.cos(angle) * 4 * scaled;
				playersSprites[i].y -= Math.sin(angle) * 4 * scaled;
				
				// playerShadow.x -= Math.cos(angle) * 4 * scaled;
				// playerShadow.y -= Math.sin(angle) * 4 * scaled;
				
				// trace("Shadow movement.");
			}
			
			// ---------------------------------------
		}
		
		private function receiveDash(m: Message): void {
			
			trace("Dash.");
			
			var currentID: int = m.getInt(0);
			var angle: Number = m.getNumber(1);
			var amount: Number = m.getInt(2);
			
			trace("-----------------------");
			trace("Dash: ");
			trace("ID:" + currentID);
			trace("Angle: " + angle);
			trace("Amount: " + amount);
			trace("-----------------------");
			
			for (var i: int = 0; i < playersID.length; i++) {
				
				if (currentID == playersID[i]) {
					
					playersSprites[i].x -= Math.cos(angle) * amount * scaled;
					playersSprites[i].y -= Math.sin(angle) * amount * scaled;
				}
				
				/*if (myID == currentID) {
				
					playerShadow.x = playersSprites[i].x;
					playerShadow.y = playersSprites[i].y;
				}*/
			}
		}
		
		// ---------------------------------------
		
		// -- INITIAL SETTINGS --

		public function initialiseMultiplayerVariables(): void {

			playersID = new Array();
			playersSprites = new Array();
			
			vCamMovement = "Delay"; // Delay or Direct
			
			entitiesScale = 0.75;
		}

		public function addMultiplayerContent(): void {

			bg = new AssetSuperclass(scaled, new BG);
			addChild(bg);
			
			joystick = new Joystick(scaled, screenW, screenH, new JoystickBG, new JoystickAnalog, new JoystickArea);
			addChild(joystick);
			
			dashBtn = new AssetSuperclass(scaled, new DashBtn);
			addChild(dashBtn);
		}

		public function adjustMultiplayerContent(): void {

			joystick.setStartPos(0 + joystick.joystickBG.width / 2, screenH - joystick.joystickBG.height / 2);
			
			dashBtn.x = screenW - dashBtn.width;
			dashBtn.y = screenH - dashBtn.height;
		}

		public function addMultiplayerListeners(): void {

			addEventListener(Event.ENTER_FRAME, gameLoop, false, 0, true);
			
			dashBtn.addEventListener(TouchEvent.TOUCH_TAP, dashClicked, false, 0, true);
		}

		public function removeMultiplayerListeners(): void {

		}

		private function dashClicked(event: TouchEvent): void {
			
			if (isNaN(joystick.getAngle)) return;
			
			trace("Player try to dash.");
			
			connection.send("dash", joystick.getAngle);
		}
		
		// ---------------------------------------

		// -- GAME LOOP --

		private function gameLoop(event: Event): void {

			playerController();
			drawOrder();
			vCam();
		}
		
		private function playerController(): void {
			
			// ---------------------------------------
			
			joystick.tick();
			
			// ---------------------------------------
			
			if (joystick.getJoystickIsClicked) {
				
				for (var i: int = 0; i < playersID.length; i++) {
					
					if (myID == playersID[i]) {
						
						// playersSprites[i].x -= Math.cos(joystick.getAngle) * 4 * scaled;
						// playersSprites[i].y -= Math.sin(joystick.getAngle) * 4 * scaled;
						
						connection.send("move", joystick.getAngle);
						
						break;
					}
				}
			}
			
			// ---------------------------------------
		}

		// ---------------------------------------

		// -- DRAW ORDER --
		
		private function drawOrder(): void {
			
			// ---------------------------------------
			
			this.setChildIndex(joystick, this.numChildren - 1);
			this.setChildIndex(dashBtn, this.numChildren - 1);
			
			// ---------------------------------------
		}
		
		// ---------------------------------------
		
		// -- VIRTUAL CAMERA --
		
		private function vCam(): void {
			
			// ---------------------------------------
			
			var rect: Rectangle = this.scrollRect;
			
			// ---------------------------------------
			
			if (vCamMovement == "Delay") {
				
				rect.x += (playersSprites[vCamTarget].x - screenW / 2 - rect.x) / 30;
				rect.y += (playersSprites[vCamTarget].y - screenH / 2 - rect.y) / 30;
			}
			
			if (vCamMovement == "Direct") {
				
				rect.x = playersSprites[vCamTarget].x - screenW / 2;
				rect.y = playersSprites[vCamTarget].y - screenH / 2;
			}
			
			// ---------------------------------------
			
			this.scrollRect = rect;
			
			// ---------------------------------------
			
			// Move all UI content to target position.
			
			if (vCamMovement == "Delay") {
				
				joystick.x = rect.x;
				joystick.y = rect.y;
				
				dashBtn.x = rect.x + screenW - dashBtn.width / 1.5;
				dashBtn.y = rect.y + screenH - dashBtn.height / 1.5;
			}
			
			if (vCamMovement == "Direct") {
				
				joystick.x = playersSprites[vCamTarget].x - screenW / 2;
				joystick.y = playersSprites[vCamTarget].y - screenH / 2;
				
				dashBtn.x = playersSprites[vCamTarget].x + screenW / 2 - dashBtn.width / 1.5;
				dashBtn.y = playersSprites[vCamTarget].y + screenH / 2 - dashBtn.height / 1.5;
			}
			
			// ---------------------------------------
		}
		
		// ---------------------------------------



	}
}