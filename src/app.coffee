class Pubsub
    constructor: ->
        @cache = {}
        @type = "Pubsub"
    publish: (topic, args) ->
        if @cache[topic]
            @cache[topic].forEach (obj, i) =>
                obj.callback.apply @, args || []
    subscribe: (topic, callback, weight = 50) ->
        if not @cache[topic] then @cache[topic] = []
        elem = {}
        elem.callback = callback
        elem.weight = weight
        elem.topic = topic
        for obj, i in @cache[topic]
            if obj.weight > elem.weight
                @cache[topic].splice i, 0, elem
                return elem
        @cache[topic].push elem
        elem
    unsubscribe: (handle) ->
        name = handle.topic
        if not @cache[name] then return false
        @cache[name].forEach (obj, i) =>
            if obj.callback is handle.callback then @cache[name].splice i, 1

class Event
    constructor: (@domElem = window, @en = false) ->
        @type = "Event"
        @up = @down = @left = @right = @space = @esc = @other = @mousedown = @mouseup = false
        @domElem.addEventListener "mousedown", (e) =>
            @mousedown = true
            @mouseup = false
            DD.publish("mousedown")
        @domElem.addEventListener "mouseup", (e) =>
            @mousedown = false
            @mouseup = true
            DD.publish("mouseup")
        @domElem.addEventListener "keydown", (e) =>
            if e.keyCode isnt 116
                    e.preventDefault()
            switch e.keyCode
                when 38 or 90 then @up = true; DD.publish("up")
                when 40 or 83 then @down = true; DD.publish("down")
                when 37 or 81 then @left = true; DD.publish("left")
                when 39 or 68 then @right = true; DD.publish("right")
                when 32 then @space = true; DD.publish("space")
                when 27 then @esc = true; DD.publish("esc")
                else @other = true; DD.publish("other")
        @domElem.addEventListener "keyup", (e) =>
            e.preventDefault() if e.keyCode isnt 116
            switch e.keyCode
                when 38 or 90 then @up = false
                when 40 or 83 then @down = false
                when 37 or 81 then @left = false
                when 39 or 68 then @right = false
                when 32 then @space = false
                when 27 then @esc = false
        @
    is: (touch) ->
        if @[touch] then @[touch] else false

