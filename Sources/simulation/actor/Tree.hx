package simulation.actor;

import simulation.actor.Actor.ActorType;

class Tree extends StorageActor {
    override public function new(position) {
        super(position);
        type = ActorType.Tree;
    }
}