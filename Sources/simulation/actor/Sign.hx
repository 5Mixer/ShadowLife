package simulation.actor;

import simulation.util.Direction;

class Sign extends Actor {
    public var direction:Direction;
    override public function new(direction:Direction) {
        this.direction = direction;
    }
}