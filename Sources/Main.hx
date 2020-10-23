package;

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
	var paused = false;
	var actorBar:ActorBar;

	public function new() {
		#if sys
		maxTicks = Std.parseInt(Sys.args()[1]);
		#end

		scene = new Scene();
		actorBar = new ActorBar();

		camera = new Camera();
		input = new Input(camera);

		input.onMouseMove = function(dx,dy) {
			if (input.middleMouseButtonDown) {
				camera.position.x -= dx;
				camera.position.y -= dy;
			}
			if (input.leftMouseButtonDown && input.getMouseScreenPosition().y > ActorBar.height) {
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
			}
		};
		input.onScroll = function(delta) {
			// if (mouseInUI()) {
			// 	ui.scroll(delta);
			// }else{
				camera.zoomOn(input.getMouseScreenPosition(), delta);
			// }
		}
		input.onEscape = function() {
			if (paused) {
				paused = false;
			}
		}
		
		var ws = new WebSocket("ws://localhost:8080");
		var connected = false;
		ws.onopen = function() {
			connected = true;
		}
		ws.onmessage = function(message:MessageType) {
			switch (message){
				case BytesMessage(content): {

				}
				case StrMessage(content): {

				}
			}
		}
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
			paused = true;
			return;
		}

		if (ticks >= maxTicks && maxTicks != -1) {
			trace("Timed out");
			kha.System.stop();
		}
	}

	public function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin();

		camera.transform(g);
		scene.render(g);
		camera.reset(g);

		if (paused) {
			actorBar.render(g);
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
