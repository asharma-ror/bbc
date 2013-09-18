module ApiHelper
  def juvia_handle_response(options)
    "Juvia.handleResponse(#{options.to_json})".html_safe
  end
  
  def juvia_handle_load_comment(options)
    "Juvia.handleLoadComment(#{options.to_json})".html_safe
  end
  
  def juvia_reinstall_behavior
    "Juvia.reinstallBehavior();".html_safe
  end

  def jsonp_response(options)
  	raise "'@jsonp' must be set!" if !@jsonp
  	"#{@jsonp}(#{options.to_json})".html_safe
  end

  def avatar_img(author_email, author_email_md5)
    default_url = "http://comments.richarddawkins.net/assets/default.jpg"
    if author_email
      return "http://www.gravatar.com/avatar/#{author_email_md5}? d=#{CGI.escape(default_url)}"
    else
      return default_url
    end
  end
  
  def sorting_options
    {:popular => "most_popular",
     :newest  => "newest",
     :oldest  => "oldest"}
  end
end
