package simulation.actor;

import simulation.actor.Actor.ActorType;
import simulation.util.Direction;
import kha.math.Vector2i;

class Sign extends Actor {
    public var direction:Direction;
    override public function new(position:Vector2i, direction:Direction) {
        super(position);
        this.direction = direction;
        this.type = ActorType.Sign;
    }
}