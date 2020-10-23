package;

import haxe.io.Bytes;
import kha.SystemImpl;
import kha.math.Vector2;
import editor.Button;
import editor.SignActorBarEntry;
import kha.math.Vector2i;
import kha.input.Mouse;
import editor.ActorBar;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;
import kha.Window;
import simulation.actor.*;
import simulation.actor.character.*;
import simulation.Scene;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var camera:Camera;
	var input:Input;
	var scene:Scene;
	var ticks = 0;
	var maxTicks = -1;
	var paused = true;
	var actorBar:ActorBar;

	var viewButton:Button;
	var editButton:Button;
	var goButton:Button;

	var worldstatePreSimulation:Bytes;

	var ws:WebSocket;
	var worldID = "";

	var lastNetState:Bytes;
	var editedLevelNetState = false;

	public function new() {
		#if sys
		maxTicks = Std.parseInt(Sys.args()[1]);
		#end

		#if (js)
			untyped {
				worldID = window.location.href.split("/")[window.location.href.split("/").length-1];
			}
		#end

		scene = new Scene();
		actorBar = new ActorBar();

		camera = new Camera();
		input = new Input(camera);

		var y = ActorBar.height;
		viewButton = new Button(Assets.images.viewButton, new Vector2(10, y + 10), function() {
			var url = worldID;

			#if (js)
				untyped {
					url = window.location.href.split("/")[0] + "/" + worldID.substr(0,5);
				}
			#end

			SystemImpl.copyToClipboard(url);
		});
		y += Assets.images.viewButton.height + 10;

		editButton = new Button(Assets.images.editButton, new Vector2(10, y + 10), function() {
			var url = worldID;

			#if (js)
				untyped {
					url = window.location.href.split("/")[0] + "/" + worldID;
				}
			#end

			SystemImpl.copyToClipboard(url);
		});
		
		y += Assets.images.viewButton.height + 10;

		goButton = new Button(Assets.images.goButton, new Vector2(10, y + 10), function() {
			startSimulation();
		});

		input.onMouseMove = function(dx,dy) {
			if (input.middleMouseButtonDown) {
				camera.position.x -= dx;
				camera.position.y -= dy;
			}
			if (input.leftMouseButtonDown && input.getMouseScreenPosition().y > ActorBar.height && paused) {
				var worldPosition = input.getMouseWorldPosition();
				var gridPosition = new Vector2i(Math.floor(worldPosition.x/Scene.TILESIZE), Math.floor(worldPosition.y/Scene.TILESIZE));

				for (actor in scene.getActorsAtPosition(gridPosition))
					scene.actors.remove(actor);
				
				scene.actors.push(switch actorBar.activeOption.actorType {
					case Gatherer: new Gatherer(gridPosition);
					case Thief: new Thief(gridPosition);
					case Fence: new Fence(gridPosition);
					case GoldenTree: new GoldenTree(gridPosition);
					case Hoard: new Hoard(gridPosition);
					case MitosisPool: new MitosisPool(gridPosition);
					case Pad: new Pad(gridPosition);
					case Sign: new Sign(gridPosition, cast(actorBar.activeOption, SignActorBarEntry).direction);
					case Stockpile: new Stockpile(gridPosition);
					case Tree: new Tree(gridPosition);
				});
				editedLevelNetState = true;
			}
			if (input.rightMouseButtonDown && input.getMouseScreenPosition().y > ActorBar.height && paused) {
				var worldPosition = input.getMouseWorldPosition();
				var gridPosition = new Vector2i(Math.floor(worldPosition.x/Scene.TILESIZE), Math.floor(worldPosition.y/Scene.TILESIZE));

				for (actor in scene.getActorsAtPosition(gridPosition))
					scene.actors.remove(actor);

				editedLevelNetState = true;
			}
		};
		input.onScroll = function(delta) {
			camera.zoomOn(input.getMouseScreenPosition(), delta);
		}
		input.onEscape = function() {
			if (!paused) {
				stopSimulation();
			}
		}
		
		ws = new WebSocket("ws://128.199.98.255:8080");
		var connected = false;
		ws.onopen = function() {
			connected = true;

			if (worldID.length == 0) {
				ws.send("!worldRequest");
			}else{
				ws.send("!joinWorld:"+worldID);
				ws.send("!updateRequest");
			}
		}
		ws.onmessage = function(message:MessageType) {
			switch (message){
				case BytesMessage(content): {
					if (!paused) {
						// Ignore world updates while paused
						return;
					}
					var bytes = content.readAllAvailableBytes();
					lastNetState = bytes;
					editedLevelNetState = false;
					scene.loadBytes(bytes);
				}
				case StrMessage(content): {
					if (content.indexOf("!worldAllocated") == 0) {
						worldID = content.split(":")[1];

						#if (js)
							untyped {
								window.history.pushState({}, null, worldID);
							}
						#end

						ws.send("!joinWorld:"+worldID);
					}
				}
			}
		}

		Scheduler.addTimeTask(function sendWorld(){
			if (lastNetState == scene.getBytes() || !editedLevelNetState || !paused) {
				return;
			}
			editedLevelNetState = false;
			ws.send(scene.getBytes());
		}, 1, .05);
	}

	function startSimulation() {
		worldstatePreSimulation = scene.getBytes();
		paused = false;
	}
	function stopSimulation() {
		scene.actors = [];
		scene.loadBytes(worldstatePreSimulation);
		ws.send("!updateRequest");
		paused = true;
	}
	public function tick(): Void {
		if (paused)
			return;

		ticks++;

		if (!scene.hasHalted()){
			scene.tick();
		} else {
			trace((ticks-1) + " ticks");
			for (actor in scene.actors) {
				if (actor.type == Stockpile || actor.type == Hoard) {
					trace(cast(actor,StorageActor).berries);
				}
			}
			stopSimulation();
			return;
		}

		if (ticks >= maxTicks && maxTicks != -1) {
			trace("Timed out");
			kha.System.stop();
		}
	}

	public function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(kha.Color.fromBytes(95,151,0));

		camera.transform(g);
		scene.render(g);
		camera.reset(g);

		if (paused) {
			// Render place preview
			if (input.getMouseScreenPosition().y > ActorBar.height) {
				var worldPosition = input.getMouseWorldPosition();
				var gridPosition = new Vector2i(Math.floor(worldPosition.x/Scene.TILESIZE), Math.floor(worldPosition.y/Scene.TILESIZE));
				g.color = kha.Color.White;
				camera.transform(g);
				g.drawRect(gridPosition.x*Scene.TILESIZE, gridPosition.y*Scene.TILESIZE, Scene.TILESIZE, Scene.TILESIZE, 4);
				camera.reset(g);
			}

			actorBar.render(g);
			editButton.render(g);
			viewButton.render(g);
			goButton.render(g);
		}
		g.end();
	}

	public static function main() {
		// Remove trace prefix
		#if sys
			haxe.Log.trace = function(msg, ?position) { Sys.print(msg); }
		#end

		#if js
			haxe.Log.trace = function(msg, ?pos) js.Browser.window.console.log(msg);
		#end

		System.start({title: "ShadowLife", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {

				var tickFrequency = .01;

				var main = new Main();
				Scheduler.addTimeTask(function () { main.tick(); }, tickFrequency, tickFrequency);
				System.notifyOnFrames(function (framebuffers) { main.render(framebuffers[0]); });
			});
		});
	}
}
