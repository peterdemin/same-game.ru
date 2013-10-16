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

    reward: =>
      m = @get('multiplier')
      @set 'points', @get('points') + m
      @set('multiplier', Math.min(10, m + 1))

    penalize: =>
      m = @get('multiplier')
      @set('multiplier', Math.max(1, Math.floor(m / 2)))


  class Deck extends Backbone.Collection
    model: Card
    alphabet: "abc"

    initialize: ->
      @sameness = 0.5 - 1.0 / @alphabet.length
      @score = new Score

    start_game: =>
      @add_card()

    add_card: =>
      if @length > 2 and Math.random() < @sameness
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
      $(document).keydown @on_key_up
      @deck = new Deck
      @deck.on 'add', @on_card_added
      @render()
      @score = new ScoreView model: @deck.score, el: @$('div.score')
      @button_default_color = $('button').css 'backgroundColor'
      @deck.start_game()

    render: =>
      @$el.append """
        <div class="score"></div>
        <div class="cards"></div>
        <div class="buttons">
          <button class="btn another">← Another</button>
          <button class="btn same">Same →</button>
        </div>
      """

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

    on_key_up: (keyboard_event) =>
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
      'keyup': 'on_key_up'


  class ScoreView extends Backbone.View
    tagName: 'div'
    className: 'score'

    initialize: ->
      @model.on 'change', @render
      @render()

    render: =>
      @$el.text "Your score: " + @model.get('points') + " pts"
      @


  $('.box').css
    perspective: '300px'
    'transform-origin': '120% 50%'
  deck_view = new DeckView
