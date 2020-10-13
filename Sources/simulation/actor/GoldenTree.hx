package simulation.actor;

class GoldenTree extends Actor implements Storage{

    // Golden tree behaviour is that of a tree, with infinite fruit
    public function addFruit() {}
    public function removeFruit() {}
    public function hasFruit() { return true; }
}