package simulation.actor.character;

import simulation.util.Direction;

class Character extends Actor {
    var direction = Direction.LEFT;
    var active = true;
    var carrying = false;

    public function move(forwards = true) {
        var changeFactor = forwards ? 1 : -1;

        if (direction == Direction.LEFT) {
            position.x -= changeFactor;
        } else if (direction == Direction.RIGHT) {
            position.x += changeFactor;
        } else if (direction == Direction.UP) {
            position.y -= changeFactor;
        } else if (direction == Direction.DOWN) {
            position.y += changeFactor;
        }
    }
}