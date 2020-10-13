package simulation.actor.character;

import simulation.actor.Actor.ActorType;

class Gatherer extends Character {
    override public function new(position) {
        super(position);
        type = ActorType.Gatherer;
        direction = LEFT;
        carrying = false;
    }

    override public function tick(scene:Scene) {
        super.tick(scene);

        if (active) {
            move();
        }

        if (scene.getActorTypeAtPosition(position, Fence).length > 0){
            active = false;
            move(false);
        }

        if (scene.getActorTypeAtPosition(position, MitosisPool).length > 0){
            var leftGatherer = new Gatherer(position.mult(1));
            leftGatherer.direction = direction.getAnticlockwise();
            leftGatherer.move();
            scene.queueNewActor(leftGatherer);

            var rightGatherer = new Gatherer(position.mult(1));
            rightGatherer.direction = direction.getClockwise();
            rightGatherer.move();
            scene.queueNewActor(rightGatherer);

            destroy();
            return;
        }

        for (sign in scene.getActorTypeAtPosition(position, Sign)) {
            direction = cast(sign, Sign).direction;
        }

        // if able to take fruit from thing providing fruit, do so.
        if (!carrying) {
            for (tree in scene.getActorTypesAtPosition(position, [Tree, GoldenTree])) {
                var tree:Storage = cast tree;
                if (tree.hasFruit()) {
                    tree.removeFruit();
                    carrying = true;
                    direction = direction.getClockwise().getClockwise(); // Turn to opposite direction implicitely
                }
            }
        }

        // Deposit fruits if possible
        for (storage in scene.getActorTypesAtPosition(position, [Hoard, Stockpile])) {
            var storage = cast(storage, Storage);
            if (carrying) {
                carrying = false;
                storage.addFruit();
            }
            direction = direction.getClockwise().getClockwise(); // Turn to opposite direction implicitely
        }
    }
}