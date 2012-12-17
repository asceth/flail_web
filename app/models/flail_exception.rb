require 'digest/md5'

class FlailException < ActiveRecord::Base
  serialize :user
  serialize :params
  serialize :backtrace

  has_many :occurrences, :class_name => 'FlailException', :foreign_key => 'digest', :primary_key => 'digest'
  belongs_to :filter, :foreign_key => 'filtered_by', :counter_cache => true

  scope :tagged, lambda {|tag| where(:tag => tag)}
  scope :unresolved, where(:resolved_at => nil)
  scope :with_digest, lambda {|digest| where(:digest => digest)}
  scope :within, lambda {|time| where("created_at >= ?", time)}

  before_create :set_digest

  def resolve!
    FlailException.with_digest(self.digest).update_all(:resolved_at => Time.now)
  end

  def check_against_filters!(filter_collection)
    matching_filter = filter_collection.detect {|filter| filter.match?(self) }
    if matching_filter
      self.resolve_with!(matching_filter)
    end
  end

  def resolved?
    resolved_at?
  end

  def resolve_with!(filter)
    self.resolved_at = Time.now
    self.filtered_by = filter.id

    save!
  end

  def set_digest
    bt = self.backtrace.first

    controller, action = if params.is_a?(Hash)
                           [params['controller'], params['action']]
                         else
                           ['controller', 'action']
                         end

    self.digest = Digest::MD5.hexdigest("#{tag}#{environment}#{class_name}:#{controller}:#{action}:#{bt[:file]}:#{bt[:number]}")
  end

  module ClassMethods
    def tags
      select('distinct tag').map(&:tag)
    end

    def digested(flail_exceptions)
      flail_exceptions.group_by(&:digest).sort_by do |digest, fes|
        fes.select(&:created_at).max
      end.reverse.inject([]) do |arr, (digest, fes)|
        arr << fes.sort_by(&:created_at).reverse
      end.sort_by do |fes|
        fes.first.created_at
      end.reverse
    end

    def swing!(params)
      fe = FlailException.new

      fe.target_url = params[:target_url]
      fe.referer_url = params[:referer_url]
      fe.user_agent = params[:user_agent]
      fe.environment = params[:environment]
      fe.hostname = params[:hostname]
      fe.tag = params[:tag]
      fe.class_name = params[:class_name]
      fe.message = params[:message]
      fe.params = params[:parameters] || {}
      fe.user = params[:user] || {}
      fe.backtrace = params[:trace] || []
      fe.rack = params[:rack] || {}

      fe.save!
      fe
    end
  end
  extend ClassMethods
end
