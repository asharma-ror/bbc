// jQuery lightBox plugin
(function(Juvia) {
 (function($){
      $.extend($.fn, {
          delayedObserver: function(callback, delay, options) {
              return this.each(function() {
                  var el = $(this);
                  var op = options || {};
                  
                  var timer;
                  var oldval = el.val();
                  var condition = op.condition || function() {
                      return $(this).val() == oldval;
                  }
                  delay = delay || 0.5;
                  
                  function changeHandler() {
                      if (!condition.apply(el)) {
                          if (timer) {
                              clearTimeout(timer);
                          }
                          timer = setTimeout(function() {
                              callback.apply(el);
                          }, delay * 1000);
                          oldval = el.val();
                      }
                  }
                  
                  el.bind(op.event || 'keyup', changeHandler);
              });
          }
      });
  })(Juvia.$);
})(Juvia);
