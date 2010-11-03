# Redmine sample plugin
require 'redmine'
require File.dirname(__FILE__) + '/lib/zendesk'

RAILS_DEFAULT_LOGGER.info 'Zendesk integration'

Redmine::Plugin.register :zendesk_plugin do
  name 'Zendesk plugin'
  author 'Zach Wily'
  description 'Updates associated Zendesk tickets when Redmine issues are updated'
  version '0.0.1'
  settings :default => {
      'zendesk_url' => 'http://support.zendesk.com/',
      'zendesk_username' => 'zendeskuser',
      'zendesk_password' => 'zendeskpassword',
      'field' => nil,
      'redmine_url' => 'https://your.redmine.url/'
    },
    :partial => 'settings/zendesk_plugin_settings'
end
