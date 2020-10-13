package simulation.actor;

// Implemented by all classes that can accept or provide food, with their underlying storage abstract
// This means that Actors such as GoldenTrees can provide or accept fruit, despite being infinite providers
interface Storage {
    public function addFruit():Void;
    public function removeFruit():Void;
    public function hasFruit():Bool;
}