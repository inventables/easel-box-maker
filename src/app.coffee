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
