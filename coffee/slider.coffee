class Slider
  constructor: (origin_, destination_, slider_) ->
    @origin = $(origin_)
    @destination = $(destination_)
    @slider = $(slider_)

  slide: (reveal_next, complete) ->
    @slider.css 'left', @origin.position().left
    @slider.css 'z-index', 100
    reveal_next?()
    @slider.animate(
      {'left': @destination.position().left}
      duration: 400
      complete: =>
        @destination.css('background-color'
                         @slider.css 'background-color')
        @slider.css 'z-index', -1
        @slider.css 'left', @origin.position().left
        complete?()
    )

(exports ? this).Slider = Slider
