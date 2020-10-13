package simulation;

import simulation.actor.Actor;
import kha.math.Vector2i;

class Scene {
    var actors:Array<Actor>;
    var actorQueue:Array<Actor>;

    public function new() {
        actors = new Array<Actor>();
        actorQueue = new Array<Actor>();
    }

    public function tick() {
        for (actor in actors) {
            actor.tick(this);
        }

        while (actorQueue.length > 0)
            actors.push(actorQueue.pop());
    }

    public function getActorsAtPosition(position:Vector2i) {
        var colliders:Array<Actor> = [];
        for (actor in actors) {
            if (actor.position.x == position.x && actor.position.y == position.y) {
                colliders.push(actor);
            }
        }
        return colliders;
    }

    public function removeActor(actor:Actor) {
        actors.remove(actor);
    }

    public function queueNewActor(actor:Actor) {
        actorQueue.push(actor);
    }
}