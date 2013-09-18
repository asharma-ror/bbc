module ImportDisqus
  require 'csv'
  require 'nokogiri'
  require "net/https"
  require "uri"

  def read_disqus
    @doc = Nokogiri::XML(File.open("lib/disqus.xml")) do |config|
      config.strict.nonet
    end
    # @articles = read_articles
    @disqus_articles = read_disqus_articles
    # @threads = create_threads
    # @threads = create_special_threads
    @threads = create_special_disqus_threads
    @posts = read_posts
    create_comments
  end

  def add_post_details
    @doc = Nokogiri::XML(File.open("lib/disqus.xml")) do |config|
      config.strict.nonet
    end
    @articles = read_articles
    @disqus_articles = read_disqus_articles
    @threads = create_special_threads
    @posts = read_all_posts
    @posts.each do |po|
      @restart = true if po[:email] == 'ray@nsls.tv' and po[:created] == '2012-09-24T15:11:14Z'
      if @restart and comment = Comment.where(:author_email => po[:email]).where(:created_at => po[:created]).first
        request = "https://disqus.com/api/3.0/posts/details.json?api_key=128JGbqG5rM0uDqJtbDfUqwwMT1IrJL7ieKqmkUwXRSOBGE51MoimnV48FVvvfrB&post=#{po[:disqus_id]}"
        uri = URI.parse(request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        item = JSON.parse(response.body)
        if item["response"]["isDeleted"] or item["response"]["isFlagged"] or item["response"]["isSpam"]
          comment.destroy
        else
          create_votes(comment, item["response"]["likes"]) if item["response"]["likes"] != 0
        end
      end
    end
  end
  
  def create_votes(comment, likes)
    votes = comment.votes.where(author_email:nil).where(author_name:nil)
    if votes.present?
      vote = votes.first
      vote.like = vote.like.to_i + likes
      vote.save
    else
      vote = comment.votes.build
      vote.like = likes
      vote.save
    end
  end

  def create_comments
    @posts.each do |po|
      # if article = find_article(po[:article_id])
      if article = find_disqus_article(po[:article_id])
        topic = Topic.lookup_or_create(
          "ipv96qqxc0w2gn0l9vduwicbzrlbg2r",
          article[:id],
          article[:title],
          article[:link]
        )
        comment = Comment.create(
          :topic_id => topic.id,
          :comment_number => Comment.last_comment_number(topic.comments) + 1,
          :author_name => po[:name],
          :author_email => po[:email],
          :author_ip => po[:ip],
          :content => po[:message]
        )
        comment.update_attributes({:created_at => po[:created]})
      end
    end
  end
  
  def create_special_threads
    threads = {}
    @doc.xpath('/xmlns:disqus/xmlns:thread').each do |th|
      tid = th.css('id').text
      if find_article(tid) or find_disqus_article(tid)
        threads[th.attributes.first[1].value] = th.css('id').text
      end
    end
    threads
  end

  def create_special_disqus_threads
    threads = {}
    @doc.xpath('/xmlns:disqus/xmlns:thread').each do |th|
      tid = th.css('id').text
      if find_disqus_article(tid) and !find_topic('ipv96qqxc0w2gn0l9vduwicbzrlbg2r', tid)
        threads[th.attributes.first[1].value] = th.css('id').text
      end
    end
    threads
  end

  def create_threads
    threads = {}
    @doc.xpath('/xmlns:disqus/xmlns:thread').each do |th|
      if th.css('link').text[0..24] == "http://richarddawkins.net"
        threads[th.attributes.first[1].value] = th.css('id').text
      end
    end
    threads
  end
  
  def create_all_threads
    threads = {}
    @doc.xpath('/xmlns:disqus/xmlns:thread').each do |th|
      threads[th.attributes.first[1].value] = th.css('id').text
    end
    threads
  end

  def read_posts
    posts = []
    @doc.xpath('/xmlns:disqus/xmlns:post').each do |po|
      if article_id = @threads[po.css('thread').first.attributes.first[1].value]
        posts << {
          :article_id => article_id,
          :created => po.css('createdAt').text,
          :email => po.css('email').text,
          :name => po.css('name').text,
          :ip => po.css('ipAddress').text,
          :message => po.css('message').text
        }
      end
    end
    posts
  end
  
  def read_all_posts
    posts = []
    @doc.xpath('/xmlns:disqus/xmlns:post').each do |po|
      if @threads[po.css('thread').first.attributes.first[1].value]
        po.css('parent').blank? ? parent = nil : parent = po.css('parent').first.attributes.first[1].value
        posts << {
          :created => po.css('createdAt').text,
          :email => po.css('email').text,
          :name => po.css('name').text,
          :ip => po.css('ipAddress').text,
          :message => po.css('message').text,
          :disqus_id => po.first[1],
          :parent_disqus_id => parent
        }
      end
    end
    posts
  end

  # This must be run on the main application before importing
  def export_articles
    File.open("lib/articles.csv", "w") do |f|
      Article.approved.scoped.each do |a|
        f.write(a.id.to_s + ",\"" + a.title.gsub("\"", "\"\"") + "\",\"" + a.full_url.to_s + "\"")
        f.puts
      end
    end
  end

  def read_articles
    articles = []
    lines = File.read("#{Rails.root}/lib/articles.csv").split("\n")
    lines.each do |line|
      begin
        items = CSV.parse(line).first 
        articles << {
          :id => items[0],
          :title => items[1],
          :link => items[2]
        }
      rescue
        puts line
      end
    end
    articles
  end
  
  def read_disqus_articles
    articles = []
    lines = File.read("#{Rails.root}/lib/disqus_ids.csv").split("\n")
    lines.each do |line|
      begin
        items = CSV.parse(line).first 
        articles << {
          :disqus_id => items[0],
          :id => items[1]
        }
      rescue
        puts line
      end
    end
    articles
  end

  def find_article article_id
    @articles.each do |a|
      return a if a[:id] == article_id
    end
    nil
  end
  
  def find_disqus_article article_id
    @disqus_articles.each do |a|
      if a[:disqus_id] == article_id
        return find_article a[:id]
      end
    end
    nil
  end

  def find_special_article article_id
    [''].each do |a|
      return a if a == article_id
    end
    nil
  end
  
  def update_last_posted
    Topic.scoped.each do |t|
      t.update_attribute("last_posted_at", t.last_commented_at)
    end
  end
  
  def find_topic(site_key, topic_key)
    Topic.where(:site_id => Site.find_by_key(site_key).id).where(:key => topic_key).first
  end
  
end
