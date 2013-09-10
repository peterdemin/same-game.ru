class Slider
  constructor: (origin_
                destination_
                slider_
                @duration=4000
                @reveal_next
                @complete) ->
    @origin = $(origin_)
    @destination = $(destination_)
    @slider = $(slider_)
    _.extend(@, Backbone.Events)
    @slide_once()

  slide_once: () ->
    @once(
      "slide"
      (reveal_next, complete) =>
        @slide(
          reveal_next
          () =>
            complete ?= @complete
            complete?()
            @slide_once()
        )
    )

  slide: (reveal_next=@reveal_next,
          complete=@complete) ->
    @slider.css 'left', @origin.position().left
    @slider.css 'z-index', 100
    reveal_next?()
    @slider.animate(
        top: @destination.position().top
        left: @destination.position().left
      duration: @duration
      complete: =>
        @destination.css('background-color'
                         @slider.css 'background-color')
        @slider.css 'z-index', -1
        @slider.css 'left', @origin.position().left
        complete?()
    )

$ () ->
  s = new Slider(
    ".origin"
    ".destination"
    ".slider"
    null
    () -> $(".origin").text "C"
    null
  )
  setTimeout(
    () -> s.trigger("slide")
    500
  )
  $(".origin").click(() ->
    s.trigger("slide", null, () ->
      $(".destination").css(
        'background-color'
        'red'
      )
    )
  )
