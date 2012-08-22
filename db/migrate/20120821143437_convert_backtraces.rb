class ConvertBacktraces < ActiveRecord::Migration
  def up
    FlailException.all.map do |fe|
      trace = fe.backtrace.dup
      fe.backtrace = trace.inject([]) do |newtrace, line|
        newtrace << {:number => line[:line], :file => line[:file], :method => line[:desc]}
      end

      fe.save
    end
  end

  def down
  end
end
