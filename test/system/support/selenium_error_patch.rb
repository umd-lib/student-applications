# Taken from
# https://github.com/alphagov/forms-admin/commit/5ea98767d765a396ed06cf2cba8f9afb1b10fc0e#diff-c36c07a0c7f499b1b95634f9dce1a10ebf4d10a9dee872f39f746a9efa555ddbR1-R34
# via https://github.com/tf/pageflow/commit/238b32499a7455aa5e6ec3823addd252d75b4014
# both of which use the MIT License
#
# The MIT License (MIT)
#
# Copyright (c) 2022 Crown Copyright (Government Digital Service)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Monkey patch for a specific intermittent Selenium error.
#
# Intermittently, Selenium/Chromedriver raises `Selenium::WebDriver::Error::UnknownError`
# with the message "Node with given id does not belong to the document".

# Capybara's automatic waiting/retrying mechanism doesn't catch it,
# leading to failure.
#
# We intercept the initialization of `UnknownError`. If the message matches this specific
# case, we raise a `StaleElementReferenceError` instead. This uses Capybara's
# retry logic which makes doesn't fail the test
#
# This can be removed once the following issue is resolved:
# https://github.com/teamcapybara/capybara/issues/2800
#
# taken from the following issue:
# https://github.com/teamcapybara/capybara/issues/2800#issuecomment-3049956982
module Selenium
  module WebDriver
    module Error
      class UnknownError
        alias_method :old_initialize, :initialize
        def initialize(msg = nil)
          if msg&.include?("Node with given id does not belong to the document")
            raise StaleElementReferenceError, msg
          end

          old_initialize(msg)
        end
      end
    end
  end
end
