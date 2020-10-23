package editor;

import kha.input.Mouse;
import simulation.util.Direction;
import simulation.actor.Actor.ActorType;
import kha.Window;
import kha.graphics2.Graphics;

class ActorBar {
    static final backgroundColour = kha.Color.fromBytes(191, 184, 187);
    static final borderColour = kha.Color.fromBytes(91, 84, 87);
    static final itemBackground = kha.Color.fromBytes(91, 84, 87);
    static final itemBackgroundHover = kha.Color.fromBytes(111, 104, 107);
    public static final height = 85;
    var options:Array<ActorBarEntry> = [];
    public var activeOption:ActorBarEntry;

    var mouseIsDown = false;
    var mousex = 0;
    var focused = false;

    public function new() {
        options.push(new ActorBarEntry(ActorType.Gatherer, kha.Assets.images.gatherer));
        options.push(new ActorBarEntry(ActorType.Thief, kha.Assets.images.thief));
        options.push(new ActorBarEntry(ActorType.Fence, kha.Assets.images.fence));
        options.push(new ActorBarEntry(ActorType.GoldenTree, kha.Assets.images.gold_tree));
        options.push(new ActorBarEntry(ActorType.Hoard, kha.Assets.images.hoard));
        options.push(new ActorBarEntry(ActorType.MitosisPool, kha.Assets.images.pool));
        options.push(new ActorBarEntry(ActorType.Pad, kha.Assets.images.pad));
        options.push(new ActorBarEntry(ActorType.Stockpile, kha.Assets.images.cherries));
        options.push(new ActorBarEntry(ActorType.Tree, kha.Assets.images.tree));

        options.push(new SignActorBarEntry(ActorType.Sign, kha.Assets.images.up, Direction.UP));
        options.push(new SignActorBarEntry(ActorType.Sign, kha.Assets.images.down, Direction.DOWN));
        options.push(new SignActorBarEntry(ActorType.Sign, kha.Assets.images.left, Direction.LEFT));
        options.push(new SignActorBarEntry(ActorType.Sign, kha.Assets.images.right, Direction.RIGHT));

        activeOption = options[0];

        Mouse.get().notify(function mouseDown(button, x, y) {
            if (button == 0) {
                mouseIsDown = true;
            }
            mousex = x;
            focused = y < height;
        }, function mouseUp(button,x,y){
            if (button == 0) {
                mouseIsDown = false;
            }
        }, function mouseMove(x,y,dx,dy){
            mousex = x;
            focused = y < height;
        }, null);
    }
    public function render(g:Graphics) {
        g.color = backgroundColour;
        g.fillRect(0,0, Window.get(0).width, height);
        
        // Render and process things imgui style
        var x = 10;

        for (option in options) {
            g.color = focused && x < mousex && mousex < x + option.image.width ? itemBackgroundHover : itemBackground;
            g.fillRect(x,height/2-option.image.height/2,option.image.width,option.image.height);

            g.color = kha.Color.White;
            g.drawImage(option.image, x, height/2-option.image.height/2);

            if (focused && mouseIsDown && x < mousex && mousex < x + option.image.width) {
                activeOption = option;
            }

            x += option.image.width + 10;
        }

        g.color = borderColour;
        g.drawLine(0, height, Window.get(0).width, height, 4);

        g.color = kha.Color.White;
    }
}