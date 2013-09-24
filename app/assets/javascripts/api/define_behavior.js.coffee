Juvia.reinstallBehavior = ->
  self = this
  $ = @$
  
  $("inputbox:not(.juvia-installed-behavior)").each ->
    $this = $(this)
    $this.addClass "juvia-installed-behavior"
    $(".chat-input-box button.send-chat", this).bind "click", ->
      self.sendChat($this)
    
    $(".chat-input-box button#chat-refresh", this).bind "click", ->
      self.touchChat()
    
    $(".chat-input-box input", this).on "keyup", (e) ->
      self.enterChat(e,$this)
