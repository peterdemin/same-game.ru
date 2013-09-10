class Slider
  $origin = null
  $destination = null
  $slider = null

  constructor: (@origin_, @destination_, @slider_) ->
    @$origin = $(origin_)
    @$destination = $(destination_)
    @$slider = $(slider_)
    slide: slide

  slide = (reveal_next, complete) ->
    $slider.css('left', $origin.css 'left')
    $slider.css('z-index', '100')
    reveal_next()
    $slider.animate(
      {'left': $destination.css 'left'}
      duration: 400,
      complete: ->
        $destination.css(
          'background-color',
          $slider.css 'background-color'
        )
        $slider.css 'z-index', '-1'
        $slider.css('left', $origin.css 'left')
        complete()
    )

class SameGame
  c1 = null
  c2 = null
  green = null
  red = null
  next_color = null
  button_color = null
  $slider = null
  score = 0
  score_multiplier = 1
  symbol_seq = "ab"
  current_idx = 0
  game_duration = 30
  is_opening = false
  animating = false


  show_current = ->
    $('#card1').text symbol_seq[current_idx];

  open_next = (complete)->
    if not animating
      animating = true
      current_symbol = symbol_seq[current_idx]
      if Math.random() < 0.4
        symbol_seq += current_symbol
      else
        symbol_idx = Math.floor(Math.random() * 3)
        next_symbol = "abcdef"[symbol_idx]
        symbol_seq += next_symbol
      current_idx += 1
      slide(->
        complete() if complete?
        animating = false
      )

  slide = (complete) ->
    $slider.css('left', c1.left).css('z-index', '100')
    show_current()
    $slider.animate(
      {'left': c2.left},
      {
        duration: 400,
        complete: ->
          $('#card2').css(
            'background-color',
            $slider.css('background-color')
          )
          $slider.css('z-index', '-1').css('left', c1.left)
          complete()
      }
    )    

  initialize = ->
    # Ensure elements visibility (repeat game)
    $('#game-holder').removeClass('hidden')
    $('.buttons-holder').removeClass('hidden')
    $('#game-over').addClass('hidden')
    # Ensure elements color (repeat game)
    $('#card2').css(
      'background-color',
      $('#game-holder').css('background-color')
    )
    $slider = $('#slider')
    $slider.css(
      'background-color',
      $('#card1').css('background-color')
    )
    $('.score-holder').text(score)
    $('.score-multiplier').text(score_multiplier)
    # Populate cache
    c1 = $('#card1').position()
    c2 = $('#card2').position()
    green = $.Color('green').toHexString()
    red = $.Color('red').toHexString()
    button_color = $.Color($('#same-btn').css('background-color'))

  start_game = ->
    show_current()
    $slider.css('background-color',
                $('card1').css 'background-color')
    count_down(
      (counter)-> $('#card2').text counter
      -> 
        animating = false
        open_next -> $('#card2').text ''
      3
    )
    count_down(
      (counter)-> $('#remains').text counter
      -> game_over()
      game_duration + 3
    )

  game_over = ->
    $('#game-holder').addClass 'hidden'
    $('.buttons-holder').addClass 'hidden'
    $('#game-over').removeClass 'hidden'
    $(document).off 'keydown'
    the_same_game = undefined

  count_down = (progress, complete, start)->
    step = 1000
    counter = start
    progress counter
    interval = setInterval(
      ->
        counter-= 1
        if counter > 0
          progress counter
        else
          clearInterval interval
          complete()
      step
    );

  on_key_down = (event) ->
    if event.which == 37
      # left arrow
      on_another_click()
    else if event.which == 39
      # right arrow
      on_same_click()

  on_same_click = ($button) ->
    correct = (symbol_seq[current_idx] == symbol_seq[current_idx - 1])
    on_button_click correct
    button_click_animation($button, correct)

  on_another_click = ($button) ->
      correct = (symbol_seq[current_idx] != symbol_seq[current_idx - 1]);
      on_button_click(correct);
      button_click_animation($button, correct);

  button_click_animation = ($button, correct) ->
    blink_color = if correct then green else red
    $button.animate(
      {'background-color': blink_color}
      {
        duration: 150
        complete: ->
          $button.animate(
            {'background-color': button_color}
            {duration: 150}
          )
      }
    );

  is_clicking = false;

  on_button_click = (correct) ->
    if is_clicking
      return
    is_clicking = true;
    if correct
      score+= score_multiplier * 100;
      score_multiplier+= 1;
      score_multiplier = Math.min(score_multiplier, 7);
      $slider.css('background-color', green);
    else
      score_multiplier = 1;
      $slider.css('background-color', red);
    $('.score-holder').text(score);
    $('.score-multiplier').text(score_multiplier);
    if(current_idx < symbol_seq.length - 1)
      open_next(-> is_clicking = false);
    else
      game_over();

  SameGame = ->
    initialize()
    start_game()
    $(document).keydown on_key_down
    return {
      on_same_click: on_same_click
      on_another_click: on_another_click
    }


root = exports ? this

root.on_repeat_click = ()->
  root.the_same_game = SameGame()

root.on_same_click = (button)->
  root.the_same_game.on_same_click $(button)

root.on_another_click = (button)->
  root.the_same_game.on_another_click $(button)

root.on_start_click = ()->
  $('#description').addClass 'hidden'
  $('#game-holder').removeClass 'hidden'
  root.on_repeat_click()
