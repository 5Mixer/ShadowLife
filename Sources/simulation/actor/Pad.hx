package simulation.actor;

import simulation.actor.Actor.ActorType;

class Pad extends Actor {
    override public function new(position) {
        super(position);
        type = ActorType.Pad;
    }
}