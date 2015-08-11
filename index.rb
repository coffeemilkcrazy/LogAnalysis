require_relative 'test_log_analysis.rb'
require_relative 'log_analysis.rb'

log_analysis = LogAnalysis.new("sample.log", ["GET /api/users/{user_id}/count_pending_messages",
              "GET /api/users/{user_id}/get_messages",
              "GET /api/users/{user_id}/get_friends_progress",
              "GET /api/users/{user_id}/get_friends_score",
              "POST /api/users/{user_id}",
              "GET /api/users/{user_id}"])

log_analysis.summary
log_analysis.save_output("report.txt")
