module Admin
  class BaseController < ApplicationController
    before_action :ensure_auth
  end
end
