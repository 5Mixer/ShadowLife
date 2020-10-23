package ;

import kha.input.Keyboard;
import kha.input.Mouse;
import kha.math.Vector2;

class Input {
    var camera:Camera;
    
    var mousePosition:Vector2;

    public var leftMouseButtonDown = false;
    public var middleMouseButtonDown = false;
    public var rightMouseButtonDown = false;
    public var onRightDown:()->Void = function(){};
    public var onRightUp:()->Void = function(){};
    public var onLeftDown:()->Void = function(){};
    public var onMouseMove:(Int,Int)->Void = function(x,y){};
    public var onScroll:(Int)->Void = function(delta){};
    public var onEscape:()->Void = function(){};

    public function new(camera) {
        this.camera = camera;
        
        Mouse.get().notify(onMouseDown, onMouseUp, mouseMoveHandler, onMouseWheel);
        Keyboard.get().notify(function(key) {
            if (key == Escape)
                onEscape();
        },null,null);

        mousePosition = new Vector2();
    }
    
    function onMouseDown(button:Int, x:Int, y:Int) {
        mousePosition.x = x;
        mousePosition.y = y;
        
        if (button == 0){
            leftMouseButtonDown = true;
            onLeftDown();
        }
        if (button == 1){
            rightMouseButtonDown = true;
            onRightDown();
        }
        if (button == 2)
            middleMouseButtonDown = true;
    }
    function onMouseUp(button:Int, x:Int, y:Int) {
        mousePosition.x = x;
        mousePosition.y = y;
        
        if (button == 0){
            leftMouseButtonDown = false;
        }
        if (button == 1) {
            rightMouseButtonDown = false;
            onRightUp();
        }
        if (button == 2)
            middleMouseButtonDown = false;
    }
    function mouseMoveHandler(x:Int, y:Int, dx:Int, dy:Int) {
        mousePosition.x = x;
        mousePosition.y = y;
        onMouseMove(dx,dy);
    }
    function onMouseWheel(delta:Int) {
        onScroll(delta);
    }
    
    public function getMouseWorldPosition():kha.math.Vector2 {
        return camera.viewToWorld(mousePosition);
    }
    public function getMouseScreenPosition():kha.math.Vector2 {
        return mousePosition;
    }
}