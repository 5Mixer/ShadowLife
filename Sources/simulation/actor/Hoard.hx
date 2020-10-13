package simulation.actor;

import simulation.actor.Actor.ActorType;

class Hoard extends StorageActor {
    override public function new(position) {
        super(position);
        type = ActorType.Hoard;
    }
}