class Canvas
    constructor: (@canvasId = "canvas", @w = 800, @h = 600) ->
        @type = "Canvas"
        @subHandler = DD.subscribe("raf:frame:tick", (=> @clear()), 0)
        tmpCanvas = document.getElementById @canvasId
        if tmpCanvas then @canvas = tmpCanvas else
            @canvas = document.createElement("canvas")
            document.getElementsByTagName("body")[0].appendChild @canvas
        @ctx = @canvas?.getContext "2d"
        @fillStyle = "#000"
        @strokeStyle = "#000"
        @text_cache_canvas = document.createElement("canvas")
        @text_cache_canvas.width = @w
        @text_cache_canvas.height = @h
        @text_cache = @text_cache_canvas.getContext "2d"
        @text_cache.textAlign = "center"
        @transX = @transY = 0
        @z = 1
        @setSize()
    domElem: () ->
        @canvas
    splitText: (text) ->
        res = text.split "\n"
        res
    setSize: (@w = @w, @h = @h) ->
        @canvas.width = @w
        @canvas.height = @h
        @
    clear: (x = 0, y = 0, w = @w, h = @h) ->
        if @clrAll then @ctx.clearRect x, y, w, h
    setFillStyle: (@fillStyle = @fillStyle) ->
        @ctx.fillStyle = @fillStyle
    setStrokeStyle: (@strokeStyle = @strokeStyle) ->
        @ctx.strokeStyle = @strokeStyle
    setOpacity: (@globalAlpha = 1) ->
        @ctx.globalAlpha = @globalAlpha
    printImg: (@_img = null,
            x = 0, y = 0,
            w = @_img?.width,
            h = @_img?.height,
            imgX = 0,
            imgY = 0,
            imgW = @_img?.width,
            imgH = @_img?.height) ->
        if not @_img
            return false
        @ctx.drawImage(@_img, imgX, imgY, imgW, imgH, (x + @transX) * @z, (y + @transY) * @z, w * @z, h * @z)
    destroy: ->
        @canvas.parentNode.removeChild(@canvas)
    clearEachFrame: ->
        @clrAll = true
    stopClearEachFrame: ->
        @clrAll = false
    printText: (data, refresh = false) ->
        if (refresh)
            text = @splitText data.txt
            @text_cache.clearRect 0, 0, @w, @h
            width = 0
            for val in text
                tmp = @text_cache.measureText val
                if tmp.width > width then width = tmp.width
            height = data.fontSize * (text.length - 1)
            @text_cache.globalAlpha = 0.5
            @text_cache.font = data.fontSize + "px " + data.fontFamily
            @text_cache.fillStyle = data.bgColor
            @text_cache.fillRect(
                data.x - width / 2 - data.fontSize,
                data.y,
                width + data.fontSize * 2,
                height + data.fontSize * 2
            )
            @text_cache.globalAlpha = 1
            @text_cache.fillStyle = data.txtColor
            for val, ind in text
                @text_cache.fillText val, data.x, data.y + (ind + 1) * data.fontSize
        @ctx.drawImage @text_cache_canvas, 0, 0
    vecSimplify: (x, y, speed) ->
        {x: (x / speed) >> 0, y: (y / speed) >> 0}
    slideTo: (x, y, speed, callback = false) ->
        if @slideAnimation then @slideAnimation.stop()
        @absCenterX = @w / 2
        @absCenterY = @h / 2
        if not @x or not @y
            @x = @w / 2
            @y = @h / 2
        if not @transX or not @transY then @transX = @transY = 0
        @clearEachFrame()
        @vec = @vecSimplify(-x + @absCenterX - @x, -y + @absCenterY - @y, speed)
        @slideAnimation = new Update(1, speed, (() => @updateSlideAnimation()), (() => callback?()))
    updateSlideAnimation: () ->
        @x += @vec.x
        @y += @vec.y
        @transX += @vec.x
        @transY += @vec.y
    zoomTo: (x, y, z, speed, callback = false) ->
        if @zoomAnimation then @zoomAnimation.stop()
        @absZ = 1
        @slideTo x, y, speed
        @vecZ = (z - 1 + @absZ - @z) / speed
        @zoomAnimation = new Update(1, speed, (() => @updateZoomAnimation()), (() => callback?()))
    updateZoomAnimation: () ->
        @z += @vecZ
    fullScreen: (active = true) ->
        if active
            @canvas.style.height = window.innerHeight + 'px';
            @_resizeFullScreenFn = =>
                @canvas.style.height = window.innerHeight + 'px';
            window.addEventListener "resize", @_resizeFullScreenFn, false
        else
            @canvas.style.height = @canvas.h + 'px';
            @canvas.style.width = @canvas.w + 'px';
            window.removeEventListener "resize", @_resizeFullScreenFn, false
        @

class Update
    constructor: (@tickRate = 60, @expiration = -1, @callback, @callbackEnd, index) ->
        @type = "Update"
        @elapsed = 0
        @turn = 0
        @active = false
        @ended = false
        @start(index)
        @
    start: (index) ->
        @active = true
        @subHandler = DD.subscribe("raf:frame:tick", (=> @step()), index)
    step: ->
        @elapsed++
        @totalElapsed += @elapsed
        if @elapsed >= @tickRate
            @elapsed = 0
            @turn++
            @callback?()
        if @turn >= @expiration and @expiration > 0
            @callbackEnd?()
            @ended = true
            @stop()
    stop: ->
        if @subHandler then DD.unsubscribe(@subHandler)
        @active = false

class Tile
    constructor: (@_plain, @img) ->
        @type = "Tile"
        @animationName = false
        @update(@_plain, @img)
    update: (@_plain, @img) ->
        for key, val of @_plain
            @[key] = val
        @coords = []
        y = 0
        while y < @y
            x = 0
            while x < @x
                val = {
                    x: x * @w + @startX
                    y: y * @h + @startY
                    w: @w
                    h: @h
                    }
                @coords.push(val)
                x++
            y++
        @frameIndex = 0
    animate: (@from, @to, @circular, @frameRate, @expiration, callback) ->
        if @from < 0 or @to > @x * @y - 1 then return false
        if @anim then @stopAnimate()
        @frameIndex = @from
        @direction = 1
        @anim = new Update(@frameRate, @expiration * (@to - @from), (() => @updateAnimation()), (() => callback?()))
    stopAnimate: () ->
        @anim?.stop()
    updateAnimation: () ->
        @frameIndex += @direction
        if @circular
            if @frameIndex > @to
                @frameIndex = @to - 1
                @direction = -1
            else if @frameIndex < @from
                @frameIndex = @from + 1
                @direction = 1
        else if @frameIndex > @to
                @frameIndex = @from
        @

