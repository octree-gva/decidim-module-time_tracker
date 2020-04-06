# frozen_string_literal: true

require "spec_helper"

module Decidim::TimeTracker::Admin
  describe CreateAssignee do
    let(:subject) { described_class.new(form, activity) }
    let(:form) do
      double(
        # AssigneeForm,
        name: Faker::Name.name,
        email: "user@example.org",
        invalid?: invalid,
        current_user: user
      )
    end

    let(:activity) { create :activity, task: task }
    let(:task) { create :task }
    let(:user) { create :user, :admin, :confirmed, organization: organization }
    let(:organization) { create :organization }
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a new activity for the task" do
        expect { subject.call }.to change { Decidim::TimeTracker::Assignee.count }.by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::TimeTracker::Assignee, user, hash_including(:user, :activity, :status, :invited_at, :invited_by_user))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        # action_log = Decidim::ActionLog.last
        # expect(action_log.version).to be_present
      end
    end
  end
end
