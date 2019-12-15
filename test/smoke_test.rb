require_relative './helper'

class SmokeTest < CGITest
  def test_pro_navigation
    visit("/spro/new.cgi")
    assert page.has_content?('Subscribe to')

    visit("/spro/update.cgi")
    assert page.has_content?('Update your')

    visit("/spro/cancel.cgi")
    assert page.has_content?('Cancel your')

    visit("/spro/delete.cgi")
    assert page.has_content?('Confirm your')
  end
end
