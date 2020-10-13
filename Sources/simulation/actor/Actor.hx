package simulation.actor;

import kha.math.Vector2i;

enum ActorType {
    Gatherer;
    Thief;
    Fence;
    GoldenTree;
    Hoard;
    MitosisPool;
    Pad;
    Sign;
    Stockpile;
    Tree;
}
class Actor {
    public var position:Vector2i;
    public var type:ActorType;
    public function new(position) {
        this.position = position;
    }
    public function tick(scene:Scene) {

    }
}