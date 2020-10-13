package simulation.util;

enum abstract Direction(Int) {
    var UP;
    var DOWN;
    var LEFT;
    var RIGHT;
    public function getAnticlockwise() {
        return switch(cast this) {
            case UP: return LEFT;
            case LEFT: return DOWN;
            case DOWN: return RIGHT;
            case RIGHT: return UP;
        }
    }
    public function getClockwise() {
        return switch(cast this) {
            case UP: return RIGHT;
            case LEFT: return UP;
            case DOWN: return LEFT;
            case RIGHT: return DOWN;
        }
    }
}