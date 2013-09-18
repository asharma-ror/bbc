module SpecSupport
  def login(user)
    if example.metadata[:type] == :request
      visit("/test/login?user_id=#{user.id}")
      page.should have_content("ok")
    elsif example.metadata[:type] == :controller
      raise "Please use sign_in instead in controller specs"
    elsif example.metadata[:type] == :view
      @ability = Ability.new(user)
      assign(:current_ability, @ability)
      controller.stub(:current_user, user)
      view.stub(:current_user, user)
    else
      raise "Test type #{example.metadata[:type].inspect} not supported"
    end
  end
  
  def visit_html(html)
    File.open('public/_test.html', 'w') do |f|
      f.write(html)
    end
    visit('/_test.html')
  end
  
  def show_topic(site_key, topic_key, options = {})
    if options[:guest_view].blank?
      visit("/test/js_api?site_key=#{site_key}&topic_key=#{topic_key}")
    else
      visit("/test/js_api?site_key=#{site_key}&topic_key=#{topic_key}&guest_view=#{options[:guest_view]}")
    end
  end

  def eventually(max_wait = 5, sleep_time = 0.01)
    deadline = Time.now + max_wait
    while Time.now < deadline
      result = yield
      if result
        return result
      else
        sleep(sleep_time)
      end
    end
    fail "Something that should eventually happen never happened"
  end
end
