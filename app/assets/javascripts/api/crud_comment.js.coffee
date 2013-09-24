Juvia.enterChat = (e, $this_obj) ->
  self = this
  self.sendChat($this_obj) if e.keyCode is 13
  
Juvia.sendChat = ($this_obj) ->
  self = this
  # $this_obj is a inputbox object
  console.log $this_obj
  console.log self
  name = self.username
  img = self.user_image
  msg = $this_obj.find("#msg-box").val()
  clear = true
  self.addMessage(name, img, msg, clear) if msg.length > 0
  data =
   content: msg
   parent_id: ""
   restrict_comment_length: "false"
   site_key: self.site_key
   topic_key: self.topic_key
   topic_title: "Batbugger"
   topic_url: "Batbugger"
   author_name: self.username
   author_email: self.user_email

  if msg.length > 0
    self.loadScript('/api/comments/add_comment',data)

Juvia.handleAddComment = (options) ->
  self = this
  self.comment_count = options.comment_count
  self.last_comment_number = options.last_comment_number

Juvia.handleLoadChat = (options) ->
  console.log options
  self = this
  self.addMessage(options.user_name || "", options.user_image, options.comment_text, false, {"animate": 100, "creation_date": options.creation_date})
  
Juvia.addMessage = (name, img, msg, clear, options = {}) ->
  inner = $("#chat-messages-inner")
  time = new Date()
  hours = time.getHours()
  ampm = 'AM'
  ampm = 'PM' if hours > 11
  minutes = time.getMinutes()
  hours = (24 - hours) if hours >= 12
  hours = "0" + hours  if hours < 10
  minutes = "0" + minutes  if minutes < 10
  idname = name.replace(" ", "-").toLowerCase()
  chat_time = hours + ":" + minutes + " " + ampm
  chat_time = options["creation_date"] if options["creation_date"]
  chat_block = "<p><img src=\"" + img + "\" alt=\"\" />" + "<span class=\"msg-block\"><strong>" + name + "</strong> <span class=\"time\">- " + chat_time + "</span>" + "<span class=\"msg\">" + msg + "</span></span></p>"
  inner.append chat_block
  $(chat_block).find("p").hide().fadeIn 800
  $(".chat-message input").val("").focus()  if clear
  $("#chat-messages").animate
    scrollTop: inner.height()
  , ( options["animate"] || 1000)


Juvia.touchChat = ->
  self = this
  data =
   topic_key: self.topic_key
   comment_count: self.comment_count
  self.loadScript('/api/comments/touch_chat',data)

Juvia.handleTouchChat = (options) ->
  self = this
  self.appendChat() if options.got_new_comment == "true"

Juvia.appendChat = ->
  self = this
  data =
   topic_key: self.topic_key
   comment_number: self.last_comment_number
  self.loadScript('/api/comments/append_chat',data)

Juvia.handleAppendChat = (options) ->
  self = this
  console.log options
  self.comment_count = options.comment_count
  self.last_comment_number = options.last_comment_number
  for k, v of options.new_comments
    self.addMessage(v.user_name || "", v.user_image, v.comment_text, false, {"animate": 100, "creation_date": v.creation_date})
