# frozen_string_literal: true

module Decidim
  module TimeTracker
    class AssigneesController < Decidim::TimeTracker::ApplicationController
      helper_method :assignee

      # show the list of milestones for an assignee
      def show
        enforce_permission_to :show, :milestone, assignee: assignee
      end

      def create
        enforce_permission_to :create, :assignee, activity: activity

        CreateRequestAssignee.call(activity, current_user) do
          on(:ok) do |activity|
            render json: {
              message: I18n.t("assignees.request.success", scope: "decidim.time_tracker"),
              activityId: activity.id
            }
          end

          on(:invalid) do
            render json: {
              message: I18n.t("assignees.request.error", scope: "decidim.time_tracker")
            }, status: :unprocessable_entity
          end
        end
      end

      private

      def activity
        @activity ||= Activity.active.find_by(id: params[:activity_id])
      end

      def assignee
        @assignee ||= Assignee.accepted.find_by(id: params[:id])
      end
    end
  end
end
