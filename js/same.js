function SameGame($) {
    var c1;
    var c2;
    var green;
    var red;
    var next_color;
    var $slider;
    var score = 0;
    var score_multiplier = 1;

    var symbol_seq = "ab";
    var current_idx = 0;
    var game_duration = 30;

    var show_current = function() {
        $('#card1').text(symbol_seq[current_idx]);
    }

    var is_opening = false;
    var open_next = function(complete) {
        if(!is_opening) {
            is_opening = true;
            var current_symbol = symbol_seq[current_idx];
            if(Math.random() < 0.4) {
                symbol_seq+= current_symbol;
            } else {
                var symbol_idx = Math.floor(Math.random() * 3);
                var next_symbol = "abcdef"[symbol_idx];
                symbol_seq+= next_symbol;
            }
            current_idx+= 1;
            slide(function() {
                if(complete) {
                    complete();
                }
                is_opening = false;
            });
        }
    }

    var slide = function(complete) {
        $slider.css('left', c1.left).css('z-index', '100');
        show_current();
        $slider.animate(
            {
                'left': c2.left
            }, {
                duration: 400,
                complete: function() {
                    $('#card2').css(
                        'background-color',
                        $slider.css('background-color')
                    )
                    $slider.css('z-index', '-1').css('left', c1.left);
                    complete();
                }
            }
        );    
    }

    var animate_score = function(number) {
        
    }

    var initialize = function() {
        // Ensure elements visibility (repeat game)
        $('#game-holder').removeClass('hidden');
        $('#buttons-holder').removeClass('hidden');
        $('#game-over').addClass('hidden');
        // Ensure elements color (repeat game)
        $('#card2').css(
            'background-color',
            $('#game-holder').css('background-color')
        );
        $('#slider').css(
            'background-color',
            $('#card1').css('background-color')
        );
        $('.score-holder').text(score);
        $('.score-multiplier').text(score_multiplier);
        // Populate cache
        c1 = $('#card1').position();
        c2 = $('#card2').position();
        green = $.Color('green').toHexString();
        red = $.Color('red').toHexString();
        $slider = $('#slider');
    }

    var start_game = function() {
        show_current();
        $slider.css('background-color',
                    $('card1').css('background-color'));
        count_down(
            function(counter) {
                $('#card2').text(counter);
            },
            function() {
                open_next(function() {
                    $('#card2').text('');
                });
            },
            3
        );
        count_down(
            function(counter) {
                $('#remains').text(counter);
            },
            function() {
                game_over();
            },
            game_duration + 3
        );
    }

    var game_over = function() {
        $('#game-holder').addClass('hidden');
        $('#buttons-holder').addClass('hidden');
        $('#game-over').removeClass('hidden');
        $(document).off('keydown');
        the_same_game = undefined;
    };

    var count_down = function(progress, complete, start) {
        var step = 1000;
        var counter = start;
        progress(counter);
        var interval = setInterval(
            function() {
                counter-= 1;
                if(counter > 0) {
                    progress(counter);
                } else {
                    clearInterval(interval);
                    complete();
                }
            },
            step
        );
    }

    var on_key_down = function(event) {
        if(event.which == 37) {  // left arrow
            on_another_click();
        } else if(event.which == 39) {  // right arrow
            on_same_click();
        }
    }

    var on_same_click = function() {
        var correct = (symbol_seq[current_idx] == symbol_seq[current_idx - 1]);
        on_button_click(correct);
    }

    var on_another_click = function() {
        var correct = (symbol_seq[current_idx] != symbol_seq[current_idx - 1]);
        on_button_click(correct);
    }

    var is_clicking = false;
    var on_button_click = function(correct) {
        if(is_clicking) {
            return;
        }
        is_clicking = true;
        if(correct) {
            score+= score_multiplier * 100;
            score_multiplier+= 1;
            score_multiplier = Math.min(score_multiplier, 7);
            $slider.css('background-color', green);
        } else {
            score_multiplier = 1;
            $slider.css('background-color', red);
        }
        $('.score-holder').text(score);
        $('.score-multiplier').text(score_multiplier);
        if(current_idx < symbol_seq.length - 1) {
            open_next(function() {
                is_clicking = false;
            });
        } else {
            game_over();
        }
    }

    $(function() {
        initialize();
        start_game()
        $(document).keydown(on_key_down);
    })

    return {
        on_same_click: on_same_click,
        on_another_click: on_another_click
    };
}

function on_repeat_click() {
    the_same_game = SameGame($);
}

function on_same_click() {
    the_same_game.on_same_click();
}

function on_another_click() {
    the_same_game.on_another_click();
}

function on_start_click() {
    $('#description').addClass('hidden');
    $('#game-holder').removeClass('hidden');
    on_repeat_click();
}

