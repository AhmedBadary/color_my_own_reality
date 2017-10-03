# THIS IS THE CURRENT COFFEESCRIPT
# GRADIENT CORRECTLY IMPLEMENTED

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require underscore
#= require hammer
#= require paper-full

class window.ColoringInteraction
    @COLORING_PAGE: "/coloringpages/hunter.svg"
    # @COLORING_PAGE: "/coloringpages/draw_rect_trial3.svg"
    constructor: (options)->
        this.drag = false
        this.gradNum = 2
        scope = this
        Utility.paperSetup "paperCanvas"
        # SETUP COLOR PALETTE
        window.cp = new ColorPalette
            container: $("#color-palette")
        
        this.cpGC = window.cp
        # IMPORT COLORING PAGE
        paper.project.importSVG ColoringInteraction.COLORING_PAGE, (svg)->
            svg.position = paper.view.center
            
            # COMMENT OUT ONE OF THESE TO TOGGLE BETWEEN INTERACTIONS
            scope.myGradientInteraction()
            # scope.myCustomInteraction()
            # scope.myCustomInteraction_rect()

    myGradientInteraction: ()->     
        console.log "IN GRADIENT"
        hitOptions = 
            segments: false
            stroke: false
            fill: true
            tolerance: 5
        tempGradNum = this.gradNum
        console.log("temp", tempGradNum)
            
        # Tool Definition
        window.t = new paper.Tool
        t.myActivePath = null
        t.minDistance = 10

        # Gradient Definition
        stops = [['yellow'],['red'],['green'],['blue']]
        gradient = new Gradient(stops, false)
        gradientColor = new Color(gradient, 400, 400)
        
        # Interaction Definition
        t.onMouseDown =  (event)->
            hitResult = paper.project.hitTest(event.point, hitOptions)
            if not hitResult then return
            _.each hitResult, (hit)->
                if hit.fillColor and hit.fillColor.equals("black") then return;
                hit.fillColor = cp.currentColor()
                t.myActivePath = hit
        # Interaction Selection
        if this.drag == true
            t.onMouseDown =  (event)->
                hitResult = paper.project.hitTest(event.point, hitOptions)
                if not hitResult then return
                _.each hitResult, (hit)->
                    if hit.fillColor and hit.fillColor.equals("black") then return;
                    hit.fillColor = gradientColor
                    t.myActivePath = hit
            t.onMouseDrag = (event) ->
                if cp.history.length > tempGradNum
                    i = cp.history.length - 2
                    ss = [cp.history[i + 1]]
                    while i >= cp.history.length - tempGradNum
                        ss.push cp.history[i]
                        i--
                    gradient = new Gradient(ss, false)
                gradientColor = new Color(gradient, event.downPoint, event.point)
                t.onMouseDown event
                
        if this.drag == false
            console.log("er1:", cp.history.length)
            console.log("er2:", tempGradNum)
            console.log("er3:", cp.history.length-tempGradNum)
            console.log("FALSE")
            t.onMouseUp =  (event)->
                last = event.downPoint
                curr = event.point
                if last.equals(curr)
                    return
                if cp.history.length > tempGradNum
                    i = cp.history.length - 2
                    ss = [cp.history[i + 1]]
                    while i >= cp.history.length - tempGradNum
                        ss.push cp.history[i]
                        i--
                    gradient = new Gradient(ss, false)
                gradientColor = new Color(gradient, last, curr)
                t.myActivePath.fillColor = gradientColor
                
        window.t.activate()

    defaultInteraction: ()->     
        hitOptions = 
            segments: false
            stroke: false
            fill: true
            tolerance: 5
            
        # IMPLEMENT GRADIENT COLOR HERE
        window.t = new paper.Tool
        t.minDistance = 10
        t.onMouseDown =  (event)->
            hitResult = paper.project.hitTest(event.point, hitOptions)
            if not hitResult then return
            
            _.each hitResult, (hit)->
                # DON'T COLOR THE BLACK LINES
                if hit.fillColor and hit.fillColor.equals("black") then return;
                console.log("curCol: ", cp.currentColor())
                hit.fillColor = cp.currentColor()
        window.t.activate()

    myCustomInteraction: ()-> 
        console.log "IN CUSTOM"
        path = undefined
            
        # IMPLEMENT GRADIENT COLOR HERE
        window.t = new paper.Tool
        t.onMouseDown =  (event)->
            path = new Path
            path.strokeColor = 'black'
            path.add event.point
               
        t.onMouseDrag =  (event)->
            path.add event.point
            
        t.onMouseUp =  (event)->
            # path.selected = false
            path.fillColor = 'white'
            path.strokeColor = null
            
        window.t.activate()
        
    myCustomInteraction_rect: ()-> 
        console.log "IN CUSTOM RECT"
        path = undefined
        rectangle = undefined
        size = undefined
            
        # IMPLEMENT GRADIENT COLOR HERE
        window.t = new paper.Tool
        t.onMouseDown =  (event)->
            rectangle = new paper.Rectangle(event.point.x, event.point.y, 1, 1)
               
        t.onMouseDrag =  (event)->
            tempDelta = new paper.Size(event.delta)
            rectangle.size.width += tempDelta.width
            rectangle.size.height += tempDelta.height
            path = new paper.Path.Rectangle(rectangle)
            path.strokeColor = 'black'
            path.removeOnDrag()
            last = event.downPoint
            curr = event.point
            
        t.onMouseUp =  (event)->
            # path.selected = false
            path.fillColor = 'white'
            path.strokeColor = null
            
        window.t.activate()
        
    

# COLOR PALETTE OBJECT - NO NEED TO TOUCH
class window.ColorPalette
    @HUES: 32
    constructor: (options)->
        _.extend this, options
        @history = [new paper.Color("yellow"), new paper.Color("blue")]
        @init()
    init: ->
        scope = this
        hues = _.range(0, 360, 360/ColorPalette.HUES)
        hues = _.map hues, (hue)->
            h = new paper.Color "red"
            h.hue = hue
            return h
        hues = _.flatten [new paper.Color("white"), hues, new paper.Color("brown")]
        _.each hues, (hue, i)->
            swatch = $("<span>").addClass("swatch").css("background", hue.toCSS())
                                .click ()->
                                    scope.history.push new paper.Color rgb2hex($(this).css('background'))
                                    $(this).addClass('active').siblings().removeClass('active')
            if i == 0 then $(this).addClass('active')
            scope.container.append(swatch)
    currentColor: ->
        return @history[@history.length - 1]
    lastColor: ->
        return @history[@history.length - 2]