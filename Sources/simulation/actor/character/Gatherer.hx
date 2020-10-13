package simulation.actor.character;

import simulation.actor.Actor.ActorType;

class Gatherer extends Character {
    override public function new(position) {
        super(position);
        type = ActorType.Gatherer;
    }

    override public function tick(scene:Scene) {
        super.tick(scene);

        if (active) {
            move();
        }

        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Fence)).length > 0){
            active = false;
            move(false);
        }

        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, MitosisPool)).length > 0){
            var leftGatherer = new Gatherer(position.mult(1));
            leftGatherer.direction = leftGatherer.direction.getAnticlockwise();
            leftGatherer.move();
            scene.queueNewActor(leftGatherer);

            var rightGatherer = new Gatherer(position.mult(1));
            rightGatherer.direction = leftGatherer.direction.getClockwise();
            rightGatherer.move();
            scene.queueNewActor(rightGatherer);

            scene.removeActor(this);
            return;
        }

        for (sign in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Sign))){
            direction = cast(sign, Sign).direction;
        }

        // if able to take fruit from thing providing fruit, do so.
        if (!carrying) {
            for (tree in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Tree) || Std.isOfType(a, GoldenTree))){
                var tree:Storage = cast tree;
                if (tree.hasFruit()) {
                    tree.removeFruit();
                    carrying = true;
                    direction = direction.getClockwise().getClockwise(); // Turn to opposite direction implicitely
                }
            }
        }

        // Deposit fruits if possible
        for (storage in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Hoard) || Std.isOfType(a, Stockpile))){
            var storage = cast(storage, Storage);
            if (carrying) {
                carrying = false;
                storage.addFruit();
            }
            direction = direction.getClockwise().getClockwise(); // Turn to opposite direction implicitely
        }
    }
}