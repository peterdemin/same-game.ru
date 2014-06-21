jQuery ->
  CELL_SIZE = 72

  the_wrapper = null
  width = 4
  height = 4

  render_cell = _.template("""
    <div class="cell" data-x=<%= x %> data-y=<%= y %>></div>
  """)

  matrix = ($wrapper) ->
    the_wrapper = $wrapper
    order = []
    for y in [0..width-1]
      for x in [0..height-1]
        $wrapper.append(render_cell(x: x, y: y))
        order.push(x + y*width)
    correct_idxs = shuffle(order).slice(0, width*height/3)
    $wrapper.find(".cell").each((idx, elem) ->
      $elem = $(elem)
      $elem.css('left', $elem.data('x') * CELL_SIZE + 'px')
           .css('top', $elem.data('y') * CELL_SIZE + 'px')
      if idx in correct_idxs
        $elem.addClass('correct')
    )
    $wrapper.css('width', CELL_SIZE * width + 'px')
            .css('height', CELL_SIZE * height + 'px')

  cell_clicked = (e) ->
    $cell = $ this
    $cell.off 'click', cell_clicked
    if correct($cell)
      flip_cell(
        $cell
        ->
          $cell.addClass 'selected'
        ->
          if all_correct_selected()
            win()
      )
    else
      lose()

  correct = ($cell) ->
    $cell.hasClass 'correct'

  all_correct_selected = ->
    the_wrapper.find('.correct').length == the_wrapper.find('.correct.selected').length

  flip_cell = ($cell, middle, finish) ->
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
        complete: finish

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
      2000
    )

  shuffle = (array) ->
    current_index = array.length
    temporary_value = undefined
    random_index = undefined
    while current_index isnt 0
      random_index = Math.floor(Math.random() * current_index)
      current_index -= 1
      temporary_value = array[current_index]
      array[current_index] = array[random_index]
      array[random_index] = temporary_value
    array

  win = ->
    width += 1
    height += 1
    the_wrapper.find('.win').removeClass('hidden')

  lose = ->
    the_wrapper.find('.lose').removeClass('hidden')
    the_wrapper.find('.correct').each((idx, elem) ->
      $cell = $(elem)
      flip_cell $cell, -> $cell.addClass 'selected'
    )

  restart = ->
    the_wrapper.find('.lose').addClass('hidden')
    the_wrapper.find('.win').addClass('hidden')
    the_wrapper.find(".cell").remove()
    initialize(the_wrapper[0])

  initialize = (elem) ->
    $matrix = matrix($(elem), 4, 4)
    setTimeout(
      -> preview($matrix, start)
      1000
    )

  start = ($matrix) ->
    $matrix.find(".cell").click(cell_clicked)

  attach_buttons = ($wrapper) ->
    $wrapper.find('.restart').click(restart)

  $(".matrix").each (idx, elem) ->
    attach_buttons($ elem)
    initialize(elem)
