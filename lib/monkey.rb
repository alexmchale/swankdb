class Fixnum
  def spaces
    return '' if self < 0
    '&nbsp;' * self
  end
end

class Hash
  def to_url
    map {|key, value| "#{CGI.escape key.to_s}=#{CGI.escape value.to_s}"}.join "&"
  end
end

class String
  def striphtml
    Hpricot(self).to_plain_text
  end
end

