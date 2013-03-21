DD.startCycle(false)

DD("^mainEvent", window)

DD("!canvas", "canvas", 512, 448).clearEachFrame()

DD.buildSprite [{name: "heros_tile", x: 4, y: 1, w: 46, h: 150, startX: 0, startY: 0, partW: 184, partH: 150},
        {name: "bg_tile", w: 512, h: 448, imgW: 512, imgH: 448, startX: 0, startY: 0},
        {name: "enemy_tile", x: 2, y: 1, w: 20, h: 20, startX: 0, startY: 0, partW: 40, partH: 20},
        {name: "coin_tile", x: 2, y: 1, w: 20, h: 20, startX: 20, startY: 0, partW: 20, partH: 20},
        {name: "front_tile", x: 1, y: 1, w: 512, h: 448, startX: 0, startY: 0, partW: 512, partH: 448}
        {name: "plateforme_tile", x: 1, y: 1, w: 50, h: 10, startX: 0, startY: 0, partW: 50, partH: 10}]
DD.loadImages [{name: "perso", src: "img/heros.png"},
        {name: "front", src: "img/front.png"},
        {name: "bg", src: "img/bg.png"},
        {name: "coin", src: "img/coin.png"},
        {name: "plateforme", src: "img/plateform.png"}], =>

        INTRO = ->
                launch = (e) ->
                        if e.keyCode is 32
                                DD(".bgintro").kill()
                                DD(".front").kill()
                                window.removeEventListener("keydown", launch, false)
                                GAME()
                DD(".bgintro").addSquare(512, 448, 0, 0).addTexture(DD("|bg_tile"), DD("@bg")).drawTexture DD("!canvas")
                DD(".bgintro").animateTexture(0, -2, 1, -1)
                DD(".front").addSquare(512, 448, 0, 0).addTile(DD("|front_tile"), DD("@front")).drawTile DD("!canvas")
                window.addEventListener "keydown", launch, false
        END = (score) ->
                DD(".bgintro").addSquare(512, 448, 0, 0).addTexture(DD("|bg_tile"), DD("@bg")).drawTexture DD("!canvas")
                DD(".bgintro").animateTexture(0, -2, 1, -1)
                stop = ->
                        DD(".bgintro").kill()
                        INTRO()
                        DD.unsubscribe(text)
                text = DD.subscribe "raf:frame:tick", =>
                        DD("!canvas").printText({txt: "Score:\n#{score}" ,x: 256, y: 224, bgColor: "#fff",txtColor: "#000", fontFamily: "Changa One", fontSize: "40"}, true)
                DD("!canvas").ctx.fillStyle = "#fff"
                DD("!canvas").ctx.font = "40px Arial";
                DD("!canvas").ctx.fillText("Score : " + score, 5, 25)
                window.setTimeout (-> stop()), 5000
        GAME = ->
                DD(".bg").addSquare(512, 448, 0, 0).addTexture(DD("|bg_tile"), DD("@bg")).drawTexture DD("!canvas")
                DD(".bg").animateTexture(0, -2, 1, -1)
                DD(".heros").addSquare(46, 150, 221, 280).addTile(DD("|heros_tile"), DD("@perso")).animateTile(0, 2, true, 10, -1).drawTile(DD("!canvas"))
                DD(".heros")._vx = 0
                DD(".heros")._vy = -30
                DD(".heros")._fakeVy = 0
                score = 0
                event = DD("^mainEvent")
                less = 300
                spawnTime = 1
                enemyCounter = 0
                spawnFn = ->
                        node = DD.newNode()
                        .addSquare(20, 20, Math.floor(Math.random() * 512), Math.floor(Math.random() * 50) * - 1)
                        .addTile(DD("|enemy_tile"), DD("@coin"))
                        .animateTile(1, 0, false, 4, -1)
                        .drawTile(DD("!canvas"), 100)
                        node.enemy = false
                        DD("#coins").add node
                        if enemyCounter >= 20
                                enemyCounter = 0
                                if Math.random() * 4 <= 3
                                        enemy = DD.newNode()
                                        .addSquare(20, 20, Math.floor(Math.random() * 512), Math.floor(Math.random() * 50) * - 1)
                                        .addTile(DD("|enemy_tile"), DD("@coin"))
                                        .animateTile(0, 0, false, 4, -1)
                                        .drawTile(DD("!canvas"), 100)
                                        enemy.enemy = true
                                        DD("#coins").add enemy
                        less++
                        enemyCounter++
                        if less > 200 and spawnTime < 20
                                spawnTime++
                                less = 0
                                if DD("#coins")._spawn
                                        DD("#coins").killCycle DD("#coins")._spawn
                                DD("#coins")._spawn = DD("#coins").addCycle spawnTime, -1, => spawnFn()
                spawnFn()
                gr = false
                explode = ->
                        if score <= 0 then return false
                        DD("#explosion")
                        i = 0
                        if gr then gr.stop()
                        while i < score
                                node = DD.newNode()
                                .addSquare(20, 20, DD(".heros").square.x, DD(".heros").square.y)
                                .addTile(DD("|enemy_tile"), DD("@coin"))
                                .animateTile(0, 1, false, 4, -1)
                                .drawTile(DD("!canvas"), 100)
                                node._vx = Math.random() * 2 - 1
                                node._vy = Math.random() * 2 - 1
                                DD("#explosion").add node
                                i++
                        gr = DD("#explosion").addCycle 1, -1, =>
                                DD("#explosion").each (elem) =>
                                        elem.square.moveY elem._vy
                                        elem.square.moveX elem._vx
                                        elem._vy += 0.1
                                        if elem.square.x > 512 or elem.square.xx < 0 or elem.square.y > 448
                                                elem.kill()
                                                DD("#explosion").trash(elem)
                                        if DD("#explosion").col.length <= 0
                                                gr.stop()
                        score = 0
                DD("!canvas").ctx.fillStyle = "#fff"
                DD("!canvas").ctx.font = "20px Arial";
                DD(".heros")._gravity = DD.subscribe "raf:frame:tick", =>
                        DD("!canvas").ctx.fillText("Score : " + score, 5, 25)
                        if DD(".heros")._vy < 15
                                DD(".heros")._vy += 0.2
                                DD(".bg").animateTexture(0, DD(".heros")._vy, 1, 1)
                        else
                                DD(".heros").square.y += 3
                        if DD(".heros").square.y > 448
                                DD.unsubscribe(DD(".heros")._gravity)
                                DD.kill(".heros")
                                DD.kill(".bg")
                                DD("#coins").killCycle DD("#coins")._spawn
                                DD.kill("#coins")
                                END(score)
                                return false
                        DD("#coins").each (elem) =>
                                elem.square.moveY -DD(".heros")._vy
                                if elem.square.y > 600 or elem.square.yy < 0
                                        elem.kill()
                                        DD("#coins").trash(elem)
                        DD("#coins").squareCollision(DD(".heros"), (elem) =>
                                if not elem.enemy
                                        DD(".heros")._vy = -20
                                        score++
                                else
                                        explode()
                                elem.kill()
                                DD("#coins").trash(elem)
                                DD(".heros")._fakeVy = -3
                        )
                        if event.right
                                if DD(".heros")._vx < 7 then DD(".heros")._vx += 1 else DD(".heros")._vx = 7
                        if event.left
                                if DD(".heros")._vx > -7 then DD(".heros")._vx -= 1 else DD(".heros")._vx = -7
                        DD(".heros")._vx *= 0.95
                        DD(".heros").square.moveX(DD(".heros")._vx)
                        if DD(".heros").square.xx > 512
                                DD(".heros").square.moveToX(512 - 50)
                                DD(".heros")._vx = DD(".heros")._vx * -1 / 2
                        if DD(".heros").square.x < 0
                                DD(".heros").square.moveToX(0)
                                DD(".heros")._vx = DD(".heros")._vx * -1 / 2
        INTRO()