class Texture
    constructor: (@_plain, @img) ->
        @type = "Texture"
        @animationName = false
        @update(@_plain, @img)
    update: (@_plain, @img) ->
        @x = 0
        @y = 0
        for key, val of @_plain
            @[key] = val
        @coords = []
        @calc()
        y = 0
        while y < @y
            x = 0
            while x < @x
                val = {
                    x: x * @w + @startX
                    y: y * @h + @startY
                    w: @w
                    h: @h
                    }
                @coords.push(val)
                x++
            y++
        @frameIndex = 0
    buildPart: (x, y) ->
        part = {
            x: x,
            y: y,
            xx: (@stretchW or @imgW) + (x - @w),
            yy: (@stretchH or @imgH) + y,
            img: @img}
        @col.push part
    calc: ->
        @col = []
        if @x < 0 then @sx = -1 else @sx = 1
        if @y < 0 then @sy = -1 else @sy = 1
        y = 0
        while Math.abs(y * (@stretchH or @imgH) - Math.abs(@y)) < @h
            x = 0
            while Math.abs(x * (@stretchW or @imgW) - Math.abs(@x)) < @w
                @buildPart (x * @sx) * (@stretchW or @imgW) - @x, (y * @sy) * (@stretchW or @imgH) - @y
                x++
            y++

    animate: (@vx, @vy, @speed, @expiration, @canvas, callback) ->
        if @anim then @anim.stop()
        @anim = new Update(@speed, -1, (() => @updateAnimation()), (() => callback?()))

    stopAnimate: () ->
        @anim?.stop()
    updateAnimation: () ->
        @x += @vx >> 0
        @y += @vy >> 0
        if Math.abs(@x) >= (@stretchW or @imgW) then @x = (- ((@stretchW or @imgW) - Math.abs(@x)) )
        if Math.abs(@y) >= (@stretchW or @imgH) then @y = (- ((@stretchW or @imgH) - Math.abs(@y)) )
        @calc()

