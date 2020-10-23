package simulation;

import haxe.io.Bytes;
import simulation.actor.Actor;

class SceneBinary {
    static function getActorCode(actor:Actor) {
        return switch(actor.type) {
            case Gatherer: 0;
            case Thief: 1;
            case Fence: 2;
            case GoldenTree: 3;
            case Hoard: 4;
            case MitosisPool: 5;
            case Pad: 6;
            case Sign: 
                switch (cast(actor,simulation.actor.Sign).direction) {
                    case UP: 6;
                    case DOWN: 7;
                    case LEFT: 8;
                    case RIGHT: 9;
                }
            case Stockpile: 10;
            case Tree: 11;
        }
    }

    static function getActorBytesLength(actor:Actor) {
        return (actor.position.x > 255 || actor.position.y > 255) ? 5 : 3;
    }

    public static function getBytes(actors:Array<Actor>) {
        var requiredBytes = 0;
        for (actor in actors) {
            requiredBytes += getActorBytesLength(actor);
        }

        var bytes = Bytes.alloc(requiredBytes); 

        var byteOffset = 0;
        for (actor in actors) {
            bytes.set(byteOffset, getActorCode(actor));
            byteOffset++;

            // For positions that require more than a byte, use two bytes, otherwise use single bytes
            if (actor.position.x > 255 || actor.position.y > 255) {
                bytes.setUInt16(byteOffset, actor.position.x);
                byteOffset += 2;
                bytes.setUInt16(byteOffset, actor.position.y);
                byteOffset += 2;
            }else{
                bytes.set(byteOffset, actor.position.x);
                byteOffset++;
                bytes.set(byteOffset, actor.position.y);
                byteOffset++;
            }
        }

        return bytes;
    }
}