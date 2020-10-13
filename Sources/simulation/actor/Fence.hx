package simulation.actor;

import simulation.actor.Actor.ActorType;

class Fence extends Actor {
    override public function new(position) {
        super(position);
        type = ActorType.Fence;
    }
}