class Square
    constructor: (@w, @h, @x, @y) ->
        @type = "Square"
        @resize(@w, @h)
        @
    resize: (@w, @h) ->
        @xx = @x + @w
        @yy = @y + @h
        @hw = @w / 2
        @hh = @h / 2
    moveTo: (@x, @y) ->
        @xx = @x + @w
        @yy = @y + @h
        @moveFollowers()
        @
    move: (x, y) ->
        @x += x
        @y += y
        @xx += x
        @yy += y
        @moveFollowers()
        @
    moveToX: (@x) ->
        @xx = @x + @w
        @moveFollowers()
        @
    moveToY: (@y) ->
        @yy = @y + @h
        @moveFollowers()
        @
    moveX: (x) ->
        @x += x
        @xx += x
        @moveFollowers()
        @
    moveY: (y) ->
        @y += y
        @yy += y
        @moveFollowers()
        @
    moveCenter: (x, y) ->
        @x = x - @hw
        @y = y - @hh
        @xx = x + @hw
        @yy = y + @hh
        @moveFollowers()
    moveFollowers: () ->
        if not @followers or @followers.length is 0 then return @
        @followers.forEach((elem) =>
            @moveFollower(elem)
        )
        @
    moveFollower: (elem) ->
        elem.moveCenter(@x + @hw + elem._xIndent, @y + @hh + elem._yIndent)
        @
    vecSimplify: (x, y, speed) ->
        {x: (x / speed) >> 0, y: (y / speed) >> 0}
    slideTo: (x, y, speed, callback = false) ->
        if @slideAnimation then @slideAnimation.stop()
        @vec = @vecSimplify(x - @x, y - @y, speed)
        backToStart = () =>
            @moveTo x, y
            callback?()
        @slideAnimation = new Update(1, speed, (() => @updateAnimation()), (() => backToStart()))
    jumpY: (force, gravity, callback, originalY = @y) ->
        @jumpingY = true
        @slideTo @x, @y + force, 2, =>
            force += gravity
            if @y > originalY
                @moveToY originalY
                @jumpingY = false
                if callback then callback()
            else
                @jumpY force, gravity, callback, originalY
        @
    updateAnimation: () ->
        @x += @vec.x
        @y += @vec.y
        @xx += @vec.x
        @yy += @vec.y
    shake: (intensity, length, x = @x, y = @y, bin = 0, callback) ->
        dirx = if bin is 1 then x else @x + (intensity * -1) + (Math.random() * intensity)
        diry = if bin is 1 then y else @y + (intensity * -1) + (Math.random() * intensity)
        if length is 0
            @slideTo x, y, 2
            if callback then => callback()
        else
            @slideTo dirx, diry, 2
        if (length > 0)
            bin = if bin is 0 then 1 else 0
            setTimeout (=> @shake(intensity, length - 1, x, y, bin, callback)), 100
    sqCollision: (sq) ->
        if not sq then return false
        if not (@x > sq.xx or @xx < sq.x or @y > sq.yy or @yy < sq.y)
            return true
        false
    stopAnimate: () ->
        @slideAnimation?.stop()
    startFreeMove: (e, up, right, down, left, U, R, D, L, max = 10, callback) ->
        @freeMoveAnimation = new Update(1, -1, (() => freeMove()), false)
        vx = vy = 0
        i = 0
        freeMove = () =>
            i++
            if i % 10 is 0
                if e.up and Math.abs(vy) < max then vy += up
                if e.right and Math.abs(vx) < max then vx += right
                if e.down and Math.abs(vy) < max then vy += down
                if e.left and Math.abs(vx) < max then vx += left
            if i > 100 then i = 0
            if @x < L then @moveToX(L) ; vx *= -0.5
            if @xx > R then @moveToX(R - @w) ; vx *= -0.5
            if @y < U then @moveToY(U) ; vy *= -0.5
            if @yy > D then @moveToY(D - @h) ; vy *= -0.5
            @move(vx, vy)
            callback?()
    follow: (node, xIndent, yIndent) ->
        @following = node
        node.addFollower(@, xIndent, yIndent)
        @
    addFollower: (node, xIndent, yIndent) ->
        if not @followers then @followers = [] else if @followers.indexOf(node) isnt -1 then return @
        node._xIndent = xIndent
        node._yIndent = yIndent
        @followers.push node
        @moveFollower node
        if not node.following then node.follow()
        @
    removeFollower: (node) ->
        if not @followers or @followers.indexOf(node) is -1 then return @
        node.following = false
        @followers.splice(@followers.indexOf(node), 1)
        @
    unfollow: () ->
        if not @following then return @
        @following.removeFollower(@)
        @following = false
        @
