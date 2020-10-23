package editor;

import simulation.actor.Actor.ActorType;
import simulation.util.Direction;
import kha.Image;

class SignActorBarEntry extends ActorBarEntry {
    public final direction:Direction;
    public function new(actorType:ActorType, image:Image, direction:Direction) {
        super(actorType, image);
        this.direction = direction;
    }
}