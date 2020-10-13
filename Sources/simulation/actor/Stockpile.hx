package simulation.actor;

import simulation.actor.Actor.ActorType;

class Stockpile extends StorageActor {
    override public function new(position) {
        super(position);
        type = ActorType.Stockpile;
    }
}