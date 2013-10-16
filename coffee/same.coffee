jQuery ->

  class Card extends Backbone.Model
    defaults:
      symbol: 'a'
      position: 0


  class Score extends Backbone.Model
    defaults:
      points: 0
      multiplier: 1
      username: 'Anonymous'

    reset: =>
      @set 'points', 0
      @set 'multiplier', 1

    reward: =>
      m = @get('multiplier')
      @set 'points', @get('points') + m
      @set('multiplier', Math.min(10, m + 1))

    penalize: =>
      m = @get('multiplier')
      @set('multiplier', Math.max(1, Math.floor(m / 2)))


  class CountDown extends Backbone.Model
    defaults:
      remains: 40

    reset: =>
      @clear().set(@defaults)

    start: =>
      @reset()
      @timer = setInterval(
        @tick,
        1000
      )

    tick: =>
      @trigger 'tick'
      r = @get 'remains'
      if r > 0
        @set 'remains', r - 1
      else
        clearInterval @timer
        @trigger 'finish'


  class Deck extends Backbone.Collection
    model: Card
    alphabet: "abc"

    initialize: ->
      @sameness = 0.5 - 1.0 / @alphabet.length
      @score = new Score
      @count_down = new CountDown
      @status = 'paused'

    start_game: =>
      @status = 'playing'
      @add_card()
      @score.reset()

    stop_game: =>
      @reset()
      @count_down.reset()
      @status = 'paused'

    add_card: =>
      if @status isnt 'playing'
        return
      if @length == 0
        # well, we should not be here
      else if @length == 1
        # NOW the real game begin!
        @count_down.start()
      else if Math.random() < @sameness
        next_symbol = @at(@length - 1).get('symbol')
      else
        symbol_idx = Math.floor(Math.random() * @alphabet.length)
        next_symbol = @alphabet[symbol_idx]
      @add new Card
        symbol: next_symbol
        position: @length

    commit_answer: (answer) =>
      is_correct = null
      if @length >= 2
        current = @at(@length - 1).get('symbol')
        previous = @at(@length - 2).get('symbol')
        correct_answer = (current == previous)
        is_correct = answer is correct_answer
        if is_correct
          @score.reward()
        else
          @score.penalize()
      @add_card()
      is_correct


  class CardView extends Backbone.View
    tagName: 'div'
    className: 'card'

    initialize: ->
      @model.on 'change', @render
      @model.on 'flip', @flip
      @$el.css
        zIndex: 1000 - @model.get 'position'
        # these properties will be expanded to set of browser-specific:
        perspective: '600px'
        'transform-origin': '120% 50%'

    render: =>
      @$el.html @model.get 'symbol'
      @

    flip: =>
      @$el.transition
        rotateY: 90
        duration: 300
        easing: 'linear'
        complete: =>
          @$el.css
            zIndex: 1000 + @model.get 'position'
          @$el.text ''
      .transition
        rotateY: 180
        duration: 600
        easing: 'snap'


  class DeckView extends Backbone.View
    el: $ '.wrapper'

    initialize: ->
      @disabled = false
      @deck = new Deck
      @deck.on 'add', @on_card_added
      @deck.count_down.on 'finish', @on_finish
      @render_preface()
      @button_default_color = $('button').css 'backgroundColor'
      $(document).keydown @on_key_down

    on_start: =>
      @render_game()
      @deck.start_game()

    on_finish: =>
      @deck.stop_game()
      @render_result()

    on_repeat: =>
      @on_start()

    render_game: =>
      @$el.html """
        <div class="score-wrapper">
          Your score is <span class="score"></span>.
        </div>
        <div class="score-wrapper">
          The game will end in <span class="count-down"></span> seconds.
        </div>
        <div class="cards"></div>
        <div class="buttons">
          <button class="btn another">← Another</button>
          <button class="btn same">Same →</button>
        </div>
      """
      @score = new ScoreView model: @deck.score, el: @$('.score')
      @$('.count-down').text @deck.count_down.get 'remains'
      @deck.count_down.on 'change:remains', =>
        @$('.count-down').text @deck.count_down.get 'remains'

    render_preface: =>
      @$el.html """
        <h1>
            Same symbol game
        </h1>
        <p>
            Memorize the symbol.
        </p>
        <p>
            Answer, does the current symbol match the symbol
            that came immediatly before it?
        </p>
        <p>
            You can use keyboard arrows:
        </p>
        <div class="row">
            <div class="col-lg-6 text-right">
                ← for "Another"
            </div>
            <div class="col-lg-6">
                → for "Same"
            </div>
        </div>
        <p style="text-align: center">
            <button class="btn start">
                Start!
            </button>
        </p>
      """

    render_result: =>
      @$el.html """
        <h1>
            Horay!
        </h1>
        <p class="score-wrapper">
          Your score is <span class="score"></span>
        </p>
        <p>
            <button class="btn repeat">Repeat!</button>
        </p>
      """
      @$('.score').text @score.model.get 'points'

    on_same_button_clicked: =>
      right = @on_button_clicked(true)
      if right is true
        @button_blink($('.same'), '#a0ffa0')
      else if right is false
        @button_blink($('.same'), '#ffa0a0')

    on_another_button_clicked: =>
      right = @on_button_clicked(false)
      if right is true
        @button_blink($('.another'), '#a0ffa0')
      else if right is false
        @button_blink($('.another'), '#ffa0a0')

    on_button_clicked: (is_same) =>
      if @disabled is false
        @disabled = true
        right = @deck.commit_answer(is_same)
        setTimeout(
          => @disabled = false
          300
        )
        right

    on_card_added: (card) =>
      card_view = new CardView model: card
      new_el = card_view.render().el
      @$('.cards').append new_el
      if @deck.length > 1
        @deck.at(@deck.length - 2).trigger('flip')

    on_key_down: (keyboard_event) =>
      if keyboard_event.which == 37
        @on_another_button_clicked()
      else if keyboard_event.which == 39
        @on_same_button_clicked()

    button_blink: ($btn, color) =>
      $btn.transition
        backgroundColor: color
        100
      .transition
        backgroundColor: @button_default_color
        500

    events:
      'click button.another': 'on_another_button_clicked'
      'click button.same': 'on_same_button_clicked'
      'click button.start': 'on_start'
      'click button.repeat': 'on_repeat'
      # 'keyup': 'on_key_down'


  class ScoreView extends Backbone.View
    tagName: 'div'
    className: 'score'

    initialize: ->
      @model.on 'change', @render
      @render()

    render: =>
      @$el.text @model.get 'points'
      @

  $('.box').css
    perspective: '300px'
    'transform-origin': '120% 50%'
  $(document).deck_view = new DeckView el: $('.wrapper')
