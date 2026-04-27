package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import backend.Paths;

class PlayState extends FlxState {
    var packman:FlxSprite;
    var body:FlxGroup;
    var moveSpeed:Float = 0.15;
    var direction:Int = 1; // 0 = up, 1 = down
    var gridSize:Int = 32;

    override public function create() {
        super.create();

        bgColor = 0xFF000000;

        body = new FlxGroup();
        add(body);

        packman = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
        packman.frames = Paths.getSparrowAtlas("packman");
        packman.animation.addByPrefix("idle", "idle", 24, true);
        packman.animation.play("idle");
        packman.scale.set(0.5, 0.5);
        packman.updateHitbox();
        add(packman);

        new FlxTimer().start(moveSpeed, movePackman, 0);
    }

    function movePackman(timer:FlxTimer) {
        if (FlxG.keys.justPressed.UP) direction = 0;
        if (FlxG.keys.justPressed.DOWN) direction = 1;

        var segment = new FlxSprite(packman.x, packman.y);
        segment.makeGraphic(gridSize, gridSize, 0xFFFFFF00);
        body.add(segment);

        switch (direction) {
            case 0:
                packman.y -= gridSize;
            case 1:
                packman.y += gridSize;
        }

        if (packman.y < 0) packman.y = FlxG.height - gridSize;
        if (packman.y > FlxG.height - gridSize) packman.y = 0;

        if (body.length > 8) {
            var old = cast(body.members[0], FlxSprite);
            if (old != null) {
                body.remove(old, true);
                old.destroy();
            }
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (packman.animation.curAnim == null || packman.animation.curAnim.name != "idle") {
            packman.animation.play("idle");
        }
    }
}
