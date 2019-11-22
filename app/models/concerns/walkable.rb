# frozen_string_literal: true

require 'active_support/concern'

# this allows for the step functionality of the multiple part form
module Walkable
  extend ActiveSupport::Concern

  included do
    attr_writer :current_step

    def steps
      self.class.steps
    end

    def current_step
      @current_step || steps.first
    end

    def next_step
      self.current_step = steps[steps.index(current_step) + 1]
    end

    def previous_step
      self.current_step = steps[steps.index(current_step) - 1]
    end

    def first_step?
      current_step == steps.first
    end

    def last_step?
      current_step == steps.last
    end

    def all_valid?
      steps.all? do |step|
        self.current_step = step
        valid?
      end
    end
  end

  class_methods do
    def steps
      %w[id_and_semester contact_info work_experience skills availability upload_resume comments_confirmation]
    end

    def first_step
      steps.first
    end

    def last_step
      steps.last
    end
  end
end
