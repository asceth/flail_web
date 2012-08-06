require 'digest/md5'

class FlailException < ActiveRecord::Base
  serialize :user
  serialize :params
  serialize :backtrace

  has_many :occurences, :class_name => 'FlailException', :foreign_key => 'digest', :primary_key => 'digest'

  scope :tagged, lambda {|tag| where(:tag => tag)}
  scope :unresolved, where(:resolved_at => nil)
  scope :with_digest, lambda {|digest| where(:digest => digest)}
  scope :within, lambda {|time| where("created_at >= ?", time)}

  before_create :set_digest

  def resolve!
    FlailException.with_digest(self.digest).update_all(:resolved_at => Time.now)
  end

  def set_digest
    bt = self.backtrace.first
    self.digest = Digest::MD5.hexdigest("#{tag}#{environment}#{class_name}:#{bt[:file]}:#{bt[:line]}")
  end

  def trace=(value)
    self.backtrace = []

    value.map do |line|
      file, line, desc = line.split(':')
      self.backtrace << {:file => file, :line => line, :desc => desc}
    end
  end

  module ClassMethods
    def tags
      select('distinct tag').map(&:tag)
    end

    def digested
      unresolved.group_by(&:digest).sort_by do |digest, fes|
        fes.select(&:created_at).max
      end.reverse.inject([]) do |arr, (digest, fes)|
        arr << fes.sort_by(&:created_at).reverse
      end
    end
  end
  extend ClassMethods
end
