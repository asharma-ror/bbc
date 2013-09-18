Juvia.reqLoadComment = ->
  makeQueryString = (options) ->
    key = undefined
    params = []
    for key of options
      params.push encodeURIComponent(key) + "=" + encodeURIComponent(options[key])
    params.join "&"
  makeApiUrl = (options) ->
    
    # Makes sure that each call generates a unique URL, otherwise
    # the browser may not actually perform the request.
    window._juviaRequestCounter = 0  unless "_juviaRequestCounter" of window
    result = self.root_url + "/api/comments/load_comments.js" + "?_c=" + window._juviaRequestCounter + "&" + makeQueryString(options)
    window._juviaRequestCounter++
    result
  self = this
  options =
    site_key: self.site_key
    topic_key: self.topic_key
    topic_url: self.topic_url
    topic_title: self.topic_title
    sorting_order: self.sorting_order
    username: self.username
    user_email: self.user_email
    restrict_comment_length: self.restrict_comment_length
    use_my_user: self.use_my_user
    user_logged_in: self.user_logged_in
    perma_link_comment_id: self.perma_link_comment_id

  s = document.createElement("script")
  s.async = true
  s.type = "text/javascript"
  s.className = "juvia"
  s.src = makeApiUrl(options)
  (document.getElementsByTagName("head")[0] or document.getElementsByTagName("body")[0]).appendChild s
