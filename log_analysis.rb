class LogAnalysis
  def initialize(path, target_url)
    raise ArgumentError unless File.exists?( path )

    @log = File.open(path)
    @summary_data = Hash.new(0)
    @target_url = target_url
    target_url.each {|target| @summary_data[target] = {call: 0, dyno: Hash.new(0), response_time:Array.new}}
    @regex = /method=(?<method>[^\s]+) path=(?<path>[^\s]+) host=(?<host>[^\s]+) fwd="(?<fwd>[^"]+)" dyno=(?<dyno>[^\s]+) connect=(?<connect>[^ms]+)ms service=(?<service>[^ms]+)ms/
  end

  public

  def mean(array)
    return 0 unless array.any?
    array.inject{ |sum, el| sum + el }.to_f / array.size
  end

  def median(array)
    return 0 unless array.any?
    sorted = array.sort
    len = sorted.length
    return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def mode(array)
    return 0 unless array.any?
    freq = array.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    array.max_by { |v| freq[v] }
  end

  def parse(line)
    return line.match(@regex).captures
  end

  def replace_user(path)
    return path.sub(%r{users\/[^\s\/]+},"users/{user_id}")
  end

  def summary
    analysis = Proc.new do |line|
      method, path, host, fwd, dyno, connect, service = parse(line)
      path_no_user = replace_user(path)
      url = "#{method} #{path_no_user}"
      if @summary_data.key?(url)
        @summary_data[url][:call] += 1;
        @summary_data[url][:dyno]["#{dyno}"] += 1
        @summary_data[url][:response_time] << connect.to_i+service.to_i
      else
        # puts "not target url #{url}"
      end
    end

    @log.each_line.collect(&analysis)
  end

  def save_output(filename)
    reportFile = File.new(filename, "w+")
    if reportFile
        #puts summary data
        @summary_data.each do |url, data|
          puts url
          puts "called #{data[:call]} times"
          puts "mean of response time: #{mean(data[:response_time])}ms"
          puts "median of response time: #{median(data[:response_time])}ms"
          puts "mode of response time: #{mode(data[:response_time])}ms"
          call_dyno_sorted = data[:dyno].sort_by{|k,v| v}.reverse
          top_dyno, dyno_value = call_dyno_sorted.first
          top_dyno ||= "NaN"
          dyno_value ||= 0
          puts "most dyno responded: #{top_dyno} #{dyno_value} times"
          puts ""
        end

        @summary_data.each do |url, data|
          reportFile.write("#{url}\n")
          reportFile.write("called #{data[:call]} times\n")
          reportFile.write("mean of response time: #{mean(data[:response_time])}ms\n")
          reportFile.write("median of response time: #{median(data[:response_time])}ms\n")
          reportFile.write("mode of response time: #{mode(data[:response_time])}ms\n")
          call_dyno_sorted = data[:dyno].sort_by{|k,v| v}.reverse
          top_dyno, dyno_value = call_dyno_sorted.first
          top_dyno ||= "NaN"
          dyno_value ||= 0
          reportFile.write("most dyno responded: #{top_dyno} #{dyno_value} times\n")
          reportFile.write("\n")
        end
    else
       puts "Unable to open file!"
    end
  end

end
