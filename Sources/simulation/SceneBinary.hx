package simulation;

import simulation.actor.*;
import simulation.actor.character.*;
import kha.math.Vector2i;
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
                    case UP: 7;
                    case DOWN: 8;
                    case LEFT: 9;
                    case RIGHT: 10;
                }
            case Stockpile: 11;
            case Tree: 12;
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
            var largePosition = actor.position.x > 255 || actor.position.y > 255;
            var actorCode = getActorCode(actor);
            if (largePosition) {
                actorCode |= 1<<7;
            }
            bytes.set(byteOffset, actorCode);
            byteOffset++;

            // For positions that require more than a byte, use two bytes, otherwise use single bytes
            if (largePosition) {
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

    // Mutates bytes when unflipping large position bit
    public static function fromBytes(bytes:Bytes) {
        if (bytes.length == 0)
            return [];

        var actors = new Array<Actor>();
        var byteOffset = 0;
        while (byteOffset < bytes.length) {
            var actorCode = bytes.get(byteOffset);
            byteOffset++;

            var largePosition = actorCode & (1 << 7) != 0;
            actorCode = actorCode & (15); // Preverse 4 LSB, 15d = 1111b

            var position:Vector2i;
            if (largePosition) {
                var x = bytes.getUInt16(byteOffset);
                byteOffset += 2;
                var y = bytes.getUInt16(byteOffset);
                byteOffset += 2;

                position = new Vector2i(x,y);
            }else{
                var x = bytes.get(byteOffset);
                byteOffset++;
                var y = bytes.get(byteOffset);
                byteOffset++;

                position = new Vector2i(x,y);
            }

            var actor:Actor;
            actor = switch(actorCode) {
                case 0: new Gatherer(position);
                case 1: new Thief(position);
                case 2: new Fence(position);
                case 3: new GoldenTree(position);
                case 4: new Hoard(position);
                case 5: new MitosisPool(position);
                case 6: new Pad(position);

                case 7: new Sign(position, UP);
                case 8: new Sign(position, DOWN);
                case 9: new Sign(position, LEFT);
                case 10: new Sign(position, RIGHT);
                
                case 11: new Stockpile(position);
                case 12: new Tree(position);

                case _: null;
            }
            actors.push(actor);
        }
        return actors;
    }
}