SVG = do ->
  propertyValue = (value) ->
    if value.map
      value.map(propertyValue).join(" ")
    else
      if value.toFixed
        value.toFixed(5)
      else
        value + ""

  properties = (obj) ->
    for key, value of obj
      "#{key}=\"#{propertyValue(value)}\""

  render = (element) ->
    "<#{element.tag} #{properties(element.props).join(" ")}>#{element.children.map(render).join(" ")}</#{element.tag}>"

  element = (tag, props={}, children=[]) ->
    tag: tag
    props: props
    children: children

  root = (width, height, units="in") ->
    element('svg', {width: width + units, height: height + units, viewBox: "0 0 #{width} #{height}"})

  translate = (x, y, el) ->
    element('g', {transform: "translate(#{x} #{y})"}, [el])

  rotate = (degrees, el) ->
    element('g', {transform: "rotate(#{degrees})"}, [el])

  scale = (x, y, el) ->
    element('g', {transform: "scale(#{x} #{y})"}, [el])


  {
    element
    root
    translate
    rotate
    scale
    render
  }
