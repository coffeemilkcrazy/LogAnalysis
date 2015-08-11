require_relative 'log_analysis.rb'
require 'minitest/autorun'

describe LogAnalysis do
  before do
    @log_analysis = LogAnalysis.new("sample.log", ["GET /api/users/{user_id}/count_pending_messages",
                  "GET /api/users/{user_id}/get_messages",
                  "GET /api/users/{user_id}/get_friends_progress",
                  "GET /api/users/{user_id}/get_friends_score",
                  "POST /api/users/{user_id}",
                  "GET /api/users/{user_id}"])
  end

  describe "find mean value" do
    it "1,2,3,4,5 must equal 3" do
      @log_analysis.mean([1,2,3,4,5]).must_equal 3
    end

    it "3,3,4,1 must equal 2.75" do
      @log_analysis.mean([3,3,4,1]).must_equal 2.75
    end
  end

  describe "find median value" do
    it "1,2,3,4,5 must equal 3" do
      @log_analysis.median([1,2,3,4,5]).must_equal 3
    end

    it "3,3,4,1 must equal 3" do
      @log_analysis.median([3,3,4,1]).must_equal 3
    end
  end

  describe "find mode value" do
    it "1,1,3,4,5 must equal 1" do
      @log_analysis.mode([1,1,3,4,5]).must_equal 1
    end

    it "3,3,4,1 must equal 3" do
      @log_analysis.mode([3,3,4,1]).must_equal 3
    end
  end

  describe "parse log line" do
    it "method should be POST" do
      method, path, host, fwd, dyno, connect, service = @log_analysis.parse("2014-01-09T06:17:19.658075+00:00 heroku[router]: at=info method=POST path=/api/users/100002855870680 host=services.pocketplaylab.com fwd=\"27.131.40.242\" dyno=web.10 connect=1ms service=442ms status=200 bytes=52")
      method.must_equal "POST"
      path.must_equal "/api/users/100002855870680"
      dyno.must_equal "web.10"
      connect.must_equal "1"
      service.must_equal "442"
    end

    it "method should be POST" do
      method, path, host, fwd, dyno, connect, service = @log_analysis.parse("2014-01-09T06:15:59.090644+00:00 heroku[router]: at=info method=GET path=/api/users/100007107163063/get_messages host=services.pocketplaylab.com fwd=\"75.177.118.225\" dyno=web.2 connect=0ms service=58ms status=200 bytes=443")
      method.must_equal "GET"
      path.must_equal "/api/users/100007107163063/get_messages"
      dyno.must_equal "web.2"
      connect.must_equal "0"
      service.must_equal "58"
    end
  end

  describe "replace user in log line" do
    it "url should be replace user_id to {user_id}" do
      @log_analysis.replace_user("/api/users/100002855870680").must_equal "/api/users/{user_id}"
    end

    it "url should be replace user_id/... to {user_id}" do
      @log_analysis.replace_user("/api/users/100007107163063/get_messages").must_equal "/api/users/{user_id}/get_messages"
    end
  end

end
