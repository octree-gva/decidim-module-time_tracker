# frozen_string_literal: true

module Decidim
  module TimeTracker
    # The data store for a Activity in the Decidim::TimeTracker component. It
    # stores a description and other useful information related to an activity.
    class Activity < ApplicationRecord
      self.table_name = :decidim_time_tracker_activities

      belongs_to :task,
                 class_name: "Decidim::TimeTracker::Task"

      has_many :assignees,
               class_name: "Decidim::TimeTracker::Assignee"

      has_many :time_events,
               class_name: "Decidim::TimeTracker::TimeEvent"

      scope :active, -> { where(active: true) }

      def user_total_seconds(user)
        time_events.where(user: user).sum(&:total_seconds)
      end

      def user_total_seconds_for_date(user, date)
        time_events.created_between(date.beginning_of_day, date.end_of_day).where(user: user).sum(&:total_seconds)
      end

      def assignee_pending?(user)
        assignees.pending.where(user: user).count.positive?
      end

      def assignee_accepted?(user)
        assignees.accepted.where(user: user).count.positive?
      end

      def assignee_rejected?(user)
        assignees.rejected.where(user: user).count.positive?
      end
    end
  end
end
