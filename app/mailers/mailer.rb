class Mailer < ActionMailer::Base
  default :from => Juvia::Application.config.from
  uri = URI.parse(Juvia::Application.config.base_url)
  default_url_options[:protocol] = uri.scheme
  default_url_options[:host] = uri.host

  def comment_posted(parent_comment, child_comment)
    @site    = parent_comment.site
    @comment = parent_comment
    @child_comment = child_comment
    mail(:to => parent_comment.author_email, :subject => "Reply to your comment in [#{parent_comment.topic.title.split[0,5].join(" ").to_s}...]")
  end
  
  def send_comment_notification_to_subscriber(comment,author_detail)
    @site    = comment.site
    @comment = comment
    mail(:to => author_detail.author_email, :subject => "Comment on your notified topic in [#{comment.topic.title.split[0,5].join(" ").to_s}...]")
  end
end
