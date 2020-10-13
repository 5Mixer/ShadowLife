package;

import simulation.Scene;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var scene:Scene;
	public function new() {
		scene = new Scene();
		scene.loadScene(kha.Assets.blobs.product_csv.toString());
	}
	public function tick(): Void {
		if (!scene.hasHalted()){
			scene.tick();
			trace(scene.renderCharMap());
		} else
			trace("Halted");
	}

	public function render(framebuffer: Framebuffer): Void {
	}

	public static function main() {
		System.start({title: "Kha", width: 800, height: 600}, function (_) {
			Assets.loadEverything(function () {

				var tickFrequency = .1;

				var main = new Main();
				Scheduler.addTimeTask(function () { main.tick(); }, tickFrequency, tickFrequency);
				System.notifyOnFrames(function (framebuffers) { main.render(framebuffers[0]); });
			});
		});
	}
}
