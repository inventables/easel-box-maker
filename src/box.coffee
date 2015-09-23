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
