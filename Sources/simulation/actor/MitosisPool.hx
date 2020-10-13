package simulation.actor;

import simulation.actor.Actor.ActorType;

class MitosisPool extends Actor {
    override public function new(position) {
        super(position);
        type = ActorType.MitosisPool;
    }
}