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
