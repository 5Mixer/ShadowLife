package editor;

import kha.Image;
import simulation.actor.Actor.ActorType;

class ActorBarEntry {
    public final actorType:ActorType;
    public final image:Image;
    public function new(actorType:ActorType, image:Image) {
        this.actorType = actorType;
        this.image = image;
    }
}