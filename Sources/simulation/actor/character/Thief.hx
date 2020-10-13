package simulation.actor.character;

import simulation.actor.Actor.ActorType;

class Thief extends Character {
    var consuming = false;

    override public function new(position) {
        super(position);
        type = ActorType.Thief;
        direction = UP;
    }

    override public function tick(scene:Scene) {
        super.tick(scene);

        if (active) {
            move();
        }

        // Fence halting
        if (scene.getActorTypeAtPosition(position, Fence).length > 0){
            active = false;
            move(false);
        }

        // Mitosis behaviour
        if (scene.getActorTypeAtPosition(position, MitosisPool).length > 0){
            var leftThief = new Thief(position.mult(1));
            leftThief.direction = direction.getAnticlockwise();
            leftThief.move();
            scene.queueNewActor(leftThief);

            var rightThief = new Thief(position.mult(1));
            rightThief.direction = direction.getClockwise();
            rightThief.move();
            scene.queueNewActor(rightThief);

            destroy();
            return;
        }

        // Follow signs
        for (sign in scene.getActorTypeAtPosition(position, Sign)){
            direction = cast(sign, Sign).direction;
        }

        // consume on pads
        if (scene.getActorTypeAtPosition(position, Pad).length > 0){
            consuming = true;
        }

        // Rotate on gatherers
        if (scene.getActorTypeAtPosition(position,Gatherer).length > 0){
            direction = direction.getAnticlockwise();
        }

        // if able to take fruit from thing providing fruit, do so.
        if (!carrying) {
            for (tree in scene.getActorTypesAtPosition(position, [Tree, GoldenTree])){
                var tree:Storage = cast tree;
                if (tree.hasFruit()) {
                    tree.removeFruit();
                    carrying = true;
                }
            }
        }

        // Deposit fruits if possible
        for (hoard in scene.getActorTypeAtPosition(position, Hoard)){
            var hoard = cast(hoard, Hoard);
            if (consuming) {
                consuming = false;
                if (!carrying) {
                    if (hoard.hasFruit()) {
                        carrying = true;
                        hoard.removeFruit();
                    }else{
                        direction = direction.getClockwise();
                    }
                }
            }else if (carrying) {
                carrying = false;
                hoard.addFruit();
                direction = direction.getClockwise();
            }
        }

        // Steal from stockpiles
        for (stockpile in scene.getActorTypeAtPosition(position, Stockpile)){
            var stockpile = cast(stockpile, Stockpile);
            if (!carrying) {
                if (stockpile.hasFruit()) {
                    carrying = true;
                    consuming = false;
                    stockpile.removeFruit();
                    direction = direction.getClockwise();
                }
            }else{
                direction = direction.getClockwise();
            }
        }
    }
}