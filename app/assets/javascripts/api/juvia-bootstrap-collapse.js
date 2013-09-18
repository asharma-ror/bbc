(function(Juvia){
  !function ($) {

    "use strict"; // jshint ;_;


   /* COLLAPSE PUBLIC CLASS DEFINITION
    * ================================ */

    var JuviaCollapse = function (element, options) {
      this.$element = $(element)
      this.options = $.extend({}, $.fn.juviacollapse.defaults, options)

      if (this.options.parent) {
        this.$parent = $(this.options.parent)
      }

      this.options.toggle && this.toggle()
    }

    JuviaCollapse.prototype = {

      constructor: JuviaCollapse

    , dimension: function () {
        var hasWidth = this.$element.hasClass('width')
        return hasWidth ? 'width' : 'height'
      }

    , show: function () {
        var dimension
          , scroll
          , actives
          , hasData

        if (this.transitioning) return

        dimension = this.dimension()
        scroll = $.camelCase(['scroll', dimension].join('-'))
        actives = this.$parent && this.$parent.find('> .accordion-group > .in')

        if (actives && actives.length) {
          hasData = actives.data('jcollapse')
          if (hasData && hasData.transitioning) return
          actives.juviacollapse('hide')
          hasData || actives.data('jcollapse', null)
        }

        this.$element[dimension](0)
        this.transition('addClass', $.Event('show'), 'shown')
        this.$element[dimension](this.$element[0][scroll])
      }

    , hide: function () {
        var dimension
        if (this.transitioning) return
        dimension = this.dimension()
        this.reset(this.$element[dimension]())
        this.transition('removeClass', $.Event('hide'), 'hidden')
        this.$element[dimension](0)
      }

    , reset: function (size) {
        var dimension = this.dimension()

        this.$element
          .removeClass('jcollapse')
          [dimension](size || 'auto')
          [0].offsetWidth

        this.$element[size !== null ? 'addClass' : 'removeClass']('jcollapse')

        return this
      }

    , transition: function (method, startEvent, completeEvent) {
        var that = this
          , complete = function () {
              if (startEvent.type == 'show') that.reset()
              that.transitioning = 0
              that.$element.trigger(completeEvent)
            }

        this.$element.trigger(startEvent)

        if (startEvent.isDefaultPrevented()) return

        this.transitioning = 1

        this.$element[method]('in')

        $.support.transition && this.$element.hasClass('jcollapse') ?
          this.$element.one($.support.transition.end, complete) :
          complete()
      }

    , toggle: function () {
        this[this.$element.hasClass('in') ? 'hide' : 'show']()
      }

    }


   /* COLLAPSIBLE PLUGIN DEFINITION
    * ============================== */

    $.fn.juviacollapse = function (option) {
      return this.each(function () {
        var $this = $(this)
          , data = $this.data('jcollapse')
          , options = typeof option == 'object' && option
        if (!data) $this.data('jcollapse', (data = new JuviaCollapse(this, options)))
        if (typeof option == 'string') data[option]()
      })
    }

    $.fn.juviacollapse.defaults = {
      toggle: true
    }

    $.fn.juviacollapse.Constructor = JuviaCollapse


   /* COLLAPSIBLE DATA-API
    * ==================== */

    $(function () {
      $('body').on('click.jcollapse.data-api', '[data-toggle=jcollapse]', function ( e ) {
        var $this = $(this), href
          , target = $this.attr('data-target')
            || e.preventDefault()
            || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '') //strip for ie7
          , option = $(target).data('jcollapse') ? 'toggle' : $this.data()
        $(target).juviacollapse(option)
      })
    })

  }(Juvia.$);
})(Juvia);
