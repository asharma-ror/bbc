Juvia.enterChat = (e, $this_obj) ->
  self = this
  self.userOnline("#chat_user_"+self.user_id)
  self.last_active_at = new Date;
  self.sendChat($this_obj) if e.keyCode is 13

Juvia.sendChat = ($this_obj) ->
  self = this
  # $this_obj is a inputbox object
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
  self = this
  self.addMessage(options.user_name || "", options.user_image, options.comment_text, false, {"animate": 10, "creation_date": options.creation_date})
  
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
  self.comment_count = options.comment_count
  self.last_comment_number = options.last_comment_number
  for k, v of options.new_comments
    self.addMessage(v.user_name || "", v.user_image, v.comment_text, false, {"animate": 100, "creation_date": v.creation_date})

Juvia.userStatus = ->
  self = this
  current_time = new Date
  diff = (current_time - self.last_active_at)/(60*1000)
  current_status = "away"
  current_status = "online" if diff < 6
  projects_users = self.user_id
  $("#project_users_list span.badge").each ->
    projects_users = projects_users + "," + $(this).data("userid") if self.user_id != $(this).data("userid")
  
  data =
    status: current_status
    user_id: self.user_id
    topic_key: self.topic_key
    project_users: projects_users
  self.loadScript('/api/comments/user_status',data)

Juvia.handleUserStatus = (options) ->
  self = this
  for k, v of options.users_status
    if v.status == "online"
      self.userOnline("#chat_user_"+k)
    if v.status == "away"
      self.userAway("#chat_user_"+k)
    if v.status == "offline"
      self.userOffline("#chat_user_"+k)
    
Juvia.userActive = ->
  self = this
  self.last_active_at = new Date;
  
Juvia.userOnline = (user_id) ->
  $(user_id).addClass("badge-success")
  $(user_id).removeClass("badge-warning")

Juvia.userAway = (user_id) ->
  $(user_id).addClass("badge-warning")
  $(user_id).removeClass("badge-success")

Juvia.userOffline = (user_id) ->
  $(user_id).removeClass("badge-success")
  $(user_id).removeClass("badge-warning")
