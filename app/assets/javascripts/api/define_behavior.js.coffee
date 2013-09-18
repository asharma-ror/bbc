Juvia.reinstallBehavior = ->
  self = this
  $ = @$
  $('input[name="parent_id"]').val("");
  $('.juvia-comment-content img').lightBox();
  $('.dropdown-toggle').dropdown();
  unless $(document.body).hasClass("juvia-installed-behavior")
    $(document.body).addClass "juvia-installed-behavior"
    $(document.body).bind "mousedown touchdown", (event) ->
      $(".juvia-help-content").hide()  if not $(event.target).hasClass(".juvia-help-content") and $(event.target).closest(".juvia-help-content").length is 0

  $("#author_email_setting").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      $this.bind "click", (event) ->
        self.authorSetting event

  $(".juvia-comment-editable-content:not(juvia-installed-behavior)").each ->
    if self.user_logged_in
      $this = $(this)
      $this.addClass "juvia-installed-behavior"
      $this.bind "dblclick", ->
        self.editComment this

  $("li.editcomment:not(.juvia-installed-behavior)").each ->
    if self.user_logged_in
      $this = $(this)
      $this.addClass "juvia-installed-behavior"
      $this.bind "click", ->
        $(this).closest(".juvia-comment-content").find(".juvia-comment-editable-content").dblclick()

  #self.editComment(this);
  $(".juvia-container:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    addCommentForm = $(".juvia-add-comment-form", this)

    $("input[name=author_name]", addCommentForm).example "Your name (optional)",
      className: "juvia-example-text"
    $("input[name=author_email]", addCommentForm).example "Your email (optional)",
      className: "juvia-example-text"
    
    # Our submit handler is called before jquery.example has cleared the
    #      * example texts. We work around this by calling our actual
    #      * submit handler a short while later.
    #      
    addCommentForm.bind "submit", (event) ->
      setTimeout (->
        self.submitComment event
      ), 1

    $("#comment_textarea").bind "input focus", ->
      if this.value.length
        $("#juvia-cancel-button").show()
      else
        $("#juvia-cancel-button").hide()

    $("#juvia-cancel-button").bind "click", (event) ->
      $container = $(event.target).closest(".juvia-container")
      $("#comment_textarea",$container).val("")
      preview = $(".juvia-preview", $container)
      preview.find(".juvia-preview-content").hide()
      preview.find(".juvia-preview-content").html("")
      preview.find(".juvia-preview-empty").show()
      self.clearAllTextBoxStorage $container
      $('input[name="parent_id"]').val('')
      
    $(".juvia-help", this).bind "click", ->
      $this = $(this)
      content = $this.parent().find(".juvia-help-content")
      offset = $this.position()
      content.css
        left: offset.left + "px"
        top: (offset.top + $this.outerHeight() + 8) + "px"

      content.show()

    textarea = $(".juvia-textarea-field textarea", addCommentForm)
    textarea.delayedObserver ->
      self.previewComment this

    errorDiv = $(".juvia-form-actions .juvia-error", addCommentForm)
    addCommentForm.bind "reset", ->
      errorDiv.hide()
      
      # Repopulate example texts in input fields.
      setTimeout (->
        $("input", addCommentForm).blur()
      ), 1


  $(".juvia-sort-select select:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $this.bind "change", (event) ->
      self.sortComments event, this


  $("replycomment:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $this.bind "click", ->
      comment = $(this).closest(".juvia-comment")
      self.replyToComment comment


  $(".juvia-preview a:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $this.juviatooltip html: true

  $(".juvia-vote-to-comment").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      $this.bind "click", (event) ->
        self.voteComment event, this

  $(".comment-vote").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      if $this.hasClass("user_like")
        $this.css({'cursor':'pointer'})
        $this.bind "click", (event) ->
          self.showCommentLikeUsers event, this

  $("#liked_pages").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      if $this.hasClass("user_like")
        $this.css({'cursor':'pointer'})
        $this.bind "click", (event) ->
          self.showTopicLikeUsers event, this

  $(".juvia-vote-to-topic").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      $this.bind "click", (event) ->
        self.voteTopic event, this


  $("flagcomment:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    unless $this.hasClass("flagged")
      $flag_span = $($this.find("span"))
      unless $flag_span.html() == " Flagged"
        $this.addClass "juvia-installed-behavior"
        $this.bind "click", (event) ->
          jConfirm Juvia.translated_locale.confirm_message_flag, "Confirmation", (res) ->
            if res
              $(this).removeClass "juvia-installed-behavior"
              $this.addClass "flagged"
              $this.unbind "click"
              self.reportComment event, $this
            else
              false


  $(".juvia-comment-function").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      $this.bind
        mouseenter: (e) ->
          $(".blink_text", $this).each ->
            $(this).css "visibility", "visible"

        mouseleave: (e) ->
          $(".blink_text", $this).each ->
            $(this).css "visibility", "hidden"

  $(".juvia-avatar img:not(.juvia-installed-behavior)").each (index) ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $this.bind "click", ->
      window.location = "/users?juvia=true&email=" + $this.data("user-email")


  $(".collapse_link_class:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $this.bind "click", ->
      if $("#" + @dataset.divid).hasClass("in")
        $("#comment_sign_" + @dataset.divid).addClass "icon-plus"
        $("#comment_sign_" + @dataset.divid).removeClass "icon-minus"
      else
        $("#comment_sign_" + @dataset.divid).addClass "icon-minus"
        $("#comment_sign_" + @dataset.divid).removeClass "icon-plus"
  
  $(".more-options").each ->
    $this = $(this)
    $this.bind "click", (event) ->
       $('#'+ $this.attr("data-wrapper")).css({'overflow':'visible'})
    $this.bind "openClassRemoved", (event) ->
       $('#'+ $this.attr("data-wrapper")).css({'overflow':'inherit'})

  $("li.deletecomment:not(.juvia-installed-behavior)").each ->
    $this = $(this)  
    $this.addClass "juvia-installed-behavior"
    $this.bind "click", (event) ->
      if confirm(Juvia.translated_locale.delete_confirm_msg)
        self.deleteComment event, this
      else
        false

  $(".juvia-subscribe-to-topic").each ->
    $this = $(this)
    unless $this.hasClass("juvia-installed-behavior")
      $this.addClass "juvia-installed-behavior"
      $this.bind "click", (event) ->
        self.topicNotification event, this
