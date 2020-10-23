package editor;

import kha.Color;
import kha.input.Mouse;
import kha.Image;
import kha.graphics2.Graphics;
import kha.math.Vector2;

class Button {
    var position:Vector2;
    var image:Image;
    var input:Input;

    var clickColour = Color.fromBytes(129, 212, 157);
    var hoverColour = Color.fromBytes(39, 230, 103);

    public function new(image:Image, position:Vector2, callback:Void->Void) {
        this.image = image;
        this.position = position;
        input = new Input(null);

        Mouse.get().notify(function(button,x,y){
            if (button == 0)
                if (position.x < x && x < position.x + image.width && position.y < y && y < position.y + image.height)
                    callback();

        },null,null,null);
    }
    public function render(g:Graphics) {
        if (position.x < input.getMouseScreenPosition().x && input.getMouseScreenPosition().x < position.x + image.width
         && position.y < input.getMouseScreenPosition().y && input.getMouseScreenPosition().y < position.y + image.height)
            g.color = input.leftMouseButtonDown ? clickColour : hoverColour;

        g.drawImage(image, position.x, position.y);
        g.color = kha.Color.White;
    }
}