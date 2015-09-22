Utils = do ->
  translate: (x, y, pointArray) ->
    for point in pointArray
      [point[0] + x, point[1] + y]

  rotate: (angle, pointArray) ->
    for point in pointArray
      [
        point[0] * Math.cos(angle) - point[1] * Math.sin(angle)
        point[0] * Math.sin(angle) + point[1] * Math.cos(angle)
      ]

  flatten: (arr) ->
    arr.reduce (collector, subarr) -> collector.concat(subarr)

Box = (params) ->
  tabSizes = (length, tabLength) ->
    segments =  Math.floor(Math.floor(length / tabLength) / 2) * 2 + 1

    {
      tabSize: length / segments
      gapSize: length / segments
      tabCount: segments
    }

  side = (length, tabLength, tabOffset, tabStart, tabLeft, tabRight) ->
    {tabSize, gapSize, tabCount} = tabSizes(length, tabLength)
    segments = for index in [0...tabCount]
      startX = tabSize * index
      endX = tabSize * (index + 1)

      if index is 0 and not tabLeft
        startX += tabOffset
      else if index is (tabCount - 1) and not tabRight
        endX -= tabOffset

      y = tabOffset * ((index % 2 isnt 0) is tabStart)

      [
        [startX, y]
        [endX, y]
      ]

    Utils.flatten segments

  panel = (width, height, tabLength, tabOffset, tabs) ->
    {flatten, translate, rotate} = Utils
    flatten [
      side(width, tabLength, tabOffset, tabs.bottom, tabs.left, tabs.right)
      translate(width, 0, rotate(Math.PI / 2, side(height, tabLength, tabOffset, tabs.right, tabs.bottom, tabs.top)))
      translate(width, height, rotate(Math.PI, side(width, tabLength, tabOffset, tabs.top, tabs.right, tabs.left)))
      translate(0, height, rotate(3 * Math.PI / 2, side(height, tabLength, tabOffset, tabs.left, tabs.top, tabs.bottom)))
    ]

  xy = ->
    xyTabs =
      top: true, bottom: true
      left: true, right: true
    panel(params.x, params.y, params.tabLength, params.tabOffset, xyTabs)

  xz = ->
    xzTabs =
      top: false, bottom: false
      left: true, right: true
    panel(params.x, params.z, params.tabLength, params.tabOffset, xzTabs)

  yz = ->
    yzTabs =
      top: false, bottom: false
      left: false, right: false
    panel(params.y, params.z, params.tabLength, params.tabOffset, yzTabs)

  {
    xy
    xz
    yz
  }

###
  App stuff: properties array and executor function
###
properties = [
  {id: "Width", type: "range", value: 4, min: 0, max: 10, step: 0.1}
  {id: "Height", type: "range", value: 3, min: 0, max: 10, step: 0.1}
  {id: "Depth", type: "range", value: 5, min: 0, max: 10, step: 0.1}
  {id: "Tab Length", type: "range", value: 0.75, min: 0, max: 2, step: 0.1}
  {id: "Material Thickness", type: "range", value: 0.25, min: 0, max: 0.5, step: 0.01}
]

executor = (params, success, failure) ->
  inputs = params[0]

  x = inputs["Width"]
  y = inputs["Height"]
  z = inputs["Depth"]
  tabLength = inputs["Tab Length"]
  tabOffset = inputs["Material Thickness"]

  box = Box({x, y, z, tabLength, tabOffset})

  width = Math.ceil(2 * x + 2 * y + 4 * tabOffset)
  height = Math.ceil(2 * y + 2 * z + 4 * tabOffset)
  svg = SVG.root(width, height)

  thinPolygon = (points) ->
    SVG.element('polygon', {points: points, fill: 'none', stroke: '#000', 'stroke-width': 0.01})

  xy = thinPolygon box.xy()
  svg.children.push xy
  svg.children.push SVG.translate(0, y + tabOffset, xy)

  xz = SVG.translate 0, 2 * y + 2 * tabOffset, thinPolygon(box.xz())
  svg.children.push xz
  svg.children.push SVG.translate(0, z + tabOffset, xz)

  yz = SVG.translate x + z + tabOffset, 0, SVG.rotate(90, thinPolygon(box.yz()))
  svg.children.push yz
  svg.children.push SVG.translate(0, y + tabOffset, yz)

  success(SVG.render(svg))

###
  For testing, mimic a call to executor using the default properties
  Only run if this file is being run directly (i.e. require.main === module)
###

if module? and require?.main is module
  onSuccess = (output) -> console.log(output)
  params = {}
  for prop in properties
    params[prop.id] = prop.value
  executor([params], onSuccess)
