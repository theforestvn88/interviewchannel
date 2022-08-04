# frozen_string_literal: true

module SocialLinks

  def social_support
    Setting[:social] #   "blog", "hackerrank", "leetcode", "dev.to", "stackoverflow", "codeforces", "medium", "linkedin", "twitter"
  end

  def social_link_valid?(social, link)
    return true if link.blank?

    case social
    when "stackoverflow"
      /\A(http(s)?:\/\/)?(((www|pt|ru|es|ja).)?stackoverflow.com|(www.)?stackexchange.com)\/.*\Z/.match?(link)
    when "medium"
      /\A(http(s)?:\/\/)?(www.medium.com|medium.com)\/.*\Z/.match?(link)
    when "dev.to"
      /\A(http(s)?:\/\/)?(www.dev.to|dev.to)\/.*\Z/.match?(link)
    when "codeforces"
      /\A(http(s)?:\/\/)?(www.codeforces.com|codeforces.com)\/.*\Z/.match?(link)
    when "hackerrank"
      /\A(http(s)?:\/\/)?(www.hackerrank.com|hackerrank.com)\/.*\Z/.match?(link)
    when "leetcode"
      /\A(http(s)?:\/\/)?(www.leetcode.com|leetcode.com)\/.*\Z/.match?(link)
    when "linkedin"
      /\A(http(s)?:\/\/)?(www.linkedin.com|linkedin.com|[A-Za-z]{2}.linkedin.com)\/.*\Z/.match?(link)
    else
      true
    end
  end
end