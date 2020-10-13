package simulation.actor;

// A storage actor is an actor with a finite amount of storage
class StorageActor extends Actor implements Storage {
    public var berries = 0;

    public function addFruit():Void {
        berries++;
    }
    public function removeFruit():Void {
        berries--;
    }
    public function hasFruit():Bool {
        return berries > 0;
    }
}