class Node
    constructor: (@name) ->
        @type = "Node"
        @tile = @texture = @square = false
        @
    addTile: (_plain, img) ->
        if not @tile then @tile = new Tile(_plain, img) else
            @tile.update _plain, img
        @
    addTexture: (_plain, img) ->
        if not @texture then @texture = new Texture(_plain, img) else
            @texture.update _plain, img
        @
    killTile: () ->
        @_drawTile?.stop()
        delete @tile
    killAllTile: () ->
        @_drawTile?.stop()
        @tile?.stopAnimate()
        delete @tile
    killTexture: () ->
        @_drawTexture?.stop()
        @texture?.stopAnimate()
        delete @texture
    killSquare: () ->
        @squre?.unfollow()
        @square?.stopAnimate()
        delete @square
    kill: () ->
        if @tile then @killTile()
        if @texture then @killTexture()
        if @square then @killSquare()
        @followRun?.stop()
    killAll: () ->
        if @tile then @killAllTile()
        if @texture then @killTexture()
        if @square then @killSquare()
        @followRun?.stop()
    animateTile: (from, to, circular, frameRate, expiration, callback = false) ->
        @tile.animate(from, to, circular, frameRate, expiration, callback)
        @
    animateTexture: (x, y, speed, expiration) ->
        @texture.animate(x, y, speed, expiration)
        @
    stopAnimateTile: () ->
        @tile.stopAnimate()
        @
    stopAnimateTexture: () ->
        @texture.stopAnimate()
        @
    addSquare: (w = 0, h = 0, x = 0, y = 0) ->
        @square = new Square w, h, x, y
        @
    drawTile: (canvas, zindex) ->
        @_drawTile = new Update(1, -1, (() => @drawImgSquare(canvas, @tile, @square)))
        @
    drawTexture: (canvas, zindex) ->
        @_drawTexture = new Update(1, -1, (() => @drawImgColSquare(canvas, @texture, @square)), null, zindex)
        @
    drawImgColSquare: (canvas, texture, square) ->
        i = 0
        col = texture.col
        while (col[i])
            canvas.printImg(texture.img,
                col[i].x + @square.x, col[i].y + @square.y,
                texture.stretchW or texture.imgW, texture.stretchH or texture.imgH,
                texture.startX, texture.startY,
                texture.imgW, texture.imgH
                )
            i++
        @
    drawImgSquare: (canvas, tile, square) ->
        canvas.printImg(tile.img,
                square.x, square.y,
                tile.stretchW or tile.coords[tile.frameIndex].w,
                tile.stretchH or tile.coords[tile.frameIndex].h,
                tile.coords[tile.frameIndex].x,
                tile.coords[tile.frameIndex].y,
                tile.coords[tile.frameIndex].w,
                tile.coords[tile.frameIndex].h)
        @
    slideTo: (x, y, time, callback) ->
        @square.slideTo(x, y, time, callback)
        @
    move: (x, y) ->
        @square.move x, y
    moveTo: (x, y) ->
        @square.moveTo x, y
    shake: (intensity, length, callback) ->
        @square.shake(intensity, length, null, null, null, callback)
    jumpY: (force, gravity, callback) ->
        if @square?.jumpingY then return false
        @square?.jumpY force, gravity, callback
        @
    resize: (w, h) ->
        @square?.resize(w, h)
        @
    moveCenter: (x, y) ->
        @square?.moveCenter x, y
    follow: (node = false, xIndent = 0, yIndent = 0) ->
        if not node or not node.square or not @square then return false
        @square?.follow(node.square, xIndent, yIndent)
        @
    unfollow: () ->
        @square?.unfollow()
        @
class Collection
    constructor: (@name) ->
        @type = "Collection"
        @col = []
        @
    add: (objects...) ->
        for obj in objects
            @col.push obj
    addCycle: (time = 60, expiration, callback) ->
        new Update(time, expiration, (() => callback?(@)))
    killCycle: (name) ->
        name.stop()
    squareCollision: (node, callback) ->
        if not node or not node.square then return @
        @col.forEach (obj) =>
            if obj?.square?.sqCollision node.square
                callback(obj, @)
    each: (callback) ->
        @col.forEach (obj) =>
            callback(obj, @)
    emptyTrash: (c = @_trash) ->
        if not @_trash then return @
        for elem in c.col
            for src in @col
                if src is elem then @trash(src)
        c.killAll()
        @
    addToTrash: (elem) ->
        if not @_trash then @_trash = new Collection()
        @_trash?.add(elem)
    killAll: () ->
        @each (elem) =>
            elem.kill()
        @col = []
    trash: (elem) ->
        i = 0
        while @col[i]
            if @col[i] is elem
                @col.splice i, 1
                return true
            i++
        false

class Reader
    constructor: (@data, @canvas) ->
        @type = "Reader"
        @i = 0
        @
    next: () ->
        @i++
        if @data[@i] then @read()
    print: () ->
        @canvas.printText(@data[@i], true)
    sleep: (time) ->
        sleeping = () =>
            if @data[@i].print then @print()
        @_sleep = new Update 1, time, (() => sleeping()), (() => @next())
    read: () ->
        if @data[@i].exec then @data[@i].exec()
        @sleep @data[@i].sleep

