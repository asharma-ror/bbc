// -*- Mode: SCSS; tab-width: 8; indent-tabs-mode: true; c-basic-offset: 8 -*-

var Juvia, toMarkdown, RawDeflate, Base64;
if (!Juvia) {
	Juvia = {
    user_logged_in: false,
    restrict_comment_length: false,
    sorting_order: 'oldest',
    current_page: 1,
    total_pages: 1,
    site_key: '',
    topic_key: '',
    topic_url: '',
    topic_title: '',
    username: '',
    user_email: '',
    use_my_user: 'false',
    root_url: '',
    juvia_jquery: '',
    perma_link_comment_id: '',
    translated_locale: ''
	};
}
