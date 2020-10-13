package simulation;

import simulation.util.Direction;
import simulation.actor.character.Character;
import simulation.actor.Actor;
import kha.math.Vector2i;
import simulation.actor.*;
import simulation.actor.character.*;

class Scene {
    public var actors:Array<Actor>;
    var actorQueue:Array<Actor>;

    public static var TILESIZE = 64;

    public function new() {
        actors = new Array<Actor>();
        actorQueue = new Array<Actor>();
    }

    public function loadScene(sceneData:String){
        var lineNumber = 1;
        for (line in sceneData.split("\n")) {
            var lineValues = line.split(",");
            if (lineValues.length == 3){
                var type = lineValues[0];
                var x = Math.floor(Std.parseInt(lineValues[1])/TILESIZE);
                var y = Math.floor(Std.parseInt(lineValues[2])/TILESIZE);

                if (type == "Tree") {
                    actors.push(new Tree(new Vector2i(x, y)));
                }else if (type == "GoldenTree") {
                    actors.push(new GoldenTree(new Vector2i(x, y)));
                }else if (type == "Gatherer") {
                    actors.push(new Gatherer(new Vector2i(x, y)));
                }else if (type == "Thief") {
                    actors.push(new Thief(new Vector2i(x, y)));
                }else if (type == "Stockpile") {
                    actors.push(new Stockpile(new Vector2i(x, y)));
                }else if (type == "Hoard") {
                    actors.push(new Hoard(new Vector2i(x, y)));
                }else if (type == "Pad") {
                    actors.push(new Pad(new Vector2i(x, y)));
                }else if (type == "Pool") {
                    actors.push(new MitosisPool(new Vector2i(x, y)));
                }else if (type == "Fence") {
                    actors.push(new Fence(new Vector2i(x, y)));
                }else if (type == "SignLeft") {
                    actors.push(new Sign(new Vector2i(x, y), Direction.LEFT));
                }else if (type == "SignRight") {
                    actors.push(new Sign(new Vector2i(x, y), Direction.RIGHT));
                }else if (type == "SignUp") {
                    actors.push(new Sign(new Vector2i(x, y), Direction.UP));
                }else if (type == "SignDown") {
                    actors.push(new Sign(new Vector2i(x, y), Direction.DOWN));
                }
            }

            lineNumber++;
        }
    }

    public function renderCharMap() {
        var output = "";
        for (y in 0...16) {
            for (x in 0...12) {
                var actor = getActorsAtPosition(new Vector2i(x,y)).pop();
                if (Std.isOfType(actor, Character))
                    output += "@";
                else 
                    output += " ";
            }
            output += "\n";
        }
        return output;
    }

    public function tick() {
        for (actor in actors) {
            actor.tick(this);
        }

        actors = actors.filter(a -> !a.flaggedForDestruction);

        while (actorQueue.length > 0)
            actors.push(actorQueue.pop());
    }

    public function getActorsAtPosition(position:Vector2i) {
        var colliders:Array<Actor> = [];
        for (actor in actors) {
            if (actor.position.x == position.x && actor.position.y == position.y && !actor.flaggedForDestruction) {
                colliders.push(actor);
            }
        }
        return colliders;
    }
    public function getActorTypeAtPosition(position:Vector2i, type:ActorType) {
        return getActorsAtPosition(position).filter(a -> a.type == type);
    }
    public function getActorTypesAtPosition(position:Vector2i, types:Array<ActorType>) {
        return getActorsAtPosition(position).filter(a -> types.indexOf(a.type) != -1);
    }

    public function removeActor(actor:Actor) {
        actors.remove(actor);
    }

    public function queueNewActor(actor:Actor) {
        actorQueue.push(actor);
    }

    public function hasHalted() {
        for (actor in actors){
            if (!Std.isOfType(actor, Character))
                continue;
            
            if (cast(actor,Character).active) {
                return false;
            }
        }
        return true;
    }
}