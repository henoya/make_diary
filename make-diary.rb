require 'date'
require 'holiday_japan'
require 'erb'

WDAY = %w[日 月 火 水 木 金 土]

def is_holiday(date)
  return true if HolidayJapan.check(date)
  return true if date.wday == 0 || date.wday == 6
  false
end

def make_calender(start_date, weeks=6)
  start_date = Date.parse(start_date) if start_date.kind_of?(String)
  result_weeks = []
  start_week_date = (start_date - (start_date.wday - 1)) - 7 # 先週の月曜日
  (0..weeks - 1).each do |week|
    week_list = []
    (0..6).each do |day|
      target_day = start_week_date + week * 7 + day
      day_str = target_day.strftime("%d")
      if is_holiday(target_day)
        day_str = "[#{day_str}]"
      elsif target_day == start_date
        day_str = ">#{day_str}<"
      elsif target_day.day == 1
        day_str = "/#{day_str} "
      else
        day_str = " #{day_str} "
      end
      week_list << day_str
    end
    result_weeks << week_list
  end
  result_weeks
end

# ARGV[0] : start_date
# ARGV[1] : end_date

if ARGV.count < 2
  puts "Usage $0 <start-date> <end_date> [<work_place_name>]"
  exit 1
end

start_date = Date.parse(ARGV[0])
end_date = Date.parse(ARGV[1])
work_place_name = ARGV[2].nil? ? "" : ARGV[2]

unless start_date < end_date
  puts " <start_date> < <end_date> で指定してください"
  exit
end

(start_date..end_date).each do |day|
  wday = WDAY[day.wday]
  holiday_name = HolidayJapan.name(day)
  calender_list = make_calender(day, 6)

  full_date_str = day.strftime("%Y年%m月%d日（#{wday}）")

  workplace = holiday_name.nil? ? work_place_name : ''

  week_list = []
  calender_list.each do |week|
    week_list << week.join('')
  end
  calender = week_list.join("\n")

  puts "#{full_date_str}#{workplace}#{holiday_name}"
  # puts calender

  template_file_name = 'dialy_template.erb'
  template_file = ''
  File.open(template_file_name, 'r') do |file|
    template_file = file.read
  end

  erb = ERB.new(template_file)

  dialy_text = erb.result(binding)
  File.open("dialy_file/#{full_date_str}#{workplace}#{holiday_name}.md", 'w') do |file|
    file.puts(dialy_text)
  end
end
