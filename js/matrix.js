(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  jQuery(function() {
    var CELL_SIZE, all_correct_selected, attach_buttons, cell_clicked, correct, flip_cell, height, initialize, lose, matrix, preview, render_cell, restart, shuffle, start, the_wrapper, width, win;
    CELL_SIZE = 72;
    the_wrapper = null;
    width = 4;
    height = 4;
    render_cell = _.template("<div class=\"cell\" data-x=<%= x %> data-y=<%= y %>></div>");
    matrix = function($wrapper) {
      var correct_idxs, order, x, y, _i, _j, _ref, _ref1;
      the_wrapper = $wrapper;
      order = [];
      for (y = _i = 0, _ref = width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        for (x = _j = 0, _ref1 = height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          $wrapper.append(render_cell({
            x: x,
            y: y
          }));
          order.push(x + y * width);
        }
      }
      correct_idxs = shuffle(order).slice(0, width * height / 3);
      $wrapper.find(".cell").each(function(idx, elem) {
        var $elem;
        $elem = $(elem);
        $elem.css('left', $elem.data('x') * CELL_SIZE + 'px').css('top', $elem.data('y') * CELL_SIZE + 'px');
        if (__indexOf.call(correct_idxs, idx) >= 0) {
          return $elem.addClass('correct');
        }
      });
      return $wrapper.css('width', CELL_SIZE * width + 'px').css('height', CELL_SIZE * height + 'px');
    };
    cell_clicked = function(e) {
      var $cell;
      $cell = $(this);
      $cell.off('click', cell_clicked);
      if (correct($cell)) {
        return flip_cell($cell, function() {
          return $cell.addClass('selected');
        }, function() {
          if (all_correct_selected()) {
            return win();
          }
        });
      } else {
        return lose();
      }
    };
    correct = function($cell) {
      return $cell.hasClass('correct');
    };
    all_correct_selected = function() {
      return the_wrapper.find('.correct').length === the_wrapper.find('.correct.selected').length;
    };
    flip_cell = function($cell, middle, finish) {
      return $cell.transition({
        rotateY: 90,
        duration: 250,
        easing: 'linear',
        complete: middle
      }).transition({
        rotateY: 180,
        duration: 250,
        easing: 'linear'
      }).transition({
        rotateY: 0,
        duration: 0,
        complete: finish
      });
    };
    preview = function($matrix, callback) {
      var $correct;
      $matrix.addClass("preview");
      $correct = $matrix.find('.correct');
      $correct.each(function(idx, elem) {
        var $cell;
        $cell = $(elem);
        return flip_cell($cell, function() {
          return $cell.addClass('selected');
        });
      });
      return setTimeout(function() {
        $correct.each(function(idx, elem) {
          var $cell;
          $cell = $(elem);
          return flip_cell($cell, function() {
            return $cell.removeClass('selected');
          });
        });
        $matrix.removeClass("preview");
        return typeof callback === "function" ? callback($matrix) : void 0;
      }, 2000);
    };
    shuffle = function(array) {
      var current_index, random_index, temporary_value;
      current_index = array.length;
      temporary_value = void 0;
      random_index = void 0;
      while (current_index !== 0) {
        random_index = Math.floor(Math.random() * current_index);
        current_index -= 1;
        temporary_value = array[current_index];
        array[current_index] = array[random_index];
        array[random_index] = temporary_value;
      }
      return array;
    };
    win = function() {
      width += 1;
      height += 1;
      return the_wrapper.find('.win').removeClass('hidden');
    };
    lose = function() {
      the_wrapper.find('.lose').removeClass('hidden');
      return the_wrapper.find('.correct').each(function(idx, elem) {
        var $cell;
        $cell = $(elem);
        return flip_cell($cell, function() {
          return $cell.addClass('selected');
        });
      });
    };
    restart = function() {
      the_wrapper.find('.lose').addClass('hidden');
      the_wrapper.find('.win').addClass('hidden');
      the_wrapper.find(".cell").remove();
      return initialize(the_wrapper[0]);
    };
    initialize = function(elem) {
      var $matrix;
      $matrix = matrix($(elem), 4, 4);
      return setTimeout(function() {
        return preview($matrix, start);
      }, 1000);
    };
    start = function($matrix) {
      return $matrix.find(".cell").click(cell_clicked);
    };
    attach_buttons = function($wrapper) {
      return $wrapper.find('.restart').click(restart);
    };
    return $(".matrix").each(function(idx, elem) {
      attach_buttons($(elem));
      return initialize(elem);
    });
  });

}).call(this);
