Juvia.showMoreComments = (this_obj) ->
  $ = @$
  page_num = @current_page
  page_num = page_num + 1
  @current_page = page_num
  current_sorting_order = @sorting_order
  $(".load_more_contain img").show()
  $this = $(this_obj)
  $this.hide()
  form = $("#juvia-sort-select")
  $container = $(form).closest(".juvia-container")
  @loadJsScript "/api/comments/show_comments",
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    topic_url: $container.data("topic-url")
    page: page_num
    sorting_order: current_sorting_order


Juvia.showMoreUserComments = (this_obj) ->
  $ = @$
  page_num = @current_page
  page_num = page_num + 1
  @current_page = page_num
  $(".load_more_contain img").show()
  $this = $(this_obj)
  $this.hide()
  @loadJsScript "/api/append_user_comments",
    site_key: $this.attr("data-site-key")
    username: $this.attr("data-user-name")
    user_email: $this.attr("data-user-email")
    container: "#show_user_comments"
    page: page_num


Juvia.replyToComment = ($comment) ->
  $ = @$
  parent_id = $comment.data("comment-id")
  $container = $comment.closest(".juvia-container")
  text = $(".juvia-comment-pure-content", $comment).text()
  lines = text.split("\n")
  i = undefined
  i = 0
  while i < lines.length
    lines[i] = "> " + lines[i]
    i++
  $textarea = $("textarea", $container)
  $('input[name="parent_id"]').val(parent_id);
  #var authorName = $('input[name="author_name"]', $container).val(); 
  authorName = $.trim($(".juvia-author-name", $comment).text())
  newContent = "*" + @translated_locale.in_reply_to + " [#" + $comment.data("comment-number") + "](#" + $comment.attr("id") + "') " + @translated_locale.by + " " + authorName + ":*\n" + lines.join("\n")
  unless $textarea.val() is ""
    newContent += "\n\n"
    newContent += $textarea.val()
  $textarea.val newContent
  @smoothlyScrollTo $textarea.offset().top
  $textarea.focus()


Juvia.sortComments = (event, this_obj) ->
  $ = @$
  $("#show_more_comments").hide()
  @sorting_order = this_obj.value
  @set_cookie "sorting_order", this_obj.value,
    path: "/"

  @current_page = 1
  form = event.target
  $container = $(form).closest(".juvia-container")
  @loadScript "/api/comments/sort_comment",
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    topic_title: $container.data("topic-title")
    topic_url: $container.data("topic-url")
    author_name: $("input[name=\"author_name\"]", $container).val()
    author_email: $("input[name=\"author_email\"]", $container).val()
    sort: this_obj.value

  $("#juvia-comments-box").html ""
  $(".load_more_contain img").show()


Juvia.voteComment = (event, this_obj) ->
  $ = @$
  $this = $(this_obj)
  form = event.target
  $container = $(form).closest(".juvia-container")
  up_down = 1
  $vote_icon = $this.find("i")
  $vote_text = $this.find("span")
  if $vote_icon.hasClass("up-active")
    $vote_icon.removeClass "up-active"
    $vote_icon.addClass "down-active"
    $vote_text.html " " + @translated_locale.liked
    up_down = 1
  else
    $vote_icon.removeClass "down-active"
    $vote_icon.addClass "up-active"
    $vote_text.html " " + @translated_locale.like
    up_down = 0
  a_name = $("input[name=\"author_name\"]", $container).val()
  a_email = $("input[name=\"author_email\"]", $container).val()
  opt1 =
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    topic_url: $container.data("topic-url")
    comment_key: $this.data("comment-id")
    vote: up_down

  opt2 = {}
  unless typeof a_email is "undefined"
    opt2 =
      author_name: a_name
      author_email: a_email
  @loadJsScript "/api/post/vote", $.extend(opt1, opt2)


Juvia.voteTopic = (event, this_obj) ->
  $ = @$
  $this = $(this_obj)
  form = event.target
  $container = $(form).closest(".juvia-container")
  $like = $("#vote_for_like")
  $like_text = $("#vote_for_like").find("span")
  $vote_icon = $this.find("i")
  $vote_text = $this.find("span")
  if $this.hasClass("votes-up-active")
    up_down = 0
    $this.removeClass "votes-up-active"
    $vote_text.html " " + @translated_locale.topic_like
  else
    up_down = 1
    $this.addClass "votes-up-active"
    $vote_text.html " " + @translated_locale.topic_liked
  a_name = $("input[name=\"author_name\"]", $container).val()
  a_email = $("input[name=\"author_email\"]", $container).val()
  opt1 =
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    topic_url: $container.data("topic-url")
    topic_title: $container.data("topic-title")
    vote: up_down

  opt2 = {}
  unless typeof a_email is "undefined"
    opt2 =
      author_name: a_name
      author_email: a_email
  @loadJsScript "/api/topic/vote", $.extend(opt1, opt2)


Juvia.reportComment = (event, this_obj) ->
  $ = @$
  $this = $(this_obj)
  form = event.target
  $container = $(form).closest(".juvia-container")
  @loadScript "/api/post/flag",
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    topic_title: $container.data("topic-title")
    topic_url: $container.data("topic-url")
    comment_key: $this.data("comment-id")
    author_name: $("input[name=\"author_name\"]", $container).val()
    author_email: $("input[name=\"author_email\"]", $container).val()

  false

Juvia.showCommentLikeUsers = (event, this_obj) ->
  $ = @$
  $this = $(this_obj)
  form = event.target
  $container = $(form).closest(".juvia-container")
  
  opt1 =
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
    comment_key: $this.data("comment-id")
  opt2 = {}
  
  @loadScript "/api/comments/show_like_users", $.extend(opt1, opt2)

Juvia.showTopicLikeUsers = (event) ->
  $ = @$
  form = event.target
  $container = $(form).closest(".juvia-container")

  opt1 =
    site_key: $container.data("site-key")
    topic_key: $container.data("topic-key")
  opt2 = {}

  @loadScript "/api/comments/show_topic_like_users", $.extend(opt1, opt2)

Juvia.authorSetting = (event) ->
  $ = @$
  form = event.target
  $container = $(form).closest(".juvia-container")
  a_email = $("input[name=\"author_email\"]", $container).val()
  
  if $("#juvia-author-setting").hasClass("turn_on")
    a_notification_setting = 0
  else
    a_notification_setting = 1
  opt1 =
    author_email: a_email
    notify_me: a_notification_setting
    site_key: $container.data("site-key")
  
  opt2 = {}
  
  @loadJsScript "/api/authors/update_author", $.extend(opt1, opt2)

Juvia.permalinkToComment = (link) ->
  $ = @$
  permalink_str = ""
  permalink_dom = $("#comment-permalink")
  $("#comment_permalink").modal "show"
  permalink_str = permalink_str + "<input type='text' value=" + link + " class='permalink-anchored-to' readonly='true' onclick = 'this.select()'>"
  permalink_dom.html " " + permalink_str

Juvia.deleteComment = (event, this_obj) ->
  $ = @$
  $this = $(this_obj)
  form = event.target
  $container = $(form).closest(".juvia-container")
  @loadScript "/api/comments/destroy",
    site_key: $container.data("site-key")
    comment_key: $this.data("comment-id")
    user_email: @user_email

  false
