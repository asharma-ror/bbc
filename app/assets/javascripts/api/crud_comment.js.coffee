Juvia.editComment = (this_obj) ->
  self = this
  $ = @$
  self.uniq_edit_id = self.uniq_edit_id or 123
  self.uniq_edit_id = self.uniq_edit_id + 1
  return  if $(this_obj).find("textarea").length > 0
  $textarea = $("<textarea class=\"juvia-text-area\" name=\"edit_area\" />")
  $textarea.delayedObserver ->
    self.previewEditComment this

  $buttons = $("<div class=\"edit-buttons\"><button class=\"btn update_comment\" type=\"button\">"+@translated_locale.ok+"</button><button class=\"btn\" type=\"button\" onclick=\"Juvia.resumeEdit($(this).parent().parent())\">"+@translated_locale.cancel+"</button></div>")
  edit_preview_help = $("<div class='row row-markdown'><div class='span'>" + @translated_locale.markdown_help + " <a href='#markdowncollapse_" + self.uniq_edit_id + "'data-toggle='jcollapse'>" + @translated_locale.click_here + "</a></div></div><div id='markdowncollapse_" + self.uniq_edit_id + "'class='edit_markdown_div jcollapse'><div class='edit_markdown_child_div'><div class='edit_markdown_upper_div'><div class='row'><div class='span pull-right'><a href='#markdowncollapse_" + self.uniq_edit_id + "'data-toggle='jcollapse'>X</a></div></div><div class='format_list_div'><h4>" + @translated_locale.format_text + "</h4><p>" + @translated_locale.headers + "</p><pre>#" + @translated_locale.h1_header + "<br>##" + @translated_locale.h2_header + "</pre><p>" + @translated_locale.text_styles + "</p><pre>*" + @translated_locale.for_italic + "*<br>**" + @translated_locale.for_bold + "**</pre></div><div class='format_list_div'><h4>" + @translated_locale.lists + "</h4><p>" + @translated_locale.unordered + "</p><pre>*" + @translated_locale.item_1 + "<br>*" + @translated_locale.item_2 + "</pre><p>" + @translated_locale.ordered + "</p><pre>1."+ @translated_locale.item_1 + "<br>2." + @translated_locale.item_2 + "</pre></div><div class='format_list_div edit_miscell'><h4>" + @translated_locale.miscellaneous + "</h4><p>" + @translated_locale.images + "</p><pre>" + @translated_locale.format + ":![Alt Text](url)<br>" + @translated_locale.example + ": ![rdf richard](http://rdfrs.com/assets/richard.png)</pre><p>" + @translated_locale.links + "</p><pre>" + @translated_locale.example + ": [Google](http://google.com)</pre><p class='pull-right'><a href='http://daringfireball.net/projects/markdown/basics'target='_blank'>" + @translated_locale.more_help_on_markdown_home_page + "</a></p></div></div></div></div>")
  htmlContent = $(this_obj).html()
  markdwonContent = toMarkdown(htmlContent)
  $textarea.val markdwonContent
  $edit_dom = $("<div></div>")
  $edit_dom.addClass "juvia-preview-content margin-edit"
  $edit_dom.html htmlContent
  $(this_obj).html("<br/>").append($textarea).append($buttons).append($edit_dom).append edit_preview_help
  $buttons.find(".update_comment").bind "click", ->
    self.updateComment this

  $textarea.focus()


Juvia.updateComment = (this_obj) ->
  $ = @$
  $this = $(this_obj)
  $comment_input = $this.parent().parent().find("textarea")
  comment_id = $this.closest(".juvia-data").attr("id")
  comment_id = comment_id.replace("divid", "")
  form = $(".juvia-add-comment-form")
  $container = $(".juvia-add-comment-form").closest(".juvia-container")
  @loadScript "/api/comments/update_comment",
    site_key: $container.data("site-key")
    restrict_comment_length: @restrict_comment_length
    comment_id: comment_id
    content: @compress($comment_input.val())


Juvia.resumeEdit = ($main_edit) ->
  $edit_dom = $main_edit.find(".juvia-preview-content")
  original_html = $edit_dom.html()
  $main_edit.html original_html
  false


Juvia.previewEditComment = (this_obj) ->
  $ = @$
  $textarea = $(this_obj)
  input_value = $textarea.val()
  input_value = input_value.substring(0, 140)  if @restrict_comment_length and input_value.length > 140
  html_output = markdown.toHTML(input_value)
  $preview_dom = $textarea.parent().find(".juvia-preview-content")
  $preview_dom.html(html_output).show()
  false


Juvia.handleUpdateComment = (options) ->
  self = this
  $ = @$
  if options.status is "ok"
    self.resumeEdit $("#divid" + options.comment_id).find(".juvia-comment-pure-content")
  else
    alert "something went wrong"


Juvia.findContainer = (options) ->
  $ = @$
  $ ".juvia-container[data-site-key=\"" + options.site_key + "\"][data-topic-key=\"" + options.topic_key + "\"]"


Juvia.appendComment = (dom_element) ->
  $ = @$
  $("#juvia-comments-box").append dom_element


Juvia.prependComment = (dom_element) ->
  $ = @$
  $(dom_element).prependTo $("#juvia-comments-box")


Juvia.rdf_comment_box = (option) ->
  $ = @$
  comment_number = (if (not (option.comment_number?)) then "" else option.comment_number + "")
  comment_id = option.comment_id
  user_image = option.user_image
  user_name = option.user_name
  comment_text = option.comment_text
  creation_date = option.creation_date
  comment_votes = option.comment_votes
  user_like_comment = option.user_like_comment
  liked = option.liked
  flagged = option.flagged
  comment_permalink = option.permalink
  comment_user_email = option.user_email
  editable = ->
    return true  if option.can_edit is "true"
    false

  a = document.createElement("div")
  a.className = "juvia-comment"
  a.id = "comment-box-" + comment_number  unless comment_number is ""
  a.setAttribute "data-comment-number", comment_number
  a.setAttribute "data-comment-id", comment_id
  
  # Start Header creation 
  $(a).html '<p style="display: block;" id="msg-3" class="user-cartoon-man"><img src="img/demo/av3.jpg" alt=""><span class="msg-block"><strong>Cartoon Man</strong> <span class="time">- 16:29</span><span class="msg">Turn off and turn on your computer then see result.</span></span></p>'
  a
