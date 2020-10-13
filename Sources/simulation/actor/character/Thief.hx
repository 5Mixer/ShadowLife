package simulation.actor.character;

class Thief extends Character {
    var consuming = false;

    override public function tick(scene:Scene) {
        super.tick(scene);

        if (active) {
            move();
        }

        // Fence halting
        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Fence)).length > 0){
            active = false;
            move(false);
        }

        // Mitosis behaviour
        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, MitosisPool)).length > 0){
            var leftThief = new Thief(position.mult(1));
            leftThief.direction = leftThief.direction.getAnticlockwise();
            leftThief.move();
            scene.queueNewActor(leftThief);

            var rightThief = new Thief(position.mult(1));
            rightThief.direction = leftThief.direction.getClockwise();
            rightThief.move();
            scene.queueNewActor(rightThief);

            scene.removeActor(this);
            return;
        }

        // consume on pads
        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Pad)).length > 0){
            consuming = true;
        }

        // Rotate on gatherers
        if (scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Gatherer)).length > 0){
            direction = direction.getAnticlockwise();
        }

        // if able to take fruit from thing providing fruit, do so.
        if (!carrying) {
            for (tree in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Tree) || Std.isOfType(a, GoldenTree))){
                var tree:Storage = cast tree;
                if (tree.hasFruit()) {
                    tree.removeFruit();
                    carrying = true;
                }
            }
        }

        // Deposit fruits if possible
        for (hoard in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Hoard))){
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
        for (stockpile in scene.getActorsAtPosition(position).filter(a -> Std.isOfType(a, Stockpile))){
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