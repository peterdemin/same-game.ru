jQuery ->
  SIDE = 20

  render_cell = _.template("""
    <div class="cell" data-x=<%= x %> data-y=<%= y %>></div>
  """)

  matrix = ($wrapper) ->
    for y in [0..4]
      for x in [0..4]
        $wrapper.append(render_cell(x: x, y: y))
    $wrapper.find(".cell").each((idx, elem) ->
      $elem = $(elem)
      $elem.css('left', $elem.data('x') * SIDE + '%')
           .css('top', $elem.data('y') * SIDE + '%')
      if $elem.data('x') == $elem.data('y')
        $elem.addClass('correct')
    )
    $wrapper

  cell_clicked = (e) ->
    $cell = $ this
    $cell.off 'click', cell_clicked
    flip_cell $cell, -> $cell.addClass 'selected'

  flip_cell = ($cell, middle) ->
      $cell.transition
        rotateY: 90
        duration: 250
        easing: 'linear'
        complete: middle
      .transition
        rotateY: 180
        duration: 250
        easing: 'linear'
      .transition
        rotateY: 0
        duration: 0


  preview = ($matrix, callback) ->
    $matrix.addClass("preview")
    $correct = $matrix.find('.correct')
    $correct.each((idx, elem) ->
      $cell = $(elem)
      flip_cell $cell, -> $cell.addClass 'selected'
    )
    setTimeout(
      ->
        $correct.each((idx, elem) ->
          $cell = $(elem)
          flip_cell $cell, -> $cell.removeClass 'selected'
        )
        $matrix.removeClass("preview")
        callback?($matrix)
      3000
    )

  start = ($matrix) ->
    $matrix.find(".cell").click(cell_clicked)

  $(".matrix").each (idx, elem) ->
    $matrix = matrix($ elem)
    setTimeout(
      -> preview($matrix, start)
      1000
    )
