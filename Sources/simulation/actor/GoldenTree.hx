package simulation.actor;

import simulation.actor.Actor.ActorType;

class GoldenTree extends Actor implements Storage{
    override public function new(position) {
        super(position);
        type = ActorType.GoldenTree;
    }

    // Golden tree behaviour is that of a tree, with infinite fruit
    public function addFruit() {}
    public function removeFruit() {}
    public function hasFruit() { return true; }
}