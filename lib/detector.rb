module DataDetector
  extend self

  def add_data_type(name, regex, &validator)
    validator ||= Proc.new {true} # If no validator block is given, assume the regex is correct.

    @types ||= []
    @types << { :name => name, :regex => regex, :validator => validator }
  end

  add_data_type('fedex', /\b(\d\d\d\d ?\d\d\d\d ?\d\d\d\d)\b/) do |s|
    is_fedex_express(s)
  end

  add_data_type('ups', /\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/)

  #add_data_type('link', /((http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)(\s|$)/)

  def detect_first(text)
    @types ||= []

    @types.map {|t| t.merge :offset => (text =~ t[:regex]), :data => $&}.
           find_all {|o| o[:offset]}.
           find_all {|o| o[:validator].call o[:data]}.
           sort {|o1, o2| o1[:offset] <=> o2[:offset]}.
           first
  end

  def detect_all(text)
    detections = []
    offset = 0

    while true
      next_result = detect_first(text[offset, text.length])

      return detections unless next_result

      next_result[:offset] += offset
      detections << next_result

      offset = next_result[:offset] + next_result[:data].length
    end
  end

  def modify_all(text)
    offset = 0
    result = ''

    detect_all(text).each do |dp|
      result += text[offset, dp[:offset] - offset]
      result += yield(dp[:data], dp)

      offset = dp[:offset] + dp[:data].length
    end

    result + text[offset, text.length]
  end

  def assign_all(text)
    modify_all(text) do |s, dp|
      case dp[:name]
      when 'fedex'
        url = "http://www.fedex.com/Tracking?language=english&cntry_code=us&tracknumbers=#{s}"
        href url, s
      when 'ups'
        url = "http://wwwapps.ups.com/WebTracking/processInputRequest?sort_by=status&tracknums" +
              "_displayed=1&TypeOfInquiryNumber=T&loc=en_US&InquiryNumber1=#{s}&track.x=0&track.y=0"
        href url, s
      when 'link'
        href s, s
      else
        s
      end
    end
  end

  def href(url, label)
    '<a href="%s" class="urlified">%s</a>' % [ url, label ]
  end

  def is_fedex_express(s)
    return false unless s.length == 12
    return false if s =~ /[^0-9]/

    digits = s.split(//).map {|i| i.to_i}
    sum = (0..10).map {|i| digits[i] * [3, 1, 7][i % 3]}.sum
    (sum % 11 % 10) == digits.last
  end
end
