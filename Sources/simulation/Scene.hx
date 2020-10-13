package simulation;

import simulation.actor.Actor;

class Scene {
    var actors:ArrayList<Actor>;

    public function new() {
        actors = new ArrayList<Actor>();
    }

    public function tick() {
        for (actor in actors) {
            actor.tick();
        }
    }
}