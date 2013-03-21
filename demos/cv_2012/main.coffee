    DD.startCycle(true)
    DD("^mainEvent", window)
    DD("!canvas", "canvas", 800, 600).fullScreen()
    childhood = () ->
        @
    childhood.start = () ->
        DD("!canvas").zoomTo 0, 0, 2, 1, =>
            DD("!canvas").zoomTo(0, 0, 1, 250)
        DD(".sky").addSquare(0, 0, 0, 0).addTexture(DD("|sky_tile"), DD("@decor")).animateTexture(2, 0, 1, -1).drawTexture DD("!canvas")
        DD(".btree").addSquare(0, 0, 0, 175).addTexture(DD("|big_tree_tile"), DD("@decor")).animateTexture(3, 0, 1, -1).drawTexture DD("!canvas")
        DD(".ltree").addSquare(0, 0, 0, 353).addTexture(DD("|little_tree_tile"), DD("@decor")).animateTexture(4, 0, 1, -1).drawTexture DD("!canvas")
        DD(".earth").addSquare(0, 0, 0, 500).addTexture(DD("|earth_tile"), DD("@decor")).animateTexture(5, 0, 1, -1).drawTexture DD("!canvas")

        DD("#butterfly")._spawn = DD("#butterfly").addCycle 100, -1, =>
            node = DD.newNode()
                .addSquare(22, 27, 800, 250 + Math.floor(Math.random() * 250))
                .addTile(DD("|butterfly_tile"), DD("@img"))
                .animateTile(0, 1, false, 4, -1)
                .drawTile(DD("!canvas"))
            DD("#butterfly").add(node)
    childhood.childArrive = () ->
        DD(".child").addSquare(50, 50, -10, -110).addTile(DD("|child_tile"), DD("@img")).animateTile(0, 6, false, 4, -1)
        DD(".child").slideTo 100, 450, 20, =>
            DD(".child")._jumpYGravity = 1
            DD(".child")._jump = DD.subscribe("up",
                => DD(".child").animateTile(7, 11, true, 4, -1)
                .jumpY(-20, DD(".child")._jumpYGravity, =>
                    DD(".child").animateTile 0, 6, false, 4, -1
                )
            )
        DD(".child").drawTile DD("!canvas")
        DD("#butterfly")._move = DD("#butterfly").addCycle 1, -1, =>
            DD("#butterfly").each (elem) =>
                elem.move -2, 0
                if elem.square.xx <= 0
                    elem.killTile()
            DD("#butterfly").squareCollision(DD(".child"), (elem) =>
                elem.killTile()
            )
    childhood.cosmos = () ->
        DD("!canvas").clearEachFrame()
        DD(".btree").slideTo 800, 800, 30
        DD(".ltree").slideTo 0, -500, 30
        DD(".earth").slideTo 0, 800, 30
        DD(".sky").slideTo 0, -800, 35, =>
            DD(".sky").addTexture DD("|sky_tile"), DD("@decorSpace")
            DD(".btree").addTexture DD("|big_tree_tile"), DD("@decorSpace")
            DD(".ltree").addTexture DD("|little_tree_tile"), DD("@decorSpace")
            DD(".ltree").animateTexture 4, 0, 1, -1
            DD(".sky").animateTexture 2, 0, 1, -1
            DD(".btree").animateTexture 3, 0, 1, -1
            DD(".earth").addTexture DD("|moon_tile"), DD("@decorSpace")
            DD(".earth").animateTexture 5, 0, 1, -1
            DD(".sky").slideTo 0, 0, 40, =>
                DD(".earth").slideTo 0, 500, 40, =>
                    DD(".btree").slideTo 0, 175, 40, =>
                        DD(".ltree").slideTo 0, 353, 40, =>
                            DD(".spuf").addSquare(120, 120, 120, 120).addTile(DD("|spuf_tile"), DD("@spuf")).drawTile(DD("!canvas")).follow(DD(".child"), 0, 20).animateTile(0, 5, true, 2, 6, (=> DD.kill(".spuf")))
                            DD(".child").addTile DD("|cosmos_tile"), DD("@img")
                            DD(".child")._jumpYGravity = 0.5
                            DD("#butterfly").killCycle DD("#butterfly")._move
                            DD("#butterfly").killCycle DD("#butterfly")._spawn
                            DD.kill("#butterfly")
    childhood.veto = () ->
        DD(".btree").slideTo 800, 800, 30
        DD(".ltree").slideTo 0, -500, 30
        DD(".earth").slideTo 0, 800, 30
        DD(".sky").slideTo 0, -800, 35, =>
            DD(".sky").addTexture DD("|sky_tile"), DD("@decorVeto")
            DD(".btree").addTexture DD("|big_tree_tile"), DD("@decorVeto")
            DD(".ltree").addTexture DD("|cat_veto_tile"), DD("@decorVeto")
            DD(".ltree").animateTexture 4, 0, 1, -1
            DD(".sky").animateTexture 2, 0, 1, -1
            DD(".btree").animateTexture 3, 0, 1, -1
            DD(".earth").addTexture DD("|earth_tile"), DD("@decorVeto")
            DD(".earth").animateTexture 5, 0, 1, -1
            DD(".sky").slideTo 0, 0, 40, =>
                DD(".earth").slideTo 0, 500, 40, =>
                    DD(".btree").slideTo 0, 175, 40, =>
                        DD(".ltree").slideTo 0, 50, 40, =>
                            DD(".spuf").addSquare 120, 120, 120, 120
                            DD(".spuf").addTile DD("|spuf_tile"), DD("@spuf")
                            DD(".spuf").drawTile DD("!canvas")
                            DD(".spuf").follow DD(".child"), 2, 0, 20
                            DD(".spuf").animateTile 0, 5, true, 2, 6, => DD.kill(".spuf")
                            DD(".child").addTile DD("|veto_tile"), DD("@img")
                            DD(".child")._jumpYGravity = 1
                            DD("!canvas").stopClearEachFrame()
    childhood.childBack = () ->
        DD(".spuf").addSquare 120, 120, 120, 120
        DD(".spuf").addTile DD("|spuf_tile"), DD("@spuf")
        DD(".spuf").drawTile DD("!canvas")
        DD(".spuf").follow DD(".child"), 2, 0, 20
        DD(".spuf").animateTile 0, 5, true, 2, 6, => DD.kill(".spuf")
        DD(".child").addTile DD("|child_tile"), DD("@img")
    childhood.earthquake = () ->
        DD(".sky").stopAnimateTexture()
        DD(".btree").stopAnimateTexture()
        DD(".ltree").stopAnimateTexture()
        DD(".earth").stopAnimateTexture()
        DD.unsubscribe(DD(".child")._jump)
        DD(".sky").shake(4, 30)
        DD(".earth").shake(5, 30)
        DD(".ltree").shake(10, 30)
        DD(".btree").shake(10, 30)
        DD(".child").slideTo 400, 450, 50, =>
            DD(".child").addTile DD("|child_tile"), DD("@img")
            DD(".child").animateTile 4, 4, false, 4, 1
            DD(".child").stopAnimateTile()
            DD(".child").shake(5, 30)
    childhood.stop = () ->
        DD.kill(".btree")
        DD.kill(".ltree")
        DD.kill(".earth")
        DD.kill(".child")

    chute = () ->
        @
    chute.start = () ->
        DD(".sky").addSquare 0, 0, 0, 0
        DD(".sky").addTexture DD("|chute_sky_tile"), DD("@decorChute")
        DD(".sky").animateTexture 0, 9, 1, -1
        DD(".sky").drawTexture DD("!canvas")
        DD(".leftWall").addSquare 0, 0, 0, 0
        DD(".leftWall").addTexture DD("|chute_wall_tile"), DD("@decorChute")
        DD(".leftWall").animateTexture 0, 12, 1, -1
        DD(".leftWall").drawTexture DD("!canvas")
        DD(".rightWall").addSquare 0, 0, 800 - 78, 0
        DD(".rightWall").addTexture DD("|chute_wall_tile"), DD("@decorChute")
        DD(".rightWall").animateTexture 0, 12, 1, -1
        DD(".rightWall").drawTexture DD("!canvas")
        DD(".me").addSquare 111, 132, 300, -140
        DD(".me").addTile DD("|chute_me_tile"), DD("@decorChute")
        DD(".me").animateTile 0, 5, true, 4, -1
        DD(".me").slideTo 300, 300, 40, =>
            DD(".me").square.startFreeMove(DD("^mainEvent"), -2, 2, 2, -2, 0, 800 - 78, 600, 78)
        DD(".me").drawTile DD("!canvas")
    chute.love = () ->
        DD("#col")._addNode = () ->
            node = DD.newNode()
            node.addSquare 67, 74, 78 + Math.floor(Math.random() * 600), 650
            node.addTile DD("|chute_heart_tile"), DD("@decorChute")
            node.drawTile DD("!canvas")
            node
        DD("#col")._spawn = DD("#col").addCycle 30, -1, =>
            node = DD("#col")._addNode()
            DD("#col").add(node)
        DD("#col")._move = DD("#col").addCycle 1, -1, =>
            DD("#col").each (elem) =>
                elem.move 0, -3
                if elem.square.yy <= 0
                    elem.killTile()
            DD("#col").squareCollision(DD(".me"), (elem) =>
                elem.killTile()
            )
    chute.beer = () ->
        DD("#col")._addNode = () ->
            node = DD.newNode()
            node.addSquare 24, 74, 78 + Math.floor(Math.random() * 600), 650
            node.addTile DD("|chute_bottle_tile"), DD("@decorChute")
            node.drawTile DD("!canvas")
            node
    chute.hippie = () ->
        DD("#col")._addNode = () ->
            node = DD.newNode()
            node.addSquare 64, 64, 78 + Math.floor(Math.random() * 600), 650
            node.addTile DD("|chute_hippie_tile"), DD("@decorChute")
            node.drawTile DD("!canvas")
            node
    chute.anar = () ->
        DD("#col")._addNode = () ->
            node = DD.newNode()
            node.addSquare 73, 74, 78 + Math.floor(Math.random() * 600), 650
            node.addTile DD("|chute_anar_tile"), DD("@decorChute")
            node.drawTile DD("!canvas")
            node
    chute.coco = () ->
        DD("#col")._addNode = () ->
            node = DD.newNode()
            node.addSquare 73, 74, 78 + Math.floor(Math.random() * 600), 650
            node.addTile DD("|chute_coco_tile"), DD("@decorChute")
            node.drawTile DD("!canvas")
            node
    chute.stopCol = () ->
        DD("#col").killCycle DD("#col")._move
        DD("#col").killCycle DD("#col")._spawn
        DD.kill("#col")
    chute.end = () ->
        # DD.kill(".sky")
        DD.kill(".leftWall")
        DD.kill(".rightWall")
        DD.kill(".me")

    end = () ->
        DD("!canvas").stopClearEachFrame()
        chute.end()
        DD.stopCycle()
    text = [{
        exec: => childhood.start(),
        print: true,
        sleep: 250,
        tmpSleep: 25,
        txt: "CV César LEBLIC\n2012",
        x: 400,
        y: 300,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "60"
        },
        {
        exec: => childhood.childArrive(),
        print: false,
        sleep: 100,
        tmpSleep: 10,
        },
        {
        exec: false,
        print: true,
        sleep: 200,
        tmpSleep: 20,
        txt: "Mon enfance fût tranquille",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 200,
        tmpSleep: 20,
        txt: "comme tout les enfants,\n je revais à de bien beaux métiers.",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => childhood.cosmos(),
        print: true,
        sleep: 400,
        tmpSleep: 40,
        txt: "J'ai voulu être cosmonaute",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 150,
        tmpSleep: 15,
        txt: "ainsi que...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => childhood.veto(),
        print: true,
        sleep: 400,
        tmpSleep: 40,
        txt: "vétérinaire",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => childhood.childBack(),
        print: false,
        sleep: 150,
        tmpSleep: 40,
        txt: "",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 400,
        tmpSleep: 40,
        txt: "puis\nalors que je ne m'y attendais pas\narriva...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
            },
        {
        exec: => childhood.earthquake(),
        print: true,
        sleep: 210,
        tmpSleep: 400,
        txt: "L'ADOLESCENCE",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "70"
        },
        {
        exec: =>
            childhood.stop()
            chute.start()
        ,
        print: true,
        sleep: 120,
        tmpSleep: 400,
        txt: "L'ADOLESCENCE",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "70"
        },
        {
        exec: false
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "Je fais ma scolarité au collège Condorcet\npuis au lycée Racine",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "Je participe à la création de Prométhée:\nqui reçoit le prix\ndu meilleur journal lycéen\nen 2005",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false
        print: true,
        sleep: 160,
        tmpSleep: 400,
        txt: "A part ça\nrien de très interessant à raconter...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.love(),
        print: true,
        sleep: 300,
        tmpSleep: 400,
        txt: "J'y ai découvert l'amour ...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.beer(),
        print: true,
        sleep: 300,
        tmpSleep: 400,
        txt: "la bière ...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "J'ai été pas mal de chose...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.hippie(),
        print: true,
        sleep: 220,
        tmpSleep: 400,
        txt: "un jour hippie...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.anar(),
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "un autre anarchiste...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.coco(),
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "un autre communiste...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => chute.stopCol(),
        print: true,
        sleep: 80,
        tmpSleep: 400,
        txt: "BREF",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "70"
        },
        {
        exec: false,
        print: true,
        sleep: 180,
        tmpSleep: 400,
        txt: "C'était l'adolescence",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 110,
        tmpSleep: 400,
        txt: "Puis arriva...",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 110,
        tmpSleep: 400,
        txt: "FIN !!!\n:D",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "70"
        },
        {
        exec: false,
        print: true,
        sleep: 330,
        tmpSleep: 400,
        txt: "Je m'arrête là pour le moment,\ncar mine de rien\n ca prend du temps de dessiner\nces petites sprites\naussi moches soient-elles héhé",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: false,
        print: true,
        sleep: 110,
        tmpSleep: 400,
        txt: "Suite prochainement",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        },
        {
        exec: => end(),
        print: false,
        sleep: 110,
        tmpSleep: 400,
        txt: "",
        x: 400,
        y: 80,
        bgColor: "#fff",
        txtColor: "#000",
        fontFamily: "Changa One",
        fontSize: "40"
        }
    ]

    DD.loadImages [{name: "img", src: "img/child.png"},
        {name: "decor", src: "img/decor-child.png"},
        {name: "spuf", src: "img/spuf.png"},
        {name: "decorSpace", src: "img/decor-space.png"},
        {name: "decorVeto", src: "img/decor-veto.png"},
        {name: "decorChute", src: "img/decor-chute.png"}], =>
            DD.buildSprite [{name: "child_tile", x: 12, y: 1, w: 50, h: 110, startX: 0, startY: 0, partW: 12 * 50, partH: 110},
            {name: "cosmos_tile", x: 12, y: 1, w: 50, h: 110, startX: 0, startY: 111, partW: 12 * 50, partH: 110},
            {name: "veto_tile", x: 6, y: 2, w: 71, h: 101, startX: 0, startY: 222, partW: 6 * 71, partH: 101},
            {name: "smoke_tile", x: 6, y: 1, w: 50, h: 110, startX: 0, startY: 111, partW: 6 * 50, partH: 110},
            {name: "spuf_tile", x: 3, y: 2, w: 120, h: 120, startX: 0, startY: 0, partW: 3 * 120, partH: 2 * 120},
            {name: "butterfly_tile", x: 5, y: 1, w: 22, h: 27, startX: 0, startY: 5 * 111, partW: 5 * 22, partH: 27},
            {name: "earth_tile", w: 800, h: 138, imgW: 400, imgH: 138, startX: 0, startY: 0},
            {name: "moon_tile", w: 800, h: 138, imgW: 340, imgH: 138, startX: 0, startY: 0},
            {name: "sky_tile", w: 800, h: 500, imgW: 375, imgH: 319, startX: 0, startY: 138},
            {name: "big_tree_tile", w: 800, h: 326, imgW: 400, imgH: 326, startX: 500, startY: 0},
            {name: "little_tree_tile", w: 800, h: 149, imgW: 400, imgH: 149, startX: 500, startY: 370},
            {name: "cat_veto_tile", w: 800, h: 149, imgW: 399, imgH: 149, startX: 501, startY: 370},
            {name: "chute_sky_tile", w: 800, h: 600, imgW: 598, imgH: 389, startX: 0, startY: 0},
            {name: "chute_wall_tile", w: 78, h: 600, imgW: 78, imgH: 145, startX: 598, startY: 0},
            {name: "chute_me_tile", x: 7, y: 1, w: 111, h: 132, startX: 0, startY: 389, partW: 7 * 111, partH: 133},
            {name: "chute_bottle_tile", x: 1, y: 1, w: 24, h: 74, startX: 0, startY: 521, partW: 24, partH: 74},
            {name: "chute_heart_tile", x: 1, y: 1, w: 63, h: 74, startX: 25, startY: 521, partW: 63, partH: 74},
            {name: "chute_hippie_tile", x: 1, y: 1, w: 64, h: 64, startX: 89, startY: 521, partW: 64, partH: 64},
            {name: "chute_anar_tile", x: 1, y: 1, w: 73, h: 74, startX: 152, startY: 521, partW: 73, partH: 74},
            {name: "chute_coco_tile", x: 1, y: 1, w: 70, h: 74, startX: 224, startY: 521, partW: 70, partH: 74}], =>
                reader = new Reader text, DD("!canvas")
                reader.read()


