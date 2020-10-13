package;

import kha.Window;
import simulation.actor.StorageActor;
import simulation.Scene;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var scene:Scene;
	var ticks = 0;
	var maxTicks = -1;
	var paused = false;
	public function new() {
		#if sys
		maxTicks = Std.parseInt(Sys.args()[1]);
		#end

		scene = new Scene();
		scene.loadScene(kha.Assets.blobs.product_csv.toString());
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
			kha.System.stop();
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
		g.drawImage(kha.Assets.images.background, 0, 0);
		for (entity in scene.actors) {
			g.drawImage(switch(entity.type) {
				case Gatherer: kha.Assets.images.gatherer;
				case Thief: kha.Assets.images.thief;
				case Fence: kha.Assets.images.fence;
				case GoldenTree: kha.Assets.images.gold_tree;
				case Hoard: kha.Assets.images.hoard;
				case MitosisPool: kha.Assets.images.pool;
				case Pad: kha.Assets.images.pad;
				case Sign: 
					switch (cast(entity,simulation.actor.Sign).direction) {
						case UP: kha.Assets.images.up;
						case DOWN: kha.Assets.images.down;
						case LEFT: kha.Assets.images.left;
						case RIGHT: kha.Assets.images.right;
					}
				case Stockpile: kha.Assets.images.cherries;
				case Tree: kha.Assets.images.tree;
			},entity.position.x*Scene.TILESIZE, entity.position.y*Scene.TILESIZE);

			if (Std.isOfType(entity, StorageActor)) {
				g.fontSize = 20;
				g.font = kha.Assets.fonts.VeraMono;
				g.drawString(cast(entity,StorageActor).berries+"", entity.position.x*Scene.TILESIZE, entity.position.y*Scene.TILESIZE);
			}
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
