require 'redmine'

module Zendesk
  module Rest
    class Ticket < ActiveResource::Base
    end
  end
end

class ZendeskListener < Redmine::Hook::Listener
  # We need this helper for rendering the detail stuff, and the accessors to fake it out
  include ActionView::Helpers::IssuesHelper
  attr_accessor :controller, :request
  
  def controller_issues_edit_after_save(context)
    puts context.inspect
    self.controller = context[:controller]
    self.request = context[:request]
    
    custom_field = CustomField.find(Setting.plugin_zendesk_plugin['field'])
    return unless custom_field
    
    journal = context[:journal]
    return unless journal
    
    issue = context[:issue]
    return unless issue && issue.custom_value_for(custom_field)
    
    zendesk_id_value = issue.custom_value_for(custom_field)
    return unless zendesk_id_value
    
    zendesk_ids = zendesk_id_value.to_s.split(',').map(&:strip)
    return unless !zendesk_ids.empty?
    
    Zendesk::Rest::Ticket.site = Setting.plugin_zendesk_plugin['zendesk_url']
    Zendesk::Rest::Ticket.user = Setting.plugin_zendesk_plugin['zendesk_username']
    Zendesk::Rest::Ticket.password = Setting.plugin_zendesk_plugin['zendesk_password']
    
    zendesk_ids.each do |zendesk_id|
      issue_url = "#{Setting.plugin_zendesk_plugin['redmine_url']}/issues/#{issue.id}"
      comment = "Redmine ticket #{issue_url} was updated by #{journal.user.name}:\n\n"
      
      for detail in journal.details
        comment << show_detail(detail, true)
        comment << "\n"
      end
      
      if journal.notes && !journal.notes.empty?
        comment << journal.notes
      end
      
      ticket = Zendesk::Rest::Ticket.new(:id => zendesk_id)
      ticket.comment = { :is_public => false, :value => comment }
      ticket.save
    end
  end
end