((document) ->
    _name = "2dGameLib"
    _global = @
    _oldDD = _global.DD

    _cycleRunning = false
    _pubsub = new Pubsub()

    COL_node = {}
    COL_img = {}
    COL_ctx = {}
    COL_evt = {}
    COL_col = {}
    COL_spt = {}




    parseSelectors = (sel, params) ->
        sel = sel.split(" ").join("")
        sel = sel.split(",")
        if sel.len > 1
            return filterSelectorsCollection(sel, params)
        else
            return filterSelector(sel[0], params)
    filterSelectorsCollection = (sel, params) ->
        console.log "filterSelectorsCollection", sel, sel.length
        sel
    filterSelector = (sel, params) ->
        l = sel[0]
        sel = sel.slice(1, sel.length)
        if l is '!'
            gsCtx(sel, params)
        else if l is '^'
            gsEvt(sel, params)
        else if l is '.'
            gsNode(sel, params)
        else if l is '@'
            gImg(sel)
        else if l is '#'
            gsCol(sel, params)
        else if l is '|'
            gSpt(sel)


    #
    # DD("!name", ["canvasId", 500, 600])
    #
    gsCtx = (name, params) ->
        if not COL_ctx[name]
            COL_ctx[name] = new Canvas();
            Canvas.apply(COL_ctx[name], params)
        COL_ctx[name]
    gsEvt = (name, params) ->
        if not COL_evt[name]
            COL_evt[name] = new Event();
            Event.apply(COL_evt[name], params)
        COL_evt[name]
    gsNode = (name, params) ->
        if not COL_node[name]
            COL_node[name] = new Node(name);
        COL_node[name]
    gImg = (name) ->
        COL_img[name]
    gsCol = (name, params) ->
        if not COL_col[name]
            COL_col[name] = new Collection(name);
        COL_col[name]
    gSpt = (name) ->
        COL_spt[name]

    cycle = ->
        DD.publish("raf:frame:tick")
    imgLoader = (src, callback, args...) ->
        img = new Image()
        if src then img.src = src else img.src = "missing.png"
        img.addEventListener "load", (e) =>
            callback?()
        return img

    facade = (selectors, params) ->
        p = Array.prototype.slice.call(arguments);
        p.splice 0, 1
        if @ isnt document then return facade.selector(selectors, p)
        return facade

    ####### loadImages
    facade.loadImages = (collection, callback) ->
        facade.loadImage collection, 0, callback
    ####### loadImage
    facade.loadImage = (collection, index, callback) ->
        COL_img[collection[index].name] = imgLoader collection[index].src, => if collection[++index] then facade.loadImage(collection, index, callback) else callback()
    ####### cycle
    facade.stopCycle = (isStats = false) ->
        _cycleRunning = false
        @
    facade.startCycle = (isStats = false) ->
        _cycleRunning = true
        if isStats
            stats = new Stats()
            stats.setMode 0
            stats.domElement.style.position = "absolute"
            stats.domElement.style.left = "0px"
            stats.domElement.style.top = "0px"
            document.body.appendChild stats.domElement
        anim = =>
            if isStats then stats.begin();
            if _cycleRunning then requestAnimFrame(anim)
            cycle()
            if isStats then stats.end();
        anim()
    ######## pubsub
    facade.subscribe = -> _pubsub.subscribe.apply(_pubsub, arguments)
    facade.publish = -> _pubsub.publish.apply(_pubsub, arguments)
    facade.unsubscribe = -> _pubsub.unsubscribe.apply(_pubsub, arguments)
    ######## selector
    facade.selector = (selectors, params) ->
        if selectors and typeof selectors is "string" then return parseSelectors(selectors, params)
    ######## kill
    facade.kill = (selectors) ->
        if selectors and typeof selectors is "string"
            col = parseSelectors(selectors)
            col.killAll()
            if col.type is "Canvas"
                delete COL_ctx[name]
            else if col.type is "Event"
                delete COL_evt[name]
            else if col.type is "Node"
                delete COL_node[name]
            else if col.type is "Image"
                delete COL_img[name]
            else if col.type is "Collection"
                delete COL_col[name]

    ######## newNode
    facade.newNode = () ->
        new Node()
    facade.buildSprite = (list, callback, index = 0) ->
        COL_spt[list[index].name] = list[index]
        if list[++index]
            facade.buildSprite(list, callback, index)
        else if callback
            callback()
    _global.DD = _global[_name] = facade
)